import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/models/wallet_transaction.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../data/wallet_providers.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
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

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletProvider);
    final transactions = ref.watch(walletTransactionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(walletProvider);
            ref.invalidate(walletTransactionsProvider);
            try {
              await Future.wait([
                ref.read(walletProvider.future),
                ref.read(walletTransactionsProvider.future),
              ]);
            } catch (_) {}
          },
          child: ListView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
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
                        data.nikMasked != null
                            ? 'NIK ${data.nikMasked}'
                            : 'NIK **** **** ${data.walletIdMasked}',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                loading: () => const LoadingSkeleton(height: 160),
                error: (error, _) => AppCard(
                  color: AppColors.primaryRed.withOpacity(0.1),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.primaryRed, size: 36),
                      const SizedBox(height: 10),
                      Text(
                        'Gagal memuat saldo: ${error.toString().replaceAll('Exception: ', '')}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(walletProvider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryRed,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _InlineAction(
                    label: 'Top Up',
                    subtitle: 'Tambah saldo dompet',
                    icon: Icons.add_card_rounded,
                    onTap: () => context.go('/wallet/topup'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _InlineAction(
                    label: 'Transfer',
                    subtitle: 'Kirim ke KTP lain',
                    icon: Icons.swap_horiz,
                    onTap: () => context.go('/wallet/transfer'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SectionHeader(
              title: 'Riwayat Transaksi',
              actionLabel: 'Semua',
              onAction: () => context.go('/transactions'),
            ),
            const SizedBox(height: 12),
            transactions.when(
              data: (items) {
                if (items.isEmpty) {
                  return Container(
                    height: 240,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Belum ada transaksi',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Column(
                  children: items
                      .take(3)
                      .map(
                        (item) {
                          final isIncoming = item.transactionFlow == TransactionFlow.inflow;
                          final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(item.createdAt);
                          
                          IconData icon;
                          Color iconColor;
                          Color bgIconColor;

                          switch (item.type) {
                            case TransactionType.topUp:
                              icon = Icons.add_card_rounded;
                              iconColor = AppColors.success;
                              bgIconColor = const Color(0xFFEDFDF5);
                              break;
                            case TransactionType.transfer:
                              icon = Icons.swap_horiz;
                              iconColor = AppColors.primaryRed;
                              bgIconColor = const Color(0xFFFFF4F5);
                              break;
                            case TransactionType.fuelPurchase:
                              icon = Icons.local_gas_station_rounded;
                              iconColor = AppColors.primaryRed;
                              bgIconColor = const Color(0xFFFFF4F5);
                              break;
                            default:
                              icon = Icons.payments_rounded;
                              iconColor = AppColors.textSecondary;
                              bgIconColor = AppColors.softGray;
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: AppCard(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: bgIconColor,
                                    child: Icon(icon, color: iconColor),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.description ?? item.type.label,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          formattedDate,
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${isIncoming ? '+' : '-'} ${formatCurrencyIdr(item.amount)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isIncoming
                                          ? AppColors.success
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                      .toList(),
                );
              },
              loading: () => Column(
                children: List.generate(
                  3,
                  (index) => const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: LoadingSkeleton(height: 80),
                  ),
                ),
              ),
              error: (error, __) => ErrorState(
                title: 'Gagal memuat transaksi',
                message: error.toString().replaceAll('Exception: ', ''),
                onRetry: () => ref.invalidate(walletTransactionsProvider),
              ),
            ),
          ]
              .animate(interval: 70.ms)
              .fadeIn(duration: 300.ms)
              .moveY(begin: 8, end: 0),
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
