import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'package:sociale_vote/domain/geo/repositories/device_location_repository.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location_source.dart';

class DeviceLocationRepositoryImpl implements DeviceLocationRepository {
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

    String? countryCode;
    String? cityName;
    double? centerLat = position.latitude;
    double? centerLng = position.longitude;

    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;

        final isoCountryCode = placemark.isoCountryCode?.trim();
        final locality = placemark.locality?.trim();
        final subAdministrativeArea =
            placemark.subAdministrativeArea?.trim();
        final administrativeArea = placemark.administrativeArea?.trim();

        countryCode = (isoCountryCode != null && isoCountryCode.isNotEmpty)
            ? isoCountryCode
            : null;

        cityName = _firstNonEmpty([
          locality,
          subAdministrativeArea,
          administrativeArea,
        ]);
      }
    } catch (_) {
      // Se reverse geocoding fallisce, restituiamo comunque il punto GPS.
    }

    return ContentLocation(
      source: ContentLocationSource.device,
      countryCode: countryCode,
      cityName: cityName,
      centerLat: centerLat,
      centerLng: centerLng,
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      if (value != null && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }
}
