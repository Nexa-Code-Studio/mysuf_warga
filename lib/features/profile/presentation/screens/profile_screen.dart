import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/providers/mock_providers.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../../../shared/widgets/section_header.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    final direction = _scrollController.position.userScrollDirection;
    if (direction == ScrollDirection.reverse) {
      if (ref.read(bottomNavVisibleProvider)) {
        ref.read(bottomNavVisibleProvider.notifier).setVisible(false);
      }
    } else if (direction == ScrollDirection.forward) {
      if (!ref.read(bottomNavVisibleProvider)) {
        ref.read(bottomNavVisibleProvider.notifier).setVisible(true);
      }
    }
  }

  Future<void> _confirmUpdateNfc(BuildContext context) async {
    final shouldContinue = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Update NFC'),
          content: const Text(
            'NFC E-KTP Anda akan diperbarui. Data NFC pada kendaraan dan pengajuan kendaraan yang terkait juga akan ikut diganti.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                foregroundColor: Colors.white,
              ),
              child: const Text('Lanjutkan'),
            ),
          ],
        );
      },
    );

    if (shouldContinue == true && context.mounted) {
      context.go('/profile/update-nfc');
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final risk = ref.watch(riskProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.all(20),
          children: [
            profile.when(
              data: (data) => GestureDetector(
                onTap: () => context.go('/profile/detail'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: const Color(0xFFFFF1F3),
                          child: Text(
                            data.name.isNotEmpty
                                ? (data.name.length >= 2
                                    ? data.name.substring(0, 2).toUpperCase()
                                    : data.name.toUpperCase())
                                : '',
                            style: const TextStyle(
                              color: AppColors.primaryRed,
                              fontWeight: FontWeight.w800,
                              fontSize: 28,
                            ),
                          ),
                        ),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.primaryRed,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      data.name.trim(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'NIK: ${data.nikMasked}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
              loading: () => const Center(child: LoadingSkeleton(height: 120)),
              error: (_, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            const SectionHeader(title: 'Akun & Identitas'),
            const SizedBox(height: 12),
            _MenuTile(
              title: 'Status Subsidi KTP',
              subtitle: 'Cek kelayakan, pekerjaan, dan sisa kuota',
              icon: Icons.badge_outlined,
              onTap: () => context.go('/subsidy'),
            ),
            const SizedBox(height: 10),
            const SectionHeader(title: 'Keamanan'),
            const SizedBox(height: 12),
            profile.when(
              data: (data) => _MenuTile(
                title: 'PIN Keamanan Transaksi',
                subtitle: data.isPinActive
                    ? 'Aktif - Keamanan transaksi aktif'
                    : 'Belum Aktif - Klik untuk atur PIN',
                icon: Icons.lock_outline,
                onTap: () => context.go('/profile/pin'),
              ),
              loading: () => const LoadingSkeleton(height: 72),
              error: (_, __) => _MenuTile(
                title: 'PIN Keamanan Transaksi',
                subtitle: 'Pengaturan PIN transaksi',
                icon: Icons.lock_outline,
                onTap: () => context.go('/profile/pin'),
              ),
            ),
            const SizedBox(height: 10),
            _MenuTile(
              title: 'Update NFC',
              subtitle: 'Perbarui NFC E-KTP untuk transaksi',
              icon: Icons.nfc_rounded,
              onTap: () => _confirmUpdateNfc(context),
            ),
            const SizedBox(height: 10),
            risk.when(
              data: (data) => _MenuTile(
                title: 'Status Risiko AI',
                subtitle:
                    'Skor ${data.score.toStringAsFixed(0)} - ${data.statusLabel}',
                icon: Icons.shield_outlined,
                onTap: () => context.go('/home/risk'),
              ),
              loading: () => const LoadingSkeleton(height: 72),
              error: (_, _) => _MenuTile(
                title: 'Status Risiko AI',
                subtitle: 'Data risiko belum tersedia',
                icon: Icons.shield_outlined,
                onTap: () => context.go('/home/risk'),
              ),
            ),
            const SizedBox(height: 10),
            _MenuTile(
              title: 'Pengaturan Notifikasi',
              subtitle: 'Pengingat kuota dan transaksi',
              icon: Icons.notifications_none,
              onTap: () => context.go('/profile/notifications'),
            ),
            const SizedBox(height: 10),
            _MenuTile(
              title: 'Pusat Panduan',
              subtitle: 'FAQ, panduan, dan bantuan aplikasi',
              icon: Icons.help_outline,
              onTap: () => context.go('/profile/help'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.go('/logout-processing'),
                icon: const Icon(Icons.logout),
                label: const Text('Keluar Akun'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryRed, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.primaryRed,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  const _MenuTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.softGray,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryRed),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
