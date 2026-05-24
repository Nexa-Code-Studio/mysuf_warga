class WalletSummary {
  final int balance;
  final bool isActive;
  final String walletIdMasked;
  final String? nikMasked;
  final String? nik;

  const WalletSummary({
    required this.balance,
    required this.isActive,
    required this.walletIdMasked,
    this.nikMasked,
    this.nik,
  });

  factory WalletSummary.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] as String? ?? '';
    final maskedId = rawId.length > 4
        ? rawId.substring(rawId.length - 4).toUpperCase()
        : 'UNKNOWN';
        
    final rawBalance = json['balance'];
    int parsedBalance = 0;
    if (rawBalance is num) {
      parsedBalance = rawBalance.toInt();
    } else if (rawBalance is String) {
      parsedBalance = double.tryParse(rawBalance)?.toInt() ?? 0;
    }

    return WalletSummary(
      balance: parsedBalance,
      isActive: json['is_active'] as bool? ?? false,
      walletIdMasked: maskedId,
      nikMasked: json['nik_masked'] as String?,
      nik: json['nik'] as String?,
    );
  }
}
