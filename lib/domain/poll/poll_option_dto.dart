class PollOptionDto {
  final String id;
  final String label;
  final int votes;

  const PollOptionDto({
    required this.id,
    required this.label,
    required this.votes,
  });

  factory PollOptionDto.fromJson(Map<String, dynamic> json) {
    return PollOptionDto(
      id: json['id'] as String,
      label: json['label'] as String,
      votes: json['votes'] as int? ?? 0,
    );
  }
}
