import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/providers/mock_providers.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../../../shared/widgets/section_header.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletProvider);
    final transactions = ref.watch(transactionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            wallet.when(
              data: (data) => AppCard(
                color: AppColors.primaryRed,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'E-Wallet',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.white70),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                data.isActive ? 'Aktif' : 'Nonaktif',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Saldo E-KTP',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      formatCurrencyIdr(data.balance),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'NIK **** **** ${data.walletIdMasked}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              loading: () => const LoadingSkeleton(height: 160),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _WalletAction(
                  label: 'Top Up',
                  icon: Icons.north_east,
                  onTap: () => context.go('/wallet/topup'),
                ),
                const SizedBox(width: 12),
                _WalletAction(
                  label: 'Transfer',
                  icon: Icons.swap_horiz,
                  onTap: () {},
                ),
                const SizedBox(width: 12),
                _WalletAction(
                  label: 'Tarik Tunai',
                  icon: Icons.payments_outlined,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Row(
                children: [
                  Expanded(
                    child: _InlineAction(
                      label: 'Tap E-KTP',
                      subtitle: 'Simulasi transaksi NFC',
                      icon: Icons.nfc_rounded,
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InlineAction(
                      label: 'QRIS',
                      subtitle: 'Scan QR untuk bayar',
                      icon: Icons.qr_code_2,
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SectionHeader(
              title: 'Riwayat Transaksi',
              actionLabel: 'Semua',
              onAction: () => context.go('/transactions'),
            ),
            const SizedBox(height: 12),
            transactions.when(
              data: (items) => Column(
                children: items
                    .take(3)
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AppCard(
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.softGray,
                                child: Icon(
                                  item.amount >= 0
                                      ? Icons.south_west
                                      : Icons.local_gas_station,
                                  color: AppColors.primaryRed,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.dateTimeLabel,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${item.amount >= 0 ? '+' : '-'}${formatCurrencyIdr(item.amount.abs())}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: item.amount >= 0
                                          ? AppColors.success
                                          : AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              loading: () => const LoadingSkeleton(height: 140),
              error: (_, __) => ErrorState(
                title: 'Gagal memuat transaksi',
                message: 'Coba lagi dalam beberapa saat.',
                onRetry: () => ref.invalidate(transactionsProvider),
              ),
            ),
          ]
              .animate(interval: 70.ms)
              .fadeIn(duration: 300.ms)
              .moveY(begin: 8, end: 0),
        ),
      ),
    );
  }
}

class _WalletAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _WalletAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: InkWell(
          onTap: onTap,
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFF3E8FF),
                child: Icon(icon, color: AppColors.primaryRed),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineAction extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _InlineAction({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.softGray,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              child: Icon(icon, color: AppColors.primaryRed, size: 18),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
