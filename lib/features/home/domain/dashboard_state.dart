import '../../../shared/models/quota.dart';

class DashboardState {
  final String userName;
  final bool isEligible;
  final Quota quota;
  final int riskScore;
  final List<String> fuelTypes;

  const DashboardState({
    required this.userName,
    required this.isEligible,
    required this.quota,
    required this.riskScore,
    required this.fuelTypes,
  });
}
