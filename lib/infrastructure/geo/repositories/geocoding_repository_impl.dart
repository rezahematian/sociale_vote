import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:sociale_vote/domain/geo/repositories/geocoding_repository.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location.dart';

class GeocodingRepositoryImpl implements GeocodingRepository {
  static const String _defaultBaseUrl = 'https://nominatim.openstreetmap.org';
  static const String _defaultUserAgent = 'sociale_vote/1.0';

  final http.Client _httpClient;
  final String _baseUrl;
  final String _userAgent;
  final Duration _timeout;

  const GeocodingRepositoryImpl({
    http.Client? httpClient,
    String baseUrl = _defaultBaseUrl,
    String userAgent = _defaultUserAgent,
    Duration timeout = const Duration(seconds: 8),
  })  : _httpClient = httpClient ?? const _DefaultHttpClient(),
        _baseUrl = baseUrl,
        _userAgent = userAgent,
        _timeout = timeout;

  @override
  Future<ContentLocation?> geocodeContentLocation(
    ContentLocation location,
  ) async {
    if (location.isEmpty) {
      return null;
    }

    if (location.hasExactPoint || location.hasCenter) {
      return location;
    }

    final requests = _buildRequests(location);

    for (final request in requests) {
      final resolved = await _search(
        queryParameters: request,
        seed: location,
      );

      if (resolved != null) {
        return resolved;
      }
    }

    return null;
  }

  List<Map<String, String>> _buildRequests(ContentLocation location) {
    final cityName = _normalize(location.cityName);
    final countryCode = _normalize(location.countryCode)?.toLowerCase();
    final countryName = _countryNameFromCode(countryCode);

    final requests = <Map<String, String>>[];

    Map<String, String> baseParams() {
      return <String, String>{
        'format': 'jsonv2',
        'limit': '1',
        'addressdetails': '1',
        'accept-language': 'it,en',
      };
    }

    if (cityName != null && countryCode != null) {
      final structured = baseParams()
        ..['city'] = cityName
        ..['countrycodes'] = countryCode;
      requests.add(structured);

      final freeFormWithCountryName = baseParams()
        ..['q'] = countryName != null ? '$cityName, $countryName' : '$cityName, ${countryCode.toUpperCase()}'
        ..['countrycodes'] = countryCode;
      requests.add(freeFormWithCountryName);

      final freeFormCityOnlyWithCountryFilter = baseParams()
        ..['q'] = cityName
        ..['countrycodes'] = countryCode;
      requests.add(freeFormCityOnlyWithCountryFilter);
    }

    if (cityName != null && countryCode == null) {
      final freeFormCityOnly = baseParams()..['q'] = cityName;
      requests.add(freeFormCityOnly);
    }

    if (countryCode != null) {
      final countrySearch = baseParams()
        ..['featureType'] = 'country'
        ..['countrycodes'] = countryCode
        ..['q'] = countryName ?? countryCode.toUpperCase();
      requests.add(countrySearch);
    }

    return _dedupeRequests(requests);
  }

  List<Map<String, String>> _dedupeRequests(
    List<Map<String, String>> requests,
  ) {
    final seen = <String>{};
    final output = <Map<String, String>>[];

    for (final request in requests) {
      final sortedKeys = request.keys.toList()..sort();
      final signature = sortedKeys
          .map((key) => '$key=${request[key]}')
          .join('&');

      if (seen.add(signature)) {
        output.add(request);
      }
    }

    return output;
  }

  Future<ContentLocation?> _search({
    required Map<String, String> queryParameters,
    required ContentLocation seed,
  }) async {
    final uri = Uri.parse('$_baseUrl/search').replace(
      queryParameters: queryParameters,
    );

    final response = await _httpClient
        .get(
          uri,
          headers: <String, String>{
            'User-Agent': _userAgent,
            'Accept': 'application/json',
          },
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      return null;
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List || decoded.isEmpty) {
      return null;
    }

    final first = decoded.first;
    if (first is! Map<String, dynamic>) {
      return null;
    }

    final lat = _toDouble(first['lat']);
    final lon = _toDouble(first['lon']);

    if (!_isValidLatLng(lat, lon)) {
      return null;
    }

    final address = first['address'];
    String? resolvedCountryCode = seed.countryCode;
    String? resolvedCityName = seed.cityName;

    if (address is Map<String, dynamic>) {
      resolvedCountryCode =
          _normalize(address['country_code']?.toString())?.toUpperCase() ??
              seed.countryCode;

      resolvedCityName = _firstNonEmpty([
            address['city']?.toString(),
            address['town']?.toString(),
            address['village']?.toString(),
            address['municipality']?.toString(),
            address['county']?.toString(),
            address['state_district']?.toString(),
          ]) ??
          seed.cityName;
    }

    return seed.copyWith(
      countryCode: resolvedCountryCode,
      cityName: resolvedCityName,
      centerLat: lat,
      centerLng: lon,
      latitude: lat,
      longitude: lon,
    );
  }

  String? _countryNameFromCode(String? countryCode) {
    if (countryCode == null || countryCode.isEmpty) {
      return null;
    }

    switch (countryCode.toUpperCase()) {
      case 'IT':
        return 'Italy';
      case 'US':
        return 'United States';
      case 'GB':
      case 'UK':
        return 'United Kingdom';
      case 'FR':
        return 'France';
      case 'DE':
        return 'Germany';
      case 'ES':
        return 'Spain';
      case 'PT':
        return 'Portugal';
      case 'NL':
        return 'Netherlands';
      case 'BE':
        return 'Belgium';
      case 'CH':
        return 'Switzerland';
      case 'AT':
        return 'Austria';
      case 'AU':
        return 'Australia';
      case 'CA':
        return 'Canada';
      default:
        return null;
    }
  }

  String? _normalize(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return trimmed;
  }

  String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      final normalized = _normalize(value);
      if (normalized != null) {
        return normalized;
      }
    }
    return null;
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  bool _isValidLatLng(double? lat, double? lng) {
    if (lat == null || lng == null) return false;
    if (!lat.isFinite || !lng.isFinite) return false;
    if (lat < -90 || lat > 90) return false;
    if (lng < -180 || lng > 180) return false;
    return true;
  }
}

class _DefaultHttpClient implements http.Client {
  const _DefaultHttpClient();

  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) {
    return http.get(url, headers: headers);
  }

  @override
  void close() {}

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
