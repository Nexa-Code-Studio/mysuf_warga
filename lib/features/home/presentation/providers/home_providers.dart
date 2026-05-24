import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/home_api_repository.dart';
import '../../domain/buyer_home.dart';

final homeApiRepositoryProvider = Provider<HomeApiRepository>((ref) {
  return HomeApiRepository();
});

final homeDashboardProvider = FutureProvider<BuyerHome>((ref) async {
  final repository = ref.read(homeApiRepositoryProvider);
  
  double? latitude;
  double? longitude;

  try {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (serviceEnabled) {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        // Fetch current position with a short timeout to prevent blocking
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
          timeLimit: const Duration(seconds: 4),
        );
        latitude = position.latitude;
        longitude = position.longitude;
      }
    }
  } catch (e) {
    // If anything fails (timeout, permissions denied, etc.), we fallback silently
    // and query the backend without coordinates.
  }

  return repository.fetchHomeData(latitude: latitude, longitude: longitude);
});
