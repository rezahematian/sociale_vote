import 'package:sociale_vote/domain/admin/entities/admin_entities.dart';
import 'package:sociale_vote/domain/admin/repositories/admin_repository.dart';

class LoadAdminDashboard {
  final AdminRepository _repository;

  const LoadAdminDashboard(this._repository);

  Future<AdminDashboardSummary> call() {
    return _repository.getDashboardSummary();
  }
}
