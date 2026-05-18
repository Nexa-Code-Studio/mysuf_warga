import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';

class SpbuNearbyScreen extends StatelessWidget {
  const SpbuNearbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stations = [
      const _StationInfo(
        name: 'SPBU 31.001 Sudirman',
        distance: '0.8 km dari lokasi Anda',
        address: 'Jl. Jend. Sudirman No. 21, Jakarta',
        isOpen: true,
      ),
      const _StationInfo(
        name: 'SPBU 31.002 Gatot Subroto',
        distance: '1.4 km dari lokasi Anda',
        address: 'Jl. Gatot Subroto No. 12, Jakarta',
        isOpen: true,
      ),
      const _StationInfo(
        name: 'SPBU 34.101 Bekasi',
        distance: '3.1 km dari lokasi Anda',
        address: 'Jl. Ahmad Yani No. 8, Bekasi',
        isOpen: false,
      ),
      const _StationInfo(
        name: 'SPBU 33.201 Depok',
        distance: '5.4 km dari lokasi Anda',
        address: 'Jl. Margonda Raya No. 105, Depok',
        isOpen: true,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('SPBU Terdekat')),
      body: SafeArea(
        child: ListView.separated(
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
                    child: const Icon(Icons.location_on_outlined,
                        color: AppColors.primaryRed),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          station.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          station.distance,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          station.address,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: station.isOpen
                          ? const Color(0xFFE9F9EF)
                          : const Color(0xFFFFF5E5),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      station.isOpen ? 'Buka' : 'Tutup',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color:
                                station.isOpen ? AppColors.success : AppColors.warning,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemCount: stations.length,
        ),
      ),
    );
  }
}

class _StationInfo {
  final String name;
  final String distance;
  final String address;
  final bool isOpen;

  const _StationInfo({
    required this.name,
    required this.distance,
    required this.address,
    required this.isOpen,
  });
}
