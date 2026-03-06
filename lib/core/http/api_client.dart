import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;

import 'package:sociale_vote/core/http/api_exception.dart';

/// Client HTTP centralizzato dell’app.
///
/// Responsabilità:
/// - costruire le URL partendo da [baseUrl]
/// - aggiungere header comuni
/// - decodificare JSON
/// - mappare errori HTTP in [ApiException]
/// - gestire retry minimo per GET
/// - supportare caching minimo opzionale per GET
class ApiClient {
  final String baseUrl;
  final http.Client _http;

  /// Numero massimo di retry extra per le richieste GET
  /// in caso di errori di rete/transienti.
  static const int _maxGetRetries = 1;

  /// Cache in-memory minimale per le GET.
  /// Key = uri.toString()
  final Map<String, dynamic> _getCache = {};

  ApiClient({
    required this.baseUrl,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  Uri _buildUri(String path, [Map<String, String>? query]) {
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath =
        path.startsWith('/') ? path.substring(1) : path;

    return Uri.parse('$normalizedBase/$normalizedPath')
        .replace(queryParameters: query);
  }

  Map<String, String> _mergeHeaders(
    Map<String, String>? headers,
  ) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?headers,
    };
  }

  /// GET JSON con:
  /// - retry minimo (1 retry) su errori di rete
  /// - caching opzionale in-memory (se [useCache] = true)
  Future<dynamic> getJson(
    String path, {
    Map<String, String>? query,
    Map<String, String>? headers,
    bool useCache = false,
  }) async {
    final uri = _buildUri(path, query);
    final cacheKey = uri.toString();

    if (useCache && _getCache.containsKey(cacheKey)) {
      return _getCache[cacheKey];
    }

    final result = await _sendWithRetry(
      () => _http.get(
        uri,
        headers: _mergeHeaders(headers),
      ),
      enableRetry: true,
    );

    if (useCache) {
      _getCache[cacheKey] = result;
    }

    return result;
  }

  Future<dynamic> postJson(
    String path, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path);
    final encodedBody = body == null ? null : jsonEncode(body);

    return _sendWithRetry(
      () => _http.post(
        uri,
        headers: _mergeHeaders(headers),
        body: encodedBody,
      ),
      enableRetry: false, // POST non idempotente → niente retry
    );
  }

  Future<dynamic> putJson(
    String path, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path);
    final encodedBody = body == null ? null : jsonEncode(body);

    return _sendWithRetry(
      () => _http.put(
        uri,
        headers: _mergeHeaders(headers),
        body: encodedBody,
      ),
      enableRetry: false,
    );
  }

  Future<dynamic> deleteJson(
    String path, {
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path);

    return _sendWithRetry(
      () => _http.delete(
        uri,
        headers: _mergeHeaders(headers),
      ),
      enableRetry: false,
    );
  }

  /// Wrapper che:
  /// - esegue la richiesta HTTP
  /// - applica retry minimo (solo se [enableRetry] = true)
  /// - centralizza la gestione errori (rete + HTTP status)
  Future<dynamic> _sendWithRetry(
    Future<http.Response> Function() send, {
    required bool enableRetry,
  }) async {
    int attempt = 0;

    while (true) {
      try {
        final response = await send();
        return _handleResponse(response);
      } on ApiException {
        // Errori HTTP già normalizzati → niente retry, li propaghiamo.
        rethrow;
      } catch (error) {
        // Errori di rete / client.
        if (enableRetry && attempt < _maxGetRetries) {
          attempt++;
          continue;
        }

        // Normalizziamo comunque in ApiException.
        throw ApiException(
          message: 'Network error',
          details: error.toString(),
        );
      }
    }
  }

  dynamic _handleResponse(http.Response response) {
    final status = response.statusCode;
    final body = response.body;

    dynamic decoded;
    if (body.isNotEmpty) {
      try {
        decoded = jsonDecode(body);
      } catch (_) {
        decoded = body;
      }
    }

    if (status >= 200 && status < 300) {
      // 204/205 → nessun contenuto
      if (status == 204 || status == 205) {
        return null;
      }
      // Successo: ritorniamo direttamente il payload (Map/List/String/...)
      return decoded;
    }

    // Errore HTTP → mappato in ApiException
    String message = 'HTTP $status';
    if (status == 400) {
      message = 'Bad request';
    } else if (status == 401) {
      message = 'Unauthorized';
    } else if (status == 403) {
      message = 'Forbidden';
    } else if (status == 404) {
      message = 'Not found';
    } else if (status >= 500) {
      message = 'Server error ($status)';
    }

    throw ApiException(
      statusCode: status,
      message: message,
      details: decoded,
    );
  }

  /// Chiusura esplicita del client HTTP (se mai servirà).
  void dispose() {
    _http.close();
  }
}