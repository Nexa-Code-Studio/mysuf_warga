import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/user_profile.dart';
import '../../../../shared/providers/mock_providers.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../quota/presentation/providers/quota_providers.dart';

class SubsidyScreen extends ConsumerWidget {
  const SubsidyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final quotaDetailAsync = ref.watch(quotaDetailProvider);

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subsidi KTP Anda'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        leading: BackButton(
          color: Colors.black87,
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(profileProvider);
          ref.invalidate(quotaDetailProvider);
        },
        child: profileAsync.when(
          data: (profile) => quotaDetailAsync.when(
            data: (quotaResponse) {
              final personalQuota = quotaResponse.personalQuota;
              final totalQuota = personalQuota?.quotaLiters ?? 0.0;
              final usedQuota = personalQuota?.usedLiters ?? 0.0;
              final remainingQuota = personalQuota?.remainingLiters ?? 0.0;
              final progress = totalQuota > 0 ? (usedQuota / totalQuota) : 0.0;

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Status & Profile Card
                  _buildProfileCard(context, profile, currencyFormatter),
                  const SizedBox(height: 20),

                  // Quota Progress Card
                  if (profile.isEligible && totalQuota > 0) ...[
                    _buildQuotaProgressCard(
                      context,
                      totalQuota,
                      usedQuota,
                      remainingQuota,
                      progress,
                      personalQuota?.periodLabel ?? '',
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Subsidy Breakdown details
                  _buildCalculationDetailsCard(context, profile, totalQuota, currencyFormatter),
                  const SizedBox(height: 20),

                  // Subsidized Fuel Prices
                  _buildFuelPricesCard(context, quotaResponse.subsidizedFuels, currencyFormatter),
                  const SizedBox(height: 40),
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(20),
              child: LoadingSkeleton(height: 200),
            ),
            error: (err, _) => ErrorState(
              title: 'Gagal memuat detail kuota',
              message: 'Tarik untuk mencoba lagi.',
              onRetry: () => ref.invalidate(quotaDetailProvider),
            ),
          ),
          loading: () => const Padding(
            padding: EdgeInsets.all(20),
            child: LoadingSkeleton(height: 250),
          ),
          error: (err, _) => ErrorState(
            title: 'Gagal memuat profil',
            message: 'Tarik untuk mencoba lagi.',
            onRetry: () => ref.invalidate(profileProvider),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    UserProfile profile,
    NumberFormat currencyFormatter,
  ) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Red gradient header banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFCC0000), Color(0xFFE53935)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'NIK: ${profile.nikMasked}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        profile.isEligible ? Icons.check_circle : Icons.cancel,
                        size: 14,
                        color: profile.isEligible
                            ? const Color(0xFF69F0AE)
                            : const Color(0xFFFF8A80),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        profile.isEligible ? 'AKTIF' : 'TIDAK AKTIF',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Info row below
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    context,
                    'Pekerjaan',
                    profile.pekerjaan,
                    Icons.work_outline,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    context,
                    'Penghasilan Bulanan',
                    currencyFormatter.format(profile.penghasilan),
                    Icons.payments_outlined,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primaryRed),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuotaProgressCard(
    BuildContext context,
    double totalQuota,
    double usedQuota,
    double remainingQuota,
    double progress,
    String periodLabel,
  ) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Kuota Subsidi Bulan Ini',
            actionLabel: periodLabel,
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            color: AppColors.primaryRed,
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${remainingQuota.toStringAsFixed(0)} L',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryRed,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Sisa Kuota',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${usedQuota.toStringAsFixed(0)} / ${totalQuota.toStringAsFixed(0)} L',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Kuota Terpakai',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Returns bonus liters for a given pekerjaan, null = no bonus
  int? _jobBonus(String pekerjaan) {
    switch (pekerjaan.toUpperCase()) {
      case 'OJOL': return 50;
      case 'NELAYAN': return 100;
      case 'UMKM': return 50;
      case 'PETANI': return 50;
      default: return null;
    }
  }

  Widget _buildCalculationDetailsCard(
    BuildContext context,
    UserProfile profile,
    double totalQuota,
    NumberFormat currencyFormatter,
  ) {
    final bonus = _jobBonus(profile.pekerjaan);
    final baseQuota = 100;
    final expectedTotal = baseQuota + (bonus ?? 0);

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rincian Kelayakan Subsidi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          if (profile.isEligible) ...[
            _buildDetailRow(
              'Status Kelayakan',
              'LAYAK',
              valueColor: const Color(0xFF2E7D32),
            ),
            _buildDetailRow(
              'Batas Penghasilan',
              'Di bawah Rp 5.000.000',
            ),
            _buildDetailRow(
              'Penghasilan Tercatat',
              currencyFormatter.format(profile.penghasilan),
            ),
            const Divider(height: 24),
            _buildDetailRow('Kuota Dasar', '$baseQuota L / bulan'),
            _buildDetailRow(
              'Pekerjaan',
              profile.pekerjaan,
            ),
            _buildDetailRow(
              'Bonus Pekerjaan (${profile.pekerjaan})',
              bonus != null ? '+$bonus L / bulan' : 'Tidak Ada',
              valueColor: bonus != null
                  ? const Color(0xFF2E7D32)
                  : AppColors.textSecondary,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              'Total Kuota Bulanan',
              '${expectedTotal} L',
              isBold: true,
            ),
            if (totalQuota > 0 && totalQuota != expectedTotal.toDouble())
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Kuota aktual dari server: ${totalQuota.toStringAsFixed(0)} L',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ] else ...[
            _buildDetailRow(
              'Status Kelayakan',
              'TIDAK LAYAK',
              valueColor: const Color(0xFFC62828),
            ),
            const SizedBox(height: 8),
            const Text(
              'Berdasarkan data kependudukan (KTP) Anda, penghasilan Anda berada di atas batas Rp 5.000.000 atau NIK Anda tidak terdaftar dalam penerima subsidi.',
              style: TextStyle(
                color: Color(0xFFC62828),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isBold ? Colors.black : Colors.grey[600],
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFuelPricesCard(
    BuildContext context,
    dynamic subsidizedFuels,
    NumberFormat currencyFormatter,
  ) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Harga BBM Bersubsidi Khusus KTP Layak',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (subsidizedFuels is List && subsidizedFuels.isNotEmpty)
            Column(
              children: (subsidizedFuels as List)
                  .where((fuel) {
                    final name = fuel.name.toString().toUpperCase();
                    return name.contains('PERTALITE') || name.contains('SOLAR');
                  })
                  .map<Widget>((fuel) {
                final double marketPrice = fuel.pricePerLiter;
                final double subsidyPrice = fuel.subsidyPricePerLiter ?? marketPrice;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 30,
                        decoration: BoxDecoration(
                          color: fuel.name.toString().toUpperCase().contains('SOLAR')
                              ? Colors.yellow[700]
                              : Colors.green[600],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fuel.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Harga Pasar: ${currencyFormatter.format(marketPrice)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currencyFormatter.format(subsidyPrice),
                            style: const TextStyle(
                              color: AppColors.primaryRed,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Text(
                            'per Liter',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            )
          else
            const Text(
              'Tidak ada data BBM bersubsidi saat ini.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
        ],
      ),
    );
  }
}
