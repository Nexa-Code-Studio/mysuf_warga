import '../../../core/services/mock_api.dart';
import '../domain/quota_state.dart';

class QuotaRepository {
  final MockApi api;

  QuotaRepository(this.api);

  Future<QuotaState> fetchQuota() async {
    final quota = await api.fetchQuota();
    return QuotaState(quota: quota);
  }
}
