import 'package:sociale_vote/domain/admin/entities/admin_entities.dart';
import 'package:sociale_vote/domain/admin/repositories/admin_repository.dart';

class LoadAdminReports {
  static const int maximumLimit = 100;

  final AdminRepository _repository;

  const LoadAdminReports(this._repository);

  Future<AdminReportQueuePage> call({
    AdminReportStatus? status,
    AdminReportTargetType? targetType,
    int limit = 25,
    int offset = 0,
  }) {
    if (limit < 1 || limit > maximumLimit) {
      throw RangeError.range(
        limit,
        1,
        maximumLimit,
        'limit',
      );
    }

    if (offset < 0) {
      throw RangeError.value(
        offset,
        'offset',
      );
    }

    if (status == AdminReportStatus.unknown) {
      throw ArgumentError.value(
        status,
        'status',
      );
    }

    if (targetType == AdminReportTargetType.unknown) {
      throw ArgumentError.value(
        targetType,
        'targetType',
      );
    }

    return _repository.getReportQueue(
      status: status,
      targetType: targetType,
      limit: limit,
      offset: offset,
    );
  }
}
