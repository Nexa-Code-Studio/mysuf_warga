import 'dart:math';

import '../../shared/models/family_member.dart';
import '../../shared/models/quota.dart';
import '../../shared/models/transaction.dart';
import '../../shared/models/user_profile.dart';
import '../../shared/models/vehicle.dart';
import '../../shared/models/wallet.dart';
import '../../features/risk/domain/risk_state.dart';

class MockApi {
  Future<UserProfile> fetchProfile() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return const UserProfile(
      name: 'Budi Santoso',
      nikMasked: '3171****0001',
      isVerified: true,
      isEligible: true,
      familyCardNumber: '3171010101000001',
      vehiclesCount: 2,
      quotaRemaining: 150,
      walletBalance: 1500000,
    );
  }

  Future<Quota> fetchQuota() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return const Quota(
      monthlyQuota: 300,
      remainingQuota: 150,
      periodLabel: 'Mei 2026',
      fuelTypes: ['Pertalite', 'Bio Solar'],
    );
  }

  Future<List<Vehicle>> fetchVehicles() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return const [
      Vehicle(
        plateNumber: 'B 1234 ABC',
        typeLabel: 'Roda 4 - Sedan',
        category: VehicleCategory.nonCommercial,
        isActive: true,
      ),
      Vehicle(
        plateNumber: 'B 9234 SFD',
        typeLabel: 'Roda 2 - Motor',
        category: VehicleCategory.nonCommercial,
        isActive: true,
      ),
    ];
  }

  Future<List<FamilyMember>> fetchFamilyMembers() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return const [
      FamilyMember(
        name: 'Budi Santoso',
        role: 'Kepala Keluarga',
        nikMasked: '3171****5001',
        isEligible: true,
      ),
      FamilyMember(
        name: 'Siti Rahayu',
        role: 'Istri',
        nikMasked: '3171****5002',
        isEligible: true,
      ),
      FamilyMember(
        name: 'Dimas Santoso',
        role: 'Anak',
        nikMasked: '3171****5003',
        isEligible: false,
      ),
    ];
  }

  Future<List<TransactionItem>> fetchTransactions() async {
    await Future<void>.delayed(const Duration(milliseconds: 420));
    return const [
      TransactionItem(
        title: 'SPBU 31.001 Sudirman',
        subtitle: 'Pertalite - 20 Liter',
        dateTimeLabel: '12 Mei 2026 - 08:45',
        amount: -30000,
        status: TransactionStatus.success,
      ),
      TransactionItem(
        title: 'Top Up Saldo',
        subtitle: 'Virtual Account BNI',
        dateTimeLabel: '11 Mei 2026 - 14:22',
        amount: 200000,
        status: TransactionStatus.success,
      ),
      TransactionItem(
        title: 'SPBU 34.101 Bekasi',
        subtitle: 'Bio Solar - 40 Liter',
        dateTimeLabel: '11 Mei 2026 - 09:10',
        amount: -64000,
        status: TransactionStatus.success,
      ),
      TransactionItem(
        title: 'SPBU 33.201 Depok',
        subtitle: 'Pertalite - 15 Liter',
        dateTimeLabel: '9 Mei 2026 - 17:30',
        amount: -22500,
        status: TransactionStatus.failed,
      ),
    ];
  }

  Future<WalletSummary> fetchWallet() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return const WalletSummary(
      balance: 1500000,
      isActive: true,
      walletIdMasked: '0001',
    );
  }

  Future<RiskState> fetchRiskStatus() async {
    await Future<void>.delayed(const Duration(milliseconds: 320));
    return const RiskState(
      score: 72,
      statusLabel: 'Dalam Review',
      statusLevel: RiskLevel.review,
      notes: [
        'Aktivitas pengisian BBM meningkat 20% minggu ini.',
        'Verifikasi data tambahan sedang diproses.',
      ],
    );
  }

  Future<int> submitOtp() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return Random().nextInt(899999) + 100000;
  }
}
