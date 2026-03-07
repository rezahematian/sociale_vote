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
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
      status: json['status'],
      options: (json['options'] as List)
          .map((o) => PollOptionDto.fromJson(o))
          .toList(),
      minSelections: json['minSelections'],
      maxSelections: json['maxSelections'],
      participationScope: json['participationScope'] ?? 'everyone',
      participationCountryCode: json['participationCountryCode'],
      countryCode: json['countryCode'],
      cityId: json['cityId'],
      createdByUserId: json['createdByUserId'],
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

class PollOptionDto {
  final String id;
  final String label;

  PollOptionDto({
    required this.id,
    required this.label,
  });

  factory PollOptionDto.fromJson(Map<String, dynamic> json) {
    return PollOptionDto(
      id: json['id'],
      label: json['label'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
    };
  }
}