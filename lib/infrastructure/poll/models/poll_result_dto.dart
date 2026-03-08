class PollResultDto {
  final String optionId;
  final int votes;

  const PollResultDto({
    required this.optionId,
    required this.votes,
  });

  factory PollResultDto.fromJson(Map<String, dynamic> json) {
    return PollResultDto(
      optionId: json['option_id'] as String,
      votes: json['votes'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'option_id': optionId,
      'votes': votes,
    };
  }
}