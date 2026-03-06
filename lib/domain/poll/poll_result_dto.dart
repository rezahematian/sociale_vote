class PollResultDTO {
  final String optionId;
  final int votes;

  const PollResultDTO({
    required this.optionId,
    required this.votes,
  });

  factory PollResultDTO.fromJson(Map<String, dynamic> json) {
    return PollResultDTO(
      optionId: json['option_id'],
      votes: json['votes'],
    );
  }
}
