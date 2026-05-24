class FamilyMember {
  final String name;
  final String role;
  final String nikMasked;
  final bool isEligible;
  final bool isRegisteredBuyer;

  const FamilyMember({
    required this.name,
    required this.role,
    required this.nikMasked,
    required this.isEligible,
    this.isRegisteredBuyer = false,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      name: json['name'] as String,
      role: json['role'] as String? ?? 'Anggota KK',
      nikMasked: json['nik_masked'] as String? ?? '-',
      isEligible: json['is_verified'] as bool? ?? false,
      isRegisteredBuyer: json['is_registered_buyer'] as bool? ?? false,
    );
  }
}

class FamilyVehicleHolder {
  final String buyerProfileId;
  final String name;
  final String nikMasked;

  const FamilyVehicleHolder({
    required this.buyerProfileId,
    required this.name,
    required this.nikMasked,
  });

  factory FamilyVehicleHolder.fromJson(Map<String, dynamic> json) {
    return FamilyVehicleHolder(
      buyerProfileId: json['buyer_profile_id'] as String,
      name: json['name'] as String,
      nikMasked: json['nik_masked'] as String? ?? '-',
    );
  }
}

class FamilyVehicle {
  final String ownershipId;
  final String vehicleId;
  final String plateNumber;
  final String typeLabel;
  final String usageType;
  final String category;
  final List<FamilyVehicleHolder> holders;

  const FamilyVehicle({
    required this.ownershipId,
    required this.vehicleId,
    required this.plateNumber,
    required this.typeLabel,
    required this.usageType,
    required this.category,
    required this.holders,
  });

  factory FamilyVehicle.fromJson(Map<String, dynamic> json) {
    return FamilyVehicle(
      ownershipId: json['ownership_id'] as String,
      vehicleId: json['vehicle_id'] as String,
      plateNumber: json['plate_number'] as String,
      typeLabel: json['type_label'] as String,
      usageType: json['usage_type'] as String? ?? 'PERSONAL',
      category: json['category'] as String? ?? 'nonCommercial',
      holders: (json['holders'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(FamilyVehicleHolder.fromJson)
          .toList(),
    );
  }
}

class FamilyOverview {
  final List<FamilyMember> members;
  final List<FamilyVehicle> vehicles;

  const FamilyOverview({
    required this.members,
    required this.vehicles,
  });

  factory FamilyOverview.fromJson(Map<String, dynamic> json) {
    return FamilyOverview(
      members: (json['members'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(FamilyMember.fromJson)
          .toList(),
      vehicles: (json['vehicles'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(FamilyVehicle.fromJson)
          .toList(),
    );
  }
}
