import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../providers/home_providers.dart';

class SpbuNearbyScreen extends ConsumerWidget {
  const SpbuNearbyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(currentLocationProvider);
    final nearbyStations = ref.watch(nearbyGasStationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('SPBU Terdekat')),
      body: SafeArea(
        child: nearbyStations.when(
          data: (nearby) {
            final stations = nearby.items;

            if (!nearby.locationAvailable) {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.softGray,
                      child: const Icon(
                        Icons.location_off,
                        size: 36,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      locationState.asData?.value.message ??
                          nearby.message ??
                          'Lokasi Anda tidak ditemukan, tolong nyalakan GPS.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (locationState.asData?.value.canRetry ?? true)
                          OutlinedButton(
                            onPressed: () {
                              ref.invalidate(currentLocationProvider);
                              ref.invalidate(nearbyGasStationsProvider);
                            },
                            child: const Text('Coba Lagi'),
                          ),
                        if (locationState
                                .asData
                                ?.value
                                .canOpenLocationSettings ??
                            false)
                          OutlinedButton(
                            onPressed: Geolocator.openLocationSettings,
                            child: const Text('Buka GPS'),
                          ),
                        if (locationState.asData?.value.canOpenAppSettings ??
                            false)
                          OutlinedButton(
                            onPressed: Geolocator.openAppSettings,
                            child: const Text('Buka Pengaturan'),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            }

            if (stations.isEmpty) {
              return Center(
                child: Text(
                  'Tidak ada SPBU terdekat yang ditemukan.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemBuilder: (context, index) {
                final station = stations[index];
                return AppCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.softGray,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.primaryRed,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              station.name,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${station.distanceKm.toStringAsFixed(1)} km dari lokasi Anda',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Lat: ${station.latitude.toStringAsFixed(4)}, Lon: ${station.longitude.toStringAsFixed(4)}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9F9EF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Buka',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemCount: stations.length,
            );
          },
          loading: () => ListView.separated(
            padding: const EdgeInsets.all(20),
            itemBuilder: (_, _) => const LoadingSkeleton(height: 96),
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemCount: 4,
          ),
          error: (err, _) => ErrorState(
            title: 'Gagal memuat SPBU terdekat',
            message: err.toString(),
            onRetry: () {
              ref.invalidate(currentLocationProvider);
              ref.invalidate(nearbyGasStationsProvider);
            },
          ),
        ),
      ),
    );
  }
}
