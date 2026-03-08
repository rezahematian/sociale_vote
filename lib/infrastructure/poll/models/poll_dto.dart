import 'poll_option_dto.dart';

class PollDto {
  final String id;
  final String title;
  final String? description;
  final String type;
  final String status;
  final List<PollOptionDto> options;
  final int minSelections;
  final int maxSelections;

  /// Scope di partecipazione (everyone / geoScopeOnly)
  final String participationScope;

  /// Country ISO 3166-1 alpha-2 per vincolo di partecipazione (opzionale)
  final String? participationCountryCode;

  final String? countryCode;
  final String? cityId;
  final String? createdByUserId;

  PollDto({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.status,
    required this.options,
    required this.minSelections,
    required this.maxSelections,
    required this.participationScope,
    this.participationCountryCode,
    this.countryCode,
    this.cityId,
    this.createdByUserId,
  });

  factory PollDto.fromJson(Map<String, dynamic> json) {
    return PollDto(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: json['type'] as String,
      status: json['status'] as String,
      options: (json['options'] as List<dynamic>)
          .map((o) => PollOptionDto.fromJson(o as Map<String, dynamic>))
          .toList(),
      minSelections: json['minSelections'] as int,
      maxSelections: json['maxSelections'] as int,
      participationScope: json['participationScope'] as String? ?? 'everyone',
      participationCountryCode: json['participationCountryCode'] as String?,
      countryCode: json['countryCode'] as String?,
      cityId: json['cityId'] as String?,
      createdByUserId: json['createdByUserId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'status': status,
      'options': options.map((o) => o.toJson()).toList(),
      'minSelections': minSelections,
      'maxSelections': maxSelections,
      'participationScope': participationScope,
      'participationCountryCode': participationCountryCode,
      'countryCode': countryCode,
      'cityId': cityId,
      'createdByUserId': createdByUserId,
    };
  }
}