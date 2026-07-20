import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'package:sociale_vote/domain/geo/repositories/device_location_repository.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location_source.dart';

class DeviceLocationRepositoryImpl implements DeviceLocationRepository {
  static const String _reverseGeocodingBaseUrl =
      'https://nominatim.openstreetmap.org/reverse';
  static const String _userAgent = 'sociale_vote/1.0';
  static const Duration _reverseGeocodingTimeout = Duration(seconds: 8);

  const DeviceLocationRepositoryImpl();

  @override
  Future<bool> isLocationServiceEnabled() async {
    return Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<bool> hasPermission() async {
    final permission = await Geolocator.checkPermission();

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  @override
  Future<bool> requestPermission() async {
    final current = await Geolocator.checkPermission();

    if (current == LocationPermission.always ||
        current == LocationPermission.whileInUse) {
      return true;
    }

    if (current == LocationPermission.deniedForever) {
      return false;
    }

    final requested = await Geolocator.requestPermission();

    return requested == LocationPermission.always ||
        requested == LocationPermission.whileInUse;
  }

  @override
  Future<ContentLocation?> getCurrentContentLocation() async {
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    final permitted = await requestPermission();
    if (!permitted) {
      return null;
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    var resolved = await _reverseGeocodeWithPlatformPlugin(
      latitude: position.latitude,
      longitude: position.longitude,
    );

    resolved ??= await _reverseGeocodeWithHttp(
      latitude: position.latitude,
      longitude: position.longitude,
    );

    final countryCode = resolved?.countryCode;
    final cityName = resolved?.cityName;

    return ContentLocation(
      source: ContentLocationSource.device,
      countryCode: countryCode,
      cityId: cityName,
      cityName: cityName,
      centerLat: position.latitude,
      centerLng: position.longitude,
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  Future<_ResolvedAddress?> _reverseGeocodeWithPlatformPlugin({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isEmpty) {
        return null;
      }

      final placemark = placemarks.first;
      final countryCode = _normalizeCountryCode(placemark.isoCountryCode);
      final cityName = _firstNonEmpty([
        placemark.locality,
        placemark.subLocality,
        placemark.subAdministrativeArea,
        placemark.administrativeArea,
      ]);

      if (countryCode == null && cityName == null) {
        return null;
      }

      return _ResolvedAddress(
        countryCode: countryCode,
        cityName: cityName,
      );
    } catch (_) {
      return null;
    }
  }

  Future<_ResolvedAddress?> _reverseGeocodeWithHttp({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final uri = Uri.parse(_reverseGeocodingBaseUrl).replace(
        queryParameters: <String, String>{
          'format': 'jsonv2',
          'lat': latitude.toString(),
          'lon': longitude.toString(),
          'zoom': '18',
          'addressdetails': '1',
          'accept-language': 'it,en',
        },
      );

      final response = await http.get(
        uri,
        headers: const <String, String>{
          'User-Agent': _userAgent,
          'Accept': 'application/json',
        },
      ).timeout(_reverseGeocodingTimeout);

      if (response.statusCode != 200) {
        return null;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        return null;
      }

      final rawAddress = decoded['address'];
      if (rawAddress is! Map) {
        return null;
      }

      final address = rawAddress.map(
        (key, value) => MapEntry(key.toString(), value),
      );

      final countryCode = _normalizeCountryCode(
        address['country_code']?.toString(),
      );

      final cityName = _firstNonEmpty([
        address['city']?.toString(),
        address['town']?.toString(),
        address['village']?.toString(),
        address['municipality']?.toString(),
        address['county']?.toString(),
        address['state_district']?.toString(),
        address['suburb']?.toString(),
        address['state']?.toString(),
      ]);

      if (countryCode == null && cityName == null) {
        return null;
      }

      return _ResolvedAddress(
        countryCode: countryCode,
        cityName: cityName,
      );
    } catch (_) {
      return null;
    }
  }

  String? _normalizeCountryCode(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    return normalized.toUpperCase();
  }

  String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      final normalized = value?.trim();
      if (normalized != null && normalized.isNotEmpty) {
        return normalized;
      }
    }

    return null;
  }
}

class _ResolvedAddress {
  final String? countryCode;
  final String? cityName;

  const _ResolvedAddress({
    required this.countryCode,
    required this.cityName,
  });
}
