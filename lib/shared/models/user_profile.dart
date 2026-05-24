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

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String? ?? '',
      nikMasked: json['nikMasked'] as String? ?? '',
      isVerified: json['isVerified'] as bool? ?? false,
      isEligible: json['isEligible'] as bool? ?? false,
      familyCardNumber: json['familyCardNumber'] as String? ?? '',
      vehiclesCount: json['vehiclesCount'] as int? ?? 0,
      quotaRemaining: json['quotaRemaining'] as int? ?? 0,
      walletBalance: json['walletBalance'] as int? ?? 0,
    );
  }
}
