class Quota {
  final int monthlyQuota;
  final int remainingQuota;
  final String periodLabel;
  final List<String> fuelTypes;

  const Quota({
    required this.monthlyQuota,
    required this.remainingQuota,
    required this.periodLabel,
    required this.fuelTypes,
  });

  double get progress =>
      monthlyQuota == 0 ? 0 : (monthlyQuota - remainingQuota) / monthlyQuota;
}
