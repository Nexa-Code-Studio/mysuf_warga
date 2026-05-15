import '../../../core/services/mock_api.dart';
import '../../../shared/models/quota.dart';
import '../domain/dashboard_state.dart';

class DashboardRepository {
  final MockApi api;

  DashboardRepository(this.api);

  Future<DashboardState> fetchDashboard() async {
    final quota = await api.fetchQuota();
    return DashboardState(
      userName: 'Budi Santoso',
      isEligible: true,
      quota: quota,
      riskScore: 72,
      fuelTypes: quota.fuelTypes,
    );
  }
}
