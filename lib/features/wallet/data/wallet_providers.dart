import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/wallet.dart';
import '../../../shared/models/wallet_transaction.dart';
import 'wallet_api_repository.dart';

final walletApiRepositoryProvider = Provider<WalletApiRepository>((ref) {
  return WalletApiRepository();
});

final walletProvider = FutureProvider<WalletSummary>((ref) async {
  return ref.read(walletApiRepositoryProvider).fetchWallet();
});

final walletTransactionsProvider = FutureProvider<List<WalletTransaction>>((ref) async {
  final repository = ref.read(walletApiRepositoryProvider);
  final result = await repository.fetchTransactions(page: 1, size: 5);
  final List<dynamic> itemsRaw = result['items'] as List<dynamic>? ?? [];
  return itemsRaw
      .map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
      .toList();
});
