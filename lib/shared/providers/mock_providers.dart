import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/mock_api.dart';
import '../../features/risk/data/risk_repository.dart';
import '../models/family_member.dart';
import '../models/quota.dart';
import '../models/transaction.dart';
import '../models/user_profile.dart';
import '../models/vehicle.dart';
import '../../features/profile/data/profile_repository.dart';
import '../../features/risk/domain/risk_state.dart';

final mockApiProvider = Provider<MockApi>((ref) => MockApi());

final profileRepositoryProvider = Provider<ProfileRepository>((ref) => ProfileRepository());

final profileProvider = FutureProvider<UserProfile>((ref) async {
  final state = await ref.read(profileRepositoryProvider).fetchProfile();
  return state.profile;
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



final riskRepositoryProvider = Provider<RiskRepository>((ref) => RiskRepository());

final riskProvider = FutureProvider<RiskState>((ref) async {
  return ref.read(riskRepositoryProvider).fetchRisk();
});
