import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';

class Report {
  final String? id;
  final TargetRef target;
  final String userId;
  final String reason;
  final DateTime createdAt;

  const Report({
    this.id,
    required this.target,
    required this.userId,
    required this.reason,
    required this.createdAt,
  });

  Report copyWith({
    String? id,
    TargetRef? target,
    String? userId,
    String? reason,
    DateTime? createdAt,
  }) {
    return Report(
      id: id ?? this.id,
      target: target ?? this.target,
      userId: userId ?? this.userId,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}