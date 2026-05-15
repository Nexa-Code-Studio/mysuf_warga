import '../../../core/services/mock_api.dart';
import '../domain/risk_state.dart';

class RiskRepository {
  final MockApi api;

  RiskRepository(this.api);

  Future<RiskState> fetchRisk() async {
    return api.fetchRiskStatus();
  }
}
