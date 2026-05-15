import '../../../core/services/mock_api.dart';
import '../domain/wallet_state.dart';

class WalletRepository {
  final MockApi api;

  WalletRepository(this.api);

  Future<WalletState> fetchWallet() async {
    final summary = await api.fetchWallet();
    return WalletState(summary: summary);
  }
}
