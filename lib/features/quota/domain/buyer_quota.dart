class BuyerQuotaResponse {
  final PersonalQuotaDetail personalQuota;
  final List<SubsidizedFuel> subsidizedFuels;
  final List<VehicleQuotaDetail> vehicles;

  BuyerQuotaResponse({
    required this.personalQuota,
    required this.subsidizedFuels,
    required this.vehicles,
  });

  factory BuyerQuotaResponse.fromJson(Map<String, dynamic> json) {
    return BuyerQuotaResponse(
      personalQuota: PersonalQuotaDetail.fromJson(json['personal_quota']),
      subsidizedFuels: (json['subsidized_fuels'] as List)
          .map((e) => SubsidizedFuel.fromJson(e))
          .toList(),
      vehicles: (json['vehicles'] as List)
          .map((e) => VehicleQuotaDetail.fromJson(e))
          .toList(),
    );
  }
}

class PersonalQuotaDetail {
  final int month;
  final int year;
  final double quotaLiters;
  final double usedLiters;
  final double remainingLiters;

  PersonalQuotaDetail({
    required this.month,
    required this.year,
    required this.quotaLiters,
    required this.usedLiters,
    required this.remainingLiters,
  });

  factory PersonalQuotaDetail.fromJson(Map<String, dynamic> json) {
    return PersonalQuotaDetail(
      month: json['month'],
      year: json['year'],
      quotaLiters: (json['quota_liters'] as num).toDouble(),
      usedLiters: (json['used_liters'] as num).toDouble(),
      remainingLiters: (json['remaining_liters'] as num).toDouble(),
    );
  }

  double get progress => quotaLiters == 0 ? 0.0 : (quotaLiters - remainingLiters) / quotaLiters;

  String get periodLabel {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    if (month >= 1 && month <= 12) {
      return '${months[month - 1]} $year';
    }
    return '$month/$year';
  }
}

class SubsidizedFuel {
  final String id;
  final String name;
  final double pricePerLiter;
  final double? subsidyPricePerLiter;

  SubsidizedFuel({
    required this.id,
    required this.name,
    required this.pricePerLiter,
    this.subsidyPricePerLiter,
  });

  factory SubsidizedFuel.fromJson(Map<String, dynamic> json) {
    return SubsidizedFuel(
      id: json['id'],
      name: json['name'],
      pricePerLiter: (json['price_per_liter'] as num).toDouble(),
      subsidyPricePerLiter: json['subsidy_price_per_liter'] != null
          ? (json['subsidy_price_per_liter'] as num).toDouble()
          : null,
    );
  }
}

class VehicleQuotaDetail {
  final String id;
  final String plateNumber;
  final String brand;
  final double totalLitersPurchased;

  VehicleQuotaDetail({
    required this.id,
    required this.plateNumber,
    required this.brand,
    required this.totalLitersPurchased,
  });

  factory VehicleQuotaDetail.fromJson(Map<String, dynamic> json) {
    return VehicleQuotaDetail(
      id: json['id'],
      plateNumber: json['plate_number'],
      brand: json['brand'],
      totalLitersPurchased: (json['total_liters_purchased'] as num).toDouble(),
    );
  }
}
