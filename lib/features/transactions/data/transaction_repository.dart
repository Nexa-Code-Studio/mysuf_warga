import '../../../core/services/mock_api.dart';
import '../domain/transaction_state.dart';

class TransactionRepository {
  final MockApi api;

  TransactionRepository(this.api);

  Future<TransactionState> fetchTransactions() async {
    final items = await api.fetchTransactions();
    return TransactionState(items: items);
  }
}
