import 'package:sociale_vote/domain/geo/value_objects/content_location_source.dart';

class ContentLocation {
  final ContentLocationSource source;
  final String? countryCode;
  final String? cityId;
  final String? cityName;
  final double? centerLat;
  final double? centerLng;
  final double? latitude;
  final double? longitude;

  const ContentLocation({
    required this.source,
    this.countryCode,
    this.cityId,
    this.cityName,
    this.centerLat,
    this.centerLng,
    this.latitude,
    this.longitude,
  });

  bool get hasCountry =>
      countryCode != null && countryCode!.trim().isNotEmpty;

  bool get hasCityId =>
      cityId != null && cityId!.trim().isNotEmpty;

  bool get hasCityName =>
      cityName != null && cityName!.trim().isNotEmpty;

  bool get hasCenter =>
      centerLat != null &&
      centerLng != null &&
      centerLat!.isFinite &&
      centerLng!.isFinite &&
      centerLat! >= -90 &&
      centerLat! <= 90 &&
      centerLng! >= -180 &&
      centerLng! <= 180;

  bool get hasExactPoint =>
      latitude != null &&
      longitude != null &&
      latitude!.isFinite &&
      longitude!.isFinite &&
      latitude! >= -90 &&
      latitude! <= 90 &&
      longitude! >= -180 &&
      longitude! <= 180;

  bool get isEmpty =>
      !hasCountry &&
      !hasCityId &&
      !hasCityName &&
      !hasCenter &&
      !hasExactPoint;

  ContentLocation copyWith({
    ContentLocationSource? source,
    String? countryCode,
    String? cityId,
    String? cityName,
    double? centerLat,
    double? centerLng,
    double? latitude,
    double? longitude,
  }) {
    return ContentLocation(
      source: source ?? this.source,
      countryCode: countryCode ?? this.countryCode,
      cityId: cityId ?? this.cityId,
      cityName: cityName ?? this.cityName,
      centerLat: centerLat ?? this.centerLat,
      centerLng: centerLng ?? this.centerLng,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source': source.name,
      'countryCode': countryCode,
      'cityId': cityId,
      'cityName': cityName,
      'centerLat': centerLat,
      'centerLng': centerLng,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory ContentLocation.fromJson(Map<String, dynamic> json) {
    final sourceName = json['source']?.toString();
    final source = ContentLocationSource.values.firstWhere(
      (value) => value.name == sourceName,
      orElse: () => ContentLocationSource.geoScopeFallback,
    );

    return ContentLocation(
      source: source,
      countryCode: json['countryCode']?.toString(),
      cityId: json['cityId']?.toString(),
      cityName: json['cityName']?.toString(),
      centerLat: _toDouble(json['centerLat']),
      centerLng: _toDouble(json['centerLng']),
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
