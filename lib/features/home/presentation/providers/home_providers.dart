import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/home_api_repository.dart';
import '../../domain/buyer_home.dart';

final homeApiRepositoryProvider = Provider<HomeApiRepository>((ref) {
  return HomeApiRepository();
});

class LocationSnapshot {
  final double? latitude;
  final double? longitude;
  final String? message;
  final bool canRetry;
  final bool canOpenAppSettings;
  final bool canOpenLocationSettings;

  const LocationSnapshot({
    this.latitude,
    this.longitude,
    this.message,
    this.canRetry = false,
    this.canOpenAppSettings = false,
    this.canOpenLocationSettings = false,
  });

  bool get hasCoordinates => latitude != null && longitude != null;
}

final currentLocationProvider = FutureProvider<LocationSnapshot>((ref) async {
  return _resolveCurrentLocation();
});

final homeDashboardProvider = FutureProvider<BuyerHome>((ref) async {
  final repository = ref.read(homeApiRepositoryProvider);
  final location = await ref.watch(currentLocationProvider.future);

  return repository.fetchHomeData(
    latitude: location.latitude,
    longitude: location.longitude,
  );
});

final nearbyGasStationsProvider = FutureProvider<NearbyGasStationsHome>((
  ref,
) async {
  final repository = ref.read(homeApiRepositoryProvider);
  final location = await ref.watch(currentLocationProvider.future);

  if (!location.hasCoordinates) {
    return NearbyGasStationsHome(
      locationAvailable: false,
      message: location.message,
      items: const [],
    );
  }

  return repository.fetchNearbyGasStations(
    latitude: location.latitude!,
    longitude: location.longitude!,
  );
});

Future<LocationSnapshot> _resolveCurrentLocation() async {
  try {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const LocationSnapshot(
        message:
            'Layanan lokasi nonaktif. Nyalakan GPS untuk melihat SPBU terdekat.',
        canRetry: true,
        canOpenLocationSettings: true,
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      return const LocationSnapshot(
        message:
            'Izin lokasi belum diberikan. Izinkan akses lokasi untuk mendeteksi SPBU terdekat.',
        canRetry: true,
      );
    }

    if (permission == LocationPermission.deniedForever) {
      return const LocationSnapshot(
        message:
            'Izin lokasi ditolak permanen. Buka pengaturan aplikasi untuk mengaktifkan akses lokasi.',
        canOpenAppSettings: true,
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 4),
      ),
    );

    return LocationSnapshot(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  } catch (_) {
    return const LocationSnapshot(
      message:
          'Lokasi belum bisa didapatkan. Pastikan GPS aktif lalu coba lagi.',
      canRetry: true,
      canOpenLocationSettings: true,
    );
  }
}
