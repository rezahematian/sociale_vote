import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/entities/poll_option.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_configuration.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_id.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_status.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_type.dart';
import 'package:sociale_vote/infrastructure/poll/repositories/poll_repository_supabase.dart';

// Exercises the real Supabase repository and its snake_case HTTP payload.
// Every request is handled in memory; no live Supabase account is contacted.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const userId = '00000000-0000-4000-8000-000000000001';
  const pollId = '00000000-0000-4000-8000-000000000002';
  Map<String, dynamic>? stored;
  final unexpected = <String>[];

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    final client = MockClient((request) async {
      http.Response response(Object value, [int status = 200]) => http.Response(
            jsonEncode(value), status,
            headers: {'content-type': 'application/json'},
            request: request,
          );
      if (request.url.path == '/auth/v1/token') {
        final expires = DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600;
        String encode(Object value) => base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
        final token = '${encode({'alg': 'HS256', 'typ': 'JWT'})}.'
            '${encode({'sub': userId, 'role': 'authenticated', 'exp': expires})}.test-signature';
        return response({
          'access_token': token,
          'refresh_token': 'test-only-refresh-token',
          'token_type': 'bearer',
          'expires_in': 3600,
          'expires_at': expires,
          'user': {
            'id': userId, 'aud': 'authenticated', 'role': 'authenticated',
            'email': 'minmax@example.invalid', 'app_metadata': {}, 'user_metadata': {},
            'created_at': '2026-01-01T00:00:00Z',
          },
        });
      }
      if (request.method == 'POST' && request.url.path == '/rest/v1/polls') {
        final decoded = jsonDecode(request.body);
        final payload = Map<String, dynamic>.from(decoded is List ? decoded.single : decoded as Map);
        stored = {
          ...payload, 'id': pollId, 'created_at': '2026-09-19T00:00:00Z', 'vote_count': 0,
        };
        return response([stored], 201);
      }
      if (request.method == 'GET' && request.url.path == '/rest/v1/polls_with_vote_count') {
        return response(stored == null ? [] : [stored]);
      }
      if (request.method == 'GET' && request.url.path == '/rest/v1/user_profiles') {
        return response([]);
      }
      unexpected.add('${request.method} ${request.url.path}');
      return response({'message': 'Unexpected mock request'}, 500);
    });
    await Supabase.initialize(
      url: 'https://minmax-test.invalid',
      anonKey: 'test-only-public-key',
      httpClient: client,
      debug: false,
      authOptions: const FlutterAuthClientOptions(
        autoRefreshToken: false,
        detectSessionInUri: false,
      ),
    );
    await Supabase.instance.client.auth.signInWithPassword(
      email: 'minmax@example.invalid', password: 'test-only-password',
    );
  });
  tearDownAll(() async => Supabase.instance.dispose());
  setUp(() { stored = null; unexpected.clear(); });

  for (final range in [(1, 3), (2, 4)]) {
    test('Supabase insert and a fresh repository reload preserve $range', () async {
      final poll = Poll(
        id: const PollId(pollId),
        title: 'Selection persistence',
        type: PollType.multipleChoice,
        status: PollStatus.open,
        createdByUserId: userId,
        options: [for (var i = 1; i <= 5; i++) PollOption(id: 'opt_$i', label: 'Answer $i')],
        configuration: PollConfiguration(minSelections: range.$1, maxSelections: range.$2),
      );
      final created = await PollRepositorySupabase().createPoll(poll);
      expect(stored!['min_selections'], range.$1);
      expect(stored!['max_selections'], range.$2);
      expect(created.configuration.minSelections, range.$1);
      expect(created.configuration.maxSelections, range.$2);
      final reloaded = await PollRepositorySupabase().getPollDetail(created.id);
      expect(reloaded, isNotNull);
      expect(reloaded!.configuration.minSelections, range.$1);
      expect(reloaded.configuration.maxSelections, range.$2);
      expect(unexpected, isEmpty);
    });
  }
}
