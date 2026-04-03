// lib/infrastructure/news/aggregator/web_news_proxy_provider.dart

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sociale_vote/infrastructure/news/aggregator/news_provider.dart';

class WebNewsProxyProvider implements NewsProvider {
  static const String _defaultFunctionName = 'news-proxy';

  final SupabaseClient _client;
  final String functionName;
  final Map<String, String> headers;

  WebNewsProxyProvider({
    SupabaseClient? client,
    String functionName = _defaultFunctionName,
    Map<String, String>? headers,
  })  : _client = client ?? Supabase.instance.client,
        functionName = functionName.trim().isEmpty
            ? _defaultFunctionName
            : functionName.trim(),
        headers = Map<String, String>.unmodifiable(
          headers ?? const <String, String>{},
        );

  @override
  String get id => 'webproxy';

  @override
  Future<ProviderFetchResult> fetchNews({
    String? countryCode,
    String? cityId,
    String? topic,
    String? language,
    int? limit,
    int? offset,
  }) async {
    try {
      final response = await _invokeWithAuthRecovery(
        body: <String, dynamic>{
          'action': 'feed',
          'countryCode': countryCode,
          'cityId': cityId,
          'topic': topic,
          'language': language,
          'limit': limit,
          'offset': offset,
        },
      );

      final payload = _asStringDynamicMap(response.data);
      final items = _readItems(payload['items'] ?? response.data);

      return ProviderFetchResult(
        providerId: payload['providerId']?.toString() ?? id,
        items: items,
        rateLimited: _readBool(payload['rateLimited']) ?? false,
        statusCode: _readInt(payload['statusCode']),
        error: _readErrorPayload(payload),
      );
    } catch (e) {
      return ProviderFetchResult(
        providerId: id,
        items: const <Map<String, dynamic>>[],
        rateLimited: _looksRateLimited(e),
        statusCode: _extractStatusCode(e),
        error: e,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> fetchNewsDetail(String id) async {
    final response = await _invokeWithAuthRecovery(
      body: <String, dynamic>{
        'action': 'detail',
        'id': id,
      },
    );

    final payload = _asStringDynamicMap(response.data);

    final directItem = payload['item'];
    if (directItem is Map<String, dynamic>) {
      return directItem;
    }
    if (directItem is Map) {
      return directItem.map(
        (key, value) => MapEntry(key.toString(), value),
      );
    }

    final nestedData = payload['data'];
    if (nestedData is Map<String, dynamic>) {
      return nestedData;
    }
    if (nestedData is Map) {
      return nestedData.map(
        (key, value) => MapEntry(key.toString(), value),
      );
    }

    if (payload.isNotEmpty &&
        (payload.containsKey('id') ||
            payload.containsKey('title') ||
            payload.containsKey('url'))) {
      return payload;
    }

    throw StateError(
      'Risposta detail non valida dalla Edge Function "$functionName".',
    );
  }

  Future<FunctionResponse> _invokeWithAuthRecovery({
    required Map<String, dynamic> body,
  }) async {
    Object? authFailure;

    try {
      return await _invoke(body: body);
    } catch (error) {
      if (!_looksAuthFailure(error)) {
        rethrow;
      }
      authFailure = error;
    }

    final refreshed = await _tryRefreshSession();
    if (refreshed) {
      try {
        return await _invoke(body: body);
      } catch (error) {
        if (!_looksAuthFailure(error)) {
          rethrow;
        }
        authFailure = error;
      }
    }

    final fallbackHeaders = _buildInvokeHeaders(forceApiKeyAuth: true);
    if (fallbackHeaders != null) {
      return _client.functions.invoke(
        functionName,
        headers: fallbackHeaders,
        body: body,
      );
    }

    throw authFailure ??
        StateError(
          'Impossibile invocare la Edge Function "$functionName".',
        );
  }

  Future<FunctionResponse> _invoke({
    required Map<String, dynamic> body,
  }) {
    return _client.functions.invoke(
      functionName,
      headers: _buildInvokeHeaders(),
      body: body,
    );
  }

  Map<String, String>? _buildInvokeHeaders({
    bool forceApiKeyAuth = false,
  }) {
    final merged = <String, String>{
      ...headers,
    };

    if (forceApiKeyAuth) {
      final apiKey = _resolveApiKey();
      if (apiKey != null) {
        merged['apikey'] = apiKey;
        merged['Authorization'] = 'Bearer $apiKey';
      }
    }

    return merged.isEmpty ? null : merged;
  }

  String? _resolveApiKey() {
    final apiKey = _client.functions.headers['apikey']?.trim();
    if (apiKey == null || apiKey.isEmpty) {
      return null;
    }
    return apiKey;
  }

  Future<bool> _tryRefreshSession() async {
    final session = _client.auth.currentSession;
    if (session == null) {
      return false;
    }

    try {
      final refreshed = await _client.auth.refreshSession();
      return refreshed.session != null;
    } catch (_) {
      return false;
    }
  }

  bool _looksAuthFailure(Object error) {
    final text = error.toString().toLowerCase();
    return text.contains('401') &&
        (text.contains('invalid jwt') ||
            text.contains('missing authorization header') ||
            text.contains('unauthorized'));
  }

  List<Map<String, dynamic>> _readItems(dynamic raw) {
    if (raw is! List) {
      return const <Map<String, dynamic>>[];
    }

    final output = <Map<String, dynamic>>[];

    for (final item in raw) {
      if (item is Map<String, dynamic>) {
        output.add(item);
        continue;
      }

      if (item is Map) {
        output.add(
          item.map(
            (key, value) => MapEntry(key.toString(), value),
          ),
        );
      }
    }

    return List<Map<String, dynamic>>.unmodifiable(output);
  }

  Map<String, dynamic> _asStringDynamicMap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return raw;
    }

    if (raw is Map) {
      return raw.map(
        (key, value) => MapEntry(key.toString(), value),
      );
    }

    return const <String, dynamic>{};
  }

  Object? _readErrorPayload(Map<String, dynamic> payload) {
    final error = payload['error'];
    if (error != null) {
      return error;
    }

    final message = payload['message'];
    if (message != null) {
      return message;
    }

    return null;
  }

  bool? _readBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    final normalized = value?.toString().trim().toLowerCase();
    switch (normalized) {
      case 'true':
      case '1':
        return true;
      case 'false':
      case '0':
        return false;
      default:
        return null;
    }
  }

  int? _readInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '');
  }

  bool _looksRateLimited(Object error) {
    final text = error.toString().toLowerCase();
    return text.contains('429') ||
        text.contains('rate limit') ||
        text.contains('ratelimit') ||
        text.contains('too many requests');
  }

  int? _extractStatusCode(Object error) {
    final text = error.toString();
    final match = RegExp(r'\b([1-5]\d{2})\b').firstMatch(text);
    if (match == null) {
      return null;
    }
    return int.tryParse(match.group(1)!);
  }
}