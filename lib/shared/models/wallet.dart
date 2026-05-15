class WalletSummary {
  final int balance;
  final bool isActive;
  final String walletIdMasked;

  const WalletSummary({
    required this.balance,
    required this.isActive,
    required this.walletIdMasked,
  });
}
