import '../../../core/services/mock_api.dart';
import '../domain/vehicle_state.dart';

class VehicleRepository {
  final MockApi api;

  VehicleRepository(this.api);

  Future<VehicleState> fetchVehicles() async {
    final vehicles = await api.fetchVehicles();
    return VehicleState(vehicles: vehicles);
  }
}
