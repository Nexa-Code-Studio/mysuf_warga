class UserProfile {
  final String name;
  final String nikMasked;
  final bool isVerified;
  final bool isEligible;
  final String familyCardNumber;
  final int vehiclesCount;
  final int quotaRemaining;
  final int walletBalance;

  const UserProfile({
    required this.name,
    required this.nikMasked,
    required this.isVerified,
    required this.isEligible,
    required this.familyCardNumber,
    required this.vehiclesCount,
    required this.quotaRemaining,
    required this.walletBalance,
  });
}
