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
    httpClient,
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
    final placeName = _normalize(location.cityName);
    final countryCode = _normalize(location.countryCode)?.toLowerCase();
    final countryName = _countryNameFromCode(countryCode);

    final requests = <Map<String, String>>[];

    Map<String, String> baseParams() {
      return <String, String>{
        'format': 'jsonv2',
        'limit': '3',
        'addressdetails': '1',
        'accept-language': 'it,en',
      };
    }

    if (placeName != null && countryCode != null) {
      final structured = baseParams()
        ..['city'] = placeName
        ..['countrycodes'] = countryCode;
      requests.add(structured);

      final freeFormWithCountryName = baseParams()
        ..['q'] = countryName != null
            ? '$placeName, $countryName'
            : '$placeName, ${countryCode.toUpperCase()}'
        ..['countrycodes'] = countryCode;
      requests.add(freeFormWithCountryName);

      final freeFormPlaceOnlyWithCountryFilter = baseParams()
        ..['q'] = placeName
        ..['countrycodes'] = countryCode;
      requests.add(freeFormPlaceOnlyWithCountryFilter);
    }

    if (placeName != null && countryCode == null) {
      final freeFormPlaceOnly = baseParams()..['q'] = placeName;
      requests.add(freeFormPlaceOnly);
    }

    // Importante:
    // la ricerca "solo paese" va fatta SOLO se l'utente non ha inserito
    // una città. Altrimenti qualunque città inventata verrebbe accettata
    // grazie al match del solo paese.
    if (countryCode != null && placeName == null) {
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

    final selected = _selectBestResult(
      decoded: decoded,
      seed: seed,
    );
    if (selected == null) {
      return null;
    }

    // Se l'utente ha richiesto una città specifica, il risultato deve
    // matchare davvero una località coerente. Un match del solo paese
    // non è sufficiente.
    if (!_matchesRequestedCity(
      candidate: selected,
      seed: seed,
    )) {
      return null;
    }

    final lat = _toDouble(selected['lat']);
    final lon = _toDouble(selected['lon']);

    if (!_isValidLatLng(lat, lon)) {
      return null;
    }

    final address = _readAddress(selected);

    final resolvedCountryCode =
        _normalize(address?['country_code']?.toString())?.toUpperCase() ??
            seed.countryCode;

    final resolvedCityName = _firstNonEmpty([
          address?['city']?.toString(),
          address?['town']?.toString(),
          address?['village']?.toString(),
          address?['municipality']?.toString(),
          address?['county']?.toString(),
          address?['state_district']?.toString(),
        ]) ??
        seed.cityName;

    return seed.copyWith(
      countryCode: resolvedCountryCode,
      cityName: resolvedCityName,
      centerLat: lat,
      centerLng: lon,
      latitude: lat,
      longitude: lon,
    );
  }

  Map<String, dynamic>? _selectBestResult({
    required List decoded,
    required ContentLocation seed,
  }) {
    final candidates = decoded
        .whereType<Map>()
        .map(
          (row) => row.map(
            (key, value) => MapEntry(key.toString(), value),
          ),
        )
        .toList(growable: false);

    if (candidates.isEmpty) {
      return null;
    }

    Map<String, dynamic>? best;
    int? bestScore;

    for (final candidate in candidates) {
      final score = _scoreResult(
        candidate: candidate,
        seed: seed,
      );

      if (best == null || score > (bestScore ?? -999999)) {
        best = candidate;
        bestScore = score;
      }
    }

    if (best == null) {
      return null;
    }

    if ((bestScore ?? 0) <= 0) {
      return null;
    }

    return best;
  }

  int _scoreResult({
    required Map<String, dynamic> candidate,
    required ContentLocation seed,
  }) {
    var score = 0;

    final seedCountryCode = _normalize(seed.countryCode)?.toLowerCase();
    final seedPlaceName = _normalize(seed.cityName)?.toLowerCase();

    final address = _readAddress(candidate);
    final candidateCountryCode =
        _normalize(address?['country_code']?.toString())?.toLowerCase();
    final candidateLocality = _extractLocality(address)?.toLowerCase();
    final displayName = _normalize(candidate['display_name']?.toString())
        ?.toLowerCase();

    if (seedCountryCode != null) {
      if (candidateCountryCode == seedCountryCode) {
        score += 120;
      } else {
        score -= 150;
      }
    }

    if (seedPlaceName != null) {
      // Se l'utente ha indicato una città, un risultato che non matcha
      // affatto quella città non va considerato valido.
      if (candidateLocality == seedPlaceName) {
        score += 100;
      } else if (displayName != null && displayName.contains(seedPlaceName)) {
        score += 40;
      } else {
        return -1000;
      }
    }

    return score;
  }

  bool _matchesRequestedCity({
    required Map<String, dynamic> candidate,
    required ContentLocation seed,
  }) {
    final seedPlaceName = _normalize(seed.cityName)?.toLowerCase();
    if (seedPlaceName == null) {
      return true;
    }

    final address = _readAddress(candidate);
    final localityCandidates = [
      address?['city']?.toString(),
      address?['town']?.toString(),
      address?['village']?.toString(),
      address?['municipality']?.toString(),
      address?['county']?.toString(),
      address?['state_district']?.toString(),
      address?['suburb']?.toString(),
    ]
        .map((value) => _normalize(value)?.toLowerCase())
        .whereType<String>()
        .toList(growable: false);

    for (final locality in localityCandidates) {
      if (locality == seedPlaceName) {
        return true;
      }
    }

    final displayName =
        _normalize(candidate['display_name']?.toString())?.toLowerCase();

    if (displayName != null && displayName.contains(seedPlaceName)) {
      return true;
    }

    return false;
  }

  Map<String, dynamic>? _readAddress(Map<String, dynamic> row) {
    final address = row['address'];
    if (address is Map<String, dynamic>) {
      return address;
    }
    if (address is Map) {
      return address.map(
        (key, value) => MapEntry(key.toString(), value),
      );
    }
    return null;
  }

  String? _extractLocality(Map<String, dynamic>? address) {
    if (address == null) {
      return null;
    }

    return _firstNonEmpty([
      address['city']?.toString(),
      address['town']?.toString(),
      address['village']?.toString(),
      address['municipality']?.toString(),
      address['county']?.toString(),
      address['state_district']?.toString(),
    ]);
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
      case 'IR':
        return 'Iran';
      case 'IQ':
        return 'Iraq';
      case 'IL':
        return 'Israel';
      case 'PS':
        return 'Palestine';
      case 'UA':
        return 'Ukraine';
      case 'RU':
        return 'Russia';
      case 'CN':
        return 'China';
      case 'JP':
        return 'Japan';
      case 'IN':
        return 'India';
      case 'PK':
        return 'Pakistan';
      case 'TR':
        return 'Turkey';
      case 'EG':
        return 'Egypt';
      case 'SA':
        return 'Saudi Arabia';
      case 'AE':
        return 'United Arab Emirates';
      case 'BR':
        return 'Brazil';
      case 'MX':
        return 'Mexico';
      case 'AR':
        return 'Argentina';
      case 'ZA':
        return 'South Africa';
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