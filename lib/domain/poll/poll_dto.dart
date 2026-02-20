class PollDTO {
  final String id;
  final String title;
  final String description;
  final String scope;
  final DateTime endsAt;

  const PollDTO({
    required this.id,
    required this.title,
    required this.description,
    required this.scope,
    required this.endsAt,
  });

  factory PollDTO.fromJson(Map<String, dynamic> json) {
    return PollDTO(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      scope: json['scope'],
      endsAt: DateTime.parse(json['ends_at']),
    );
  }
}
