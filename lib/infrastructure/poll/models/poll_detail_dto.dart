import 'poll_option_dto.dart';

class PollDetailDto {
  final String id;

  /// ID tecnico della città (rome, new_york, tokyo)
  final String locationId;

  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final List<PollOptionDto> options;
  final int totalVotes;

  const PollDetailDto({
    required this.id,
    required this.locationId,
    required this.title,
    required this.description,
    required this.createdAt,
    this.expiresAt,
    required this.options,
    required this.totalVotes,
  });

  factory PollDetailDto.fromJson(Map<String, dynamic> json) {
    final optionsJson = json['options'] as List<dynamic>? ?? [];

    final options = optionsJson
        .map((e) => PollOptionDto.fromJson(e as Map<String, dynamic>))
        .toList();

    final totalVotes = options.fold<int>(0, (sum, o) => sum + o.votes);

    return PollDetailDto(
      id: json['id'] as String,
      locationId: json['locationId'] as String? ?? 'rome',
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : null,
      options: options,
      totalVotes: totalVotes,
    );
  }
}