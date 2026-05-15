enum VehicleCategory { nonCommercial, commercial }

class Vehicle {
  final String plateNumber;
  final String typeLabel;
  final VehicleCategory category;
  final bool isActive;

  const Vehicle({
    required this.plateNumber,
    required this.typeLabel,
    required this.category,
    required this.isActive,
  });
}
