enum VehicleCategory { nonCommercial, commercial }

VehicleCategory vehicleCategoryFromString(String value) {
  return value == 'commercial'
      ? VehicleCategory.commercial
      : VehicleCategory.nonCommercial;
}

double? _toDoubleOrNull(Object? value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse((value ?? '').toString());
}

class Vehicle {
  final String ownershipId;
  final String vehicleId;
  final String plateNumber;
  final String typeLabel;
  final VehicleCategory category;
  final bool isActive;
  final String usageType;
  final double? quotaLiters;
  final double? usedLiters;
  final double? remainingLiters;

  const Vehicle({
    required this.ownershipId,
    required this.vehicleId,
    required this.plateNumber,
    required this.typeLabel,
    required this.category,
    required this.isActive,
    required this.usageType,
    this.quotaLiters,
    this.usedLiters,
    this.remainingLiters,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      ownershipId: json['ownership_id'] as String,
      vehicleId: json['vehicle_id'] as String,
      plateNumber: json['plate_number'] as String,
      typeLabel: json['type_label'] as String,
      category: vehicleCategoryFromString(json['category'] as String? ?? ''),
      isActive: json['is_active'] as bool? ?? true,
      usageType: json['usage_type'] as String? ?? 'PERSONAL',
      quotaLiters: _toDoubleOrNull(json['quota_liters']),
      usedLiters: _toDoubleOrNull(json['used_liters']),
      remainingLiters: _toDoubleOrNull(json['remaining_liters']),
    );
  }
}

class VehicleDocument {
  final String id;
  final String documentType;
  final String storageKey;
  final String? originalFilename;
  final String? mimeType;

  const VehicleDocument({
    required this.id,
    required this.documentType,
    required this.storageKey,
    required this.originalFilename,
    required this.mimeType,
  });

  factory VehicleDocument.fromJson(Map<String, dynamic> json) {
    return VehicleDocument(
      id: json['id'] as String,
      documentType: json['document_type'] as String,
      storageKey: json['storage_key'] as String,
      originalFilename: json['original_filename'] as String?,
      mimeType: json['mime_type'] as String?,
    );
  }
}

class VehicleHolder {
  final String buyerProfileId;
  final String name;
  final String nikMasked;

  const VehicleHolder({
    required this.buyerProfileId,
    required this.name,
    required this.nikMasked,
  });

  factory VehicleHolder.fromJson(Map<String, dynamic> json) {
    return VehicleHolder(
      buyerProfileId: json['buyer_profile_id'] as String,
      name: json['name'] as String,
      nikMasked: json['nik_masked'] as String? ?? '-',
    );
  }
}

class VehicleDetail {
  final String ownershipId;
  final String vehicleId;
  final String plateNumber;
  final String statusLabel;
  final VehicleCategory category;
  final String registrationNumber;
  final String brand;
  final String vehicleType;
  final int manufactureYear;
  final String color;
  final int engineCapacityCc;
  final String pkb;
  final String njkb;
  final String? ownerName;
  final String? ownerNik;
  final String ownershipStatus;
  final String usageType;
  final String quotaMode;
  final double? quotaLiters;
  final double? usedLiters;
  final double? remainingLiters;
  final List<VehicleHolder> holdersInFamily;
  final List<VehicleDocument> documents;

  const VehicleDetail({
    required this.ownershipId,
    required this.vehicleId,
    required this.plateNumber,
    required this.statusLabel,
    required this.category,
    required this.registrationNumber,
    required this.brand,
    required this.vehicleType,
    required this.manufactureYear,
    required this.color,
    required this.engineCapacityCc,
    required this.pkb,
    required this.njkb,
    required this.ownerName,
    required this.ownerNik,
    required this.ownershipStatus,
    required this.usageType,
    required this.quotaMode,
    required this.quotaLiters,
    required this.usedLiters,
    required this.remainingLiters,
    required this.holdersInFamily,
    required this.documents,
  });

  factory VehicleDetail.fromJson(Map<String, dynamic> json) {
    final docs = (json['documents'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(VehicleDocument.fromJson)
        .toList();
    final holders = (json['holders_in_family'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(VehicleHolder.fromJson)
        .toList();

    return VehicleDetail(
      ownershipId: json['ownership_id'] as String,
      vehicleId: json['vehicle_id'] as String,
      plateNumber: json['plate_number'] as String,
      statusLabel: json['status_label'] as String,
      category: vehicleCategoryFromString(json['category'] as String? ?? ''),
      registrationNumber: json['registration_number'] as String,
      brand: json['brand'] as String,
      vehicleType: json['vehicle_type'] as String,
      manufactureYear: json['manufacture_year'] as int,
      color: json['color'] as String,
      engineCapacityCc: json['engine_capacity_cc'] as int,
      pkb: json['pkb'] as String,
      njkb: json['njkb'] as String,
      ownerName: json['owner_name'] as String?,
      ownerNik: json['owner_nik'] as String?,
      ownershipStatus: json['ownership_status'] as String,
      usageType: json['usage_type'] as String,
      quotaMode: json['quota_mode'] as String,
      quotaLiters: _toDoubleOrNull(json['quota_liters']),
      usedLiters: _toDoubleOrNull(json['used_liters']),
      remainingLiters: _toDoubleOrNull(json['remaining_liters']),
      holdersInFamily: holders,
      documents: docs,
    );
  }
}

class PendingVehicleRequest {
  final String requestId;
  final String plateNumber;
  final String registrationNumber;
  final String usageType;
  final String status;
  final DateTime submittedAt;
  final String? reviewNote;

  const PendingVehicleRequest({
    required this.requestId,
    required this.plateNumber,
    required this.registrationNumber,
    required this.usageType,
    required this.status,
    required this.submittedAt,
    required this.reviewNote,
  });

  factory PendingVehicleRequest.fromJson(Map<String, dynamic> json) {
    return PendingVehicleRequest(
      requestId: json['request_id'] as String,
      plateNumber: json['plate_number'] as String,
      registrationNumber: json['registration_number'] as String,
      usageType: json['usage_type'] as String? ?? 'PERSONAL',
      status: json['status'] as String? ?? 'PENDING',
      submittedAt: DateTime.parse(json['submitted_at'] as String),
      reviewNote: json['review_note'] as String?,
    );
  }
}

class PendingVehicleRequestDetail {
  final String requestId;
  final String vehicleId;
  final String plateNumber;
  final String registrationNumber;
  final String brand;
  final String vehicleType;
  final int manufactureYear;
  final String color;
  final int engineCapacityCc;
  final String pkb;
  final String njkb;
  final String? ownerName;
  final String? ownerNik;
  final String ownershipStatus;
  final String usageType;
  final String quotaMode;
  final String status;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String? reviewNote;
  final List<VehicleDocument> documents;

  const PendingVehicleRequestDetail({
    required this.requestId,
    required this.vehicleId,
    required this.plateNumber,
    required this.registrationNumber,
    required this.brand,
    required this.vehicleType,
    required this.manufactureYear,
    required this.color,
    required this.engineCapacityCc,
    required this.pkb,
    required this.njkb,
    required this.ownerName,
    required this.ownerNik,
    required this.ownershipStatus,
    required this.usageType,
    required this.quotaMode,
    required this.status,
    required this.submittedAt,
    required this.reviewedAt,
    required this.reviewNote,
    required this.documents,
  });

  factory PendingVehicleRequestDetail.fromJson(Map<String, dynamic> json) {
    final docs = (json['documents'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(VehicleDocument.fromJson)
        .toList();

    return PendingVehicleRequestDetail(
      requestId: json['request_id'] as String,
      vehicleId: json['vehicle_id'] as String,
      plateNumber: json['plate_number'] as String,
      registrationNumber: json['registration_number'] as String,
      brand: json['brand'] as String,
      vehicleType: json['vehicle_type'] as String,
      manufactureYear: json['manufacture_year'] as int,
      color: json['color'] as String,
      engineCapacityCc: json['engine_capacity_cc'] as int,
      pkb: json['pkb'] as String,
      njkb: json['njkb'] as String,
      ownerName: json['owner_name'] as String?,
      ownerNik: json['owner_nik'] as String?,
      ownershipStatus: json['ownership_status'] as String,
      usageType: json['usage_type'] as String,
      quotaMode: json['quota_mode'] as String,
      status: json['status'] as String,
      submittedAt: DateTime.parse(json['submitted_at'] as String),
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
      reviewNote: json['review_note'] as String?,
      documents: docs,
    );
  }
}

class VehicleDocumentPreviewData {
  final List<int> bytes;
  final String mimeType;
  final String fileName;

  const VehicleDocumentPreviewData({
    required this.bytes,
    required this.mimeType,
    required this.fileName,
  });
}
