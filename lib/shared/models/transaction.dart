enum TransactionStatus { success, failed, pending }

class TransactionItem {
  final String title;
  final String subtitle;
  final String dateTimeLabel;
  final int amount;
  final TransactionStatus status;

  const TransactionItem({
    required this.title,
    required this.subtitle,
    required this.dateTimeLabel,
    required this.amount,
    required this.status,
  });
}
