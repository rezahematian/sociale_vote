import 'package:sociale_vote/core/supabase/supabase_client.dart';
import 'package:sociale_vote/domain/identity/entities/account_discovery_item.dart';
import 'package:sociale_vote/domain/identity/entities/user_profile.dart';
import 'package:sociale_vote/domain/identity/repositories/account_discovery_repository.dart';
import 'package:sociale_vote/domain/identity/value_objects/actor_type.dart';
import 'package:sociale_vote/domain/identity/value_objects/institution_level.dart';
import 'package:sociale_vote/domain/identity/value_objects/verification_level.dart';
import 'package:sociale_vote/domain/identity/value_objects/verification_status.dart';

class AccountDiscoveryRepositoryImpl
    implements AccountDiscoveryRepository {
  @override
  Future<List<AccountDiscoveryItem>> searchAccounts({
    required String query,
    int limit = 20,
    int offset = 0,
  }) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.length < 2 || limit <= 0) {
      return const <AccountDiscoveryItem>[];
    }

    final response = await AppSupabase.client.rpc(
      'search_public_accounts',
      params: <String, dynamic>{
        'p_query': normalizedQuery,
        'p_limit': limit.clamp(1, 30),
        'p_offset': offset < 0 ? 0 : offset,
      },
    );

    if (response is! List) {
      return const <AccountDiscoveryItem>[];
    }

    return response
        .whereType<Map>()
        .map((row) => _mapItem(Map<String, dynamic>.from(row)))
        .toList(growable: false);
  }

  AccountDiscoveryItem _mapItem(Map<String, dynamic> row) {
    final profile = UserProfile(
      id: _readRequiredString(row, 'user_id'),
      displayName: _normalizeNullable(row['display_name'] as String?),
      username: _normalizeNullable(row['username'] as String?),
      avatarUrl: _normalizeNullable(row['avatar_url'] as String?),
      bio: _normalizeNullable(row['bio'] as String?),
      country: _normalizeNullable(row['country'] as String?),
      city: _normalizeNullable(row['city'] as String?),
      actorType: ActorTypeX.fromStorageKey(row['actor_type'] as String?),
      verificationLevel: VerificationLevelX.fromStorageKey(
        row['verification_level'] as String?,
      ),
      institutionLevel: _readInstitutionLevel(row['institution_level']),
      verificationStatus: VerificationStatus.none,
      officialTitle: _normalizeNullable(row['official_title'] as String?),
      institutionName: _normalizeNullable(
        row['institution_name'] as String?,
      ),
      organizationName: _normalizeNullable(
        row['organization_name'] as String?,
      ),
      createdAt: _readDateTime(row['created_at'], 'created_at'),
      updatedAt: _readDateTime(row['updated_at'], 'updated_at'),
    );

    return AccountDiscoveryItem(
      profile: profile,
      followerCount: _readInt(row['follower_count']),
      isFollowing: row['is_following'] == true,
    );
  }

  InstitutionLevel? _readInstitutionLevel(dynamic value) {
    if (value is! String || value.trim().isEmpty) {
      return null;
    }
    return InstitutionLevelX.fromStorageKey(value);
  }

  String _readRequiredString(Map<String, dynamic> row, String key) {
    final value = row[key]?.toString().trim() ?? '';
    if (value.isEmpty) {
      throw StateError('Campo account discovery non valido: $key');
    }
    return value;
  }

  DateTime _readDateTime(dynamic value, String key) {
    final parsed = value is DateTime
        ? value.toLocal()
        : DateTime.tryParse(value?.toString() ?? '')?.toLocal();
    if (parsed == null) {
      throw StateError('Campo datetime non valido: $key');
    }
    return parsed;
  }

  int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String? _normalizeNullable(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }
}
