import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/mock_api.dart';
import '../models/family_member.dart';
import '../models/quota.dart';
import '../models/transaction.dart';
import '../models/user_profile.dart';
import '../models/vehicle.dart';
import '../models/wallet.dart';
import '../../features/risk/domain/risk_state.dart';

final mockApiProvider = Provider<MockApi>((ref) => MockApi());

final profileProvider = FutureProvider<UserProfile>((ref) async {
  return ref.read(mockApiProvider).fetchProfile();
});

final quotaProvider = FutureProvider<Quota>((ref) async {
  return ref.read(mockApiProvider).fetchQuota();
});

final vehiclesProvider = FutureProvider<List<Vehicle>>((ref) async {
  return ref.read(mockApiProvider).fetchVehicles();
});

final familyProvider = FutureProvider<List<FamilyMember>>((ref) async {
  return ref.read(mockApiProvider).fetchFamilyMembers();
});

final transactionsProvider = FutureProvider<List<TransactionItem>>((ref) async {
  return ref.read(mockApiProvider).fetchTransactions();
});

final walletProvider = FutureProvider<WalletSummary>((ref) async {
  return ref.read(mockApiProvider).fetchWallet();
});

final riskProvider = FutureProvider<RiskState>((ref) async {
  return ref.read(mockApiProvider).fetchRiskStatus();
});
