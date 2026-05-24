import '../../../../shared/models/wallet_transaction.dart';

class VehicleVerificationHome {
  final bool hasVerifiedVehicle;
  final bool showVerifyVehicleCta;
  final String ctaRoute;

  const VehicleVerificationHome({
    required this.hasVerifiedVehicle,
    required this.showVerifyVehicleCta,
    required this.ctaRoute,
  });

  factory VehicleVerificationHome.fromJson(Map<String, dynamic> json) {
    return VehicleVerificationHome(
      hasVerifiedVehicle: json['has_verified_vehicle'] as bool? ?? false,
      showVerifyVehicleCta: json['show_verify_vehicle_cta'] as bool? ?? false,
      ctaRoute: json['cta_route'] as String? ?? '/vehicles/add',
    );
  }
}

class PersonalQuotaHome {
  final int month;
  final int year;
  final double quotaLiters;
  final double usedLiters;
  final double remainingLiters;

  const PersonalQuotaHome({
    required this.month,
    required this.year,
    required this.quotaLiters,
    required this.usedLiters,
    required this.remainingLiters,
  });

  factory PersonalQuotaHome.fromJson(Map<String, dynamic> json) {
    return PersonalQuotaHome(
      month: json['month'] as int? ?? 1,
      year: json['year'] as int? ?? 2026,
      quotaLiters: (json['quota_liters'] as num?)?.toDouble() ?? 0.0,
      usedLiters: (json['used_liters'] as num?)?.toDouble() ?? 0.0,
      remainingLiters: (json['remaining_liters'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class NearbyGasStationItem {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double distanceKm;

  const NearbyGasStationItem({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
  });

  factory NearbyGasStationItem.fromJson(Map<String, dynamic> json) {
    return NearbyGasStationItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class NearbyGasStationsHome {
  final bool locationAvailable;
  final String? message;
  final List<NearbyGasStationItem> items;

  const NearbyGasStationsHome({
    required this.locationAvailable,
    this.message,
    required this.items,
  });

  factory NearbyGasStationsHome.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return NearbyGasStationsHome(
      locationAvailable: json['location_available'] as bool? ?? false,
      message: json['message'] as String?,
      items: rawItems
          .map((e) => NearbyGasStationItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class RecentTransactionFuel {
  final String fuelTypeName;
  final String gasStationName;
  final double liters;

  const RecentTransactionFuel({
    required this.fuelTypeName,
    required this.gasStationName,
    required this.liters,
  });

  factory RecentTransactionFuel.fromJson(Map<String, dynamic> json) {
    return RecentTransactionFuel(
      fuelTypeName: json['fuel_type_name'] as String? ?? '',
      gasStationName: json['gas_station_name'] as String? ?? '',
      liters: (json['liters'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class RecentTransactionHome {
  final String id;
  final String tileType; // e.g. "FUEL", "TOP_UP", "TRANSFER"
  final String title;
  final String subtitle;
  final double amount;
  final TransactionFlow transactionFlow;
  final String status;
  final DateTime occurredAt;
  final RecentTransactionFuel? fuel;

  const RecentTransactionHome({
    required this.id,
    required this.tileType,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.transactionFlow,
    required this.status,
    required this.occurredAt,
    this.fuel,
  });

  factory RecentTransactionHome.fromJson(Map<String, dynamic> json) {
    final fuelJson = json['fuel'] as Map<String, dynamic>?;
    return RecentTransactionHome(
      id: json['id'] as String? ?? '',
      tileType: json['tile_type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      transactionFlow: TransactionFlow.fromValue(json['transaction_flow'] as String? ?? ''),
      status: json['status'] as String? ?? '',
      occurredAt: json['occurred_at'] != null
          ? DateTime.parse(json['occurred_at'] as String)
          : DateTime.now(),
      fuel: fuelJson != null ? RecentTransactionFuel.fromJson(fuelJson) : null,
    );
  }
}

class RiskStatusHome {
  final String verificationStatus; // e.g. "UNVERIFIED", "VERIFIED", "REJECTED"
  final double riskScore;

  const RiskStatusHome({
    required this.verificationStatus,
    required this.riskScore,
  });

  factory RiskStatusHome.fromJson(Map<String, dynamic> json) {
    return RiskStatusHome(
      verificationStatus: json['verification_status'] as String? ?? 'UNVERIFIED',
      riskScore: (json['risk_score'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class BuyerHome {
  final VehicleVerificationHome vehicleVerification;
  final PersonalQuotaHome personalQuota;
  final NearbyGasStationsHome nearbyGasStations;
  final List<RecentTransactionHome> recentTransactions;
  final RiskStatusHome riskStatus;

  const BuyerHome({
    required this.vehicleVerification,
    required this.personalQuota,
    required this.nearbyGasStations,
    required this.recentTransactions,
    required this.riskStatus,
  });

  factory BuyerHome.fromJson(Map<String, dynamic> json) {
    return BuyerHome(
      vehicleVerification: VehicleVerificationHome.fromJson(
        json['vehicle_verification'] as Map<String, dynamic>? ?? {},
      ),
      personalQuota: PersonalQuotaHome.fromJson(
        json['personal_quota'] as Map<String, dynamic>? ?? {},
      ),
      nearbyGasStations: NearbyGasStationsHome.fromJson(
        json['nearby_gas_stations'] as Map<String, dynamic>? ?? {},
      ),
      recentTransactions: (json['recent_transactions'] as List<dynamic>? ?? [])
          .map((e) => RecentTransactionHome.fromJson(e as Map<String, dynamic>))
          .toList(),
      riskStatus: RiskStatusHome.fromJson(
        json['risk_status'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}
