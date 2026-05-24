import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/vehicle.dart';
import 'vehicle_api_repository.dart';

final vehicleApiRepositoryProvider = Provider<VehicleApiRepository>((ref) {
  return VehicleApiRepository();
});

final buyerVehiclesProvider = FutureProvider<List<Vehicle>>((ref) async {
  return ref.read(vehicleApiRepositoryProvider).fetchMyVehicles();
});

final pendingVehicleRequestsProvider = FutureProvider<List<PendingVehicleRequest>>((ref) async {
  return ref.read(vehicleApiRepositoryProvider).fetchPendingVehicleRequests();
});

final pendingVehicleRequestDetailProvider = FutureProvider.family<PendingVehicleRequestDetail, String>((ref, requestId) async {
  return ref.read(vehicleApiRepositoryProvider).fetchPendingVehicleRequestDetail(requestId);
});

final vehicleDetailProvider = FutureProvider.family<VehicleDetail, String>((ref, ownershipId) async {
  return ref.read(vehicleApiRepositoryProvider).fetchVehicleDetail(ownershipId);
});
