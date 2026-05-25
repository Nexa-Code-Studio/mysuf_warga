enum TransactionType {
  topUp('TOP_UP', 'Top Up Saldo'),
  fuelPurchase('FUEL_PURCHASE', 'Pembelian Bahan Bakar'),
  refund('REFUND', 'Pengembalian Dana'),
  adminAdjustment('ADMIN_ADJUSTMENT', 'Penyesuaian Admin');

  final String value;
  final String label;
  const TransactionType(this.value, this.label);

  static TransactionType fromValue(String value) {
    return TransactionType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TransactionType.topUp,
    );
  }
}

enum TransactionFlow {
  inflow('IN'),
  outflow('OUT');

  final String value;
  const TransactionFlow(this.value);

  static TransactionFlow fromValue(String value) {
    return TransactionFlow.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TransactionFlow.inflow,
    );
  }
}

enum WalletTransactionStatus {
  pending('PENDING', 'Menunggu'),
  success('SUCCESS', 'Berhasil'),
  failed('FAILED', 'Gagal');

  final String value;
  final String label;
  const WalletTransactionStatus(this.value, this.label);

  static WalletTransactionStatus fromValue(String value) {
    return WalletTransactionStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => WalletTransactionStatus.success,
    );
  }
}

class WalletTransaction {
  final String id;
  final String walletId;
  final TransactionType type;
  final TransactionFlow transactionFlow;
  final int amount;
  final int balanceBefore;
  final int balanceAfter;
  final String? counterpartyWalletId;
  final String? paymentTransactionId;
  final String? paymentMethod;
  final String? description;
  final WalletTransactionStatus status;
  final DateTime createdAt;
  final String? tileType;
  final String? fuelTypeName;
  final String? gasStationName;
  final double? liters;

  const WalletTransaction({
    required this.id,
    required this.walletId,
    required this.type,
    required this.transactionFlow,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    this.counterpartyWalletId,
    this.paymentTransactionId,
    this.paymentMethod,
    this.description,
    required this.status,
    required this.createdAt,
    this.tileType,
    this.fuelTypeName,
    this.gasStationName,
    this.liters,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    final rawAmount = json['amount'];
    int parsedAmount = 0;
    if (rawAmount is num) {
      parsedAmount = rawAmount.toInt();
    } else if (rawAmount is String) {
      parsedAmount = double.tryParse(rawAmount)?.toInt() ?? 0;
    }

    final rawBefore = json['balance_before'];
    int parsedBefore = 0;
    if (rawBefore is num) {
      parsedBefore = rawBefore.toInt();
    } else if (rawBefore is String) {
      parsedBefore = double.tryParse(rawBefore)?.toInt() ?? 0;
    }

    final rawAfter = json['balance_after'];
    int parsedAfter = 0;
    if (rawAfter is num) {
      parsedAfter = rawAfter.toInt();
    } else if (rawAfter is String) {
      parsedAfter = double.tryParse(rawAfter)?.toInt() ?? 0;
    }

    final rawLiters = json['liters'];
    double? parsedLiters;
    if (rawLiters is num) {
      parsedLiters = rawLiters.toDouble();
    } else if (rawLiters is String) {
      parsedLiters = double.tryParse(rawLiters);
    }

    return WalletTransaction(
      id: json['id'] as String? ?? '',
      walletId: json['wallet_id'] as String? ?? '',
      type: TransactionType.fromValue(json['type'] as String? ?? ''),
      transactionFlow: TransactionFlow.fromValue(json['transaction_flow'] as String? ?? ''),
      amount: parsedAmount,
      balanceBefore: parsedBefore,
      balanceAfter: parsedAfter,
      counterpartyWalletId: json['counterparty_wallet_id'] as String?,
      paymentTransactionId: json['payment_transaction_id'] as String?,
      paymentMethod: json['payment_method'] as String?,
      description: json['description'] as String?,
      status: WalletTransactionStatus.fromValue(json['status'] as String? ?? ''),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      tileType: json['tile_type'] as String?,
      fuelTypeName: json['fuel_type_name'] as String?,
      gasStationName: json['gas_station_name'] as String?,
      liters: parsedLiters,
    );
  }
}
