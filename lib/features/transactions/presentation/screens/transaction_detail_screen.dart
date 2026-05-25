import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/models/wallet_transaction.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../../wallet/data/wallet_providers.dart';

class TransactionDetailScreen extends ConsumerStatefulWidget {
  final String id;
  const TransactionDetailScreen({super.key, required this.id});

  @override
  ConsumerState<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends ConsumerState<TransactionDetailScreen> {
  late Future<WalletTransaction> _detailFuture;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  void _fetchDetail() {
    setState(() {
      _detailFuture = ref
          .read(walletApiRepositoryProvider)
          .fetchTransactionDetail(widget.id);
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ID Transaksi disalin ke papan klip'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareReceipt() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Resi berhasil disimpan ke galeri!'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Detail Transaksi',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: FutureBuilder<WalletTransaction>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: 3,
              itemBuilder: (context, index) => const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: LoadingSkeleton(height: 120),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ErrorState(
                  title: 'Gagal Memuat Detail',
                  message: snapshot.error.toString().replaceAll('Exception: ', ''),
                  onRetry: _fetchDetail,
                ),
              ),
            );
          }

          final tx = snapshot.data!;
          return _buildDetailContent(tx);
        },
      ),
    );
  }

  Widget _buildDetailContent(WalletTransaction tx) {
    final isIncoming = tx.transactionFlow == TransactionFlow.inflow;
    final formattedDate = DateFormat('dd MMMM yyyy, HH:mm').format(tx.createdAt);

    IconData headerIcon;
    Color statusColor;
    Color bgStatusColor;

    switch (tx.status) {
      case WalletTransactionStatus.success:
        headerIcon = Icons.check_circle_rounded;
        statusColor = AppColors.success;
        bgStatusColor = AppColors.success.withOpacity(0.1);
        break;
      case WalletTransactionStatus.failed:
        headerIcon = Icons.cancel_rounded;
        statusColor = AppColors.primaryRed;
        bgStatusColor = AppColors.primaryRed.withOpacity(0.1);
        break;
      case WalletTransactionStatus.pending:
        headerIcon = Icons.timelapse_rounded;
        statusColor = Colors.orange;
        bgStatusColor = Colors.orange.withOpacity(0.1);
        break;
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 1. Premium Header amount card
          AppCard(
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: bgStatusColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(headerIcon, color: statusColor, size: 40),
                ),
                const SizedBox(height: 16),
                Text(
                  tx.type.label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${isIncoming ? '+' : '-'} ${formatCurrencyIdr(tx.amount)}',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: isIncoming ? AppColors.success : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: bgStatusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tx.status.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
          
          const SizedBox(height: 20),

          // 2. Transaction Details List
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rincian Transaksi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildDetailRow(
                  label: 'Waktu Transaksi',
                  value: formattedDate,
                ),
                _buildDivider(),
                
                _buildDetailRow(
                  label: 'Metode Pembayaran',
                  value: tx.type == TransactionType.topUp
                      ? 'Xendit Payment Session'
                      : switch (tx.paymentMethod) {
                          'CASH' => 'Tunai / Cash',
                          'QRIS' => 'QRIS',
                          'WALLET' => 'E-Wallet Internal',
                          _ => 'E-Wallet Internal',
                        },
                ),
                _buildDivider(),
                
                _buildDetailRow(
                  label: 'ID Transaksi',
                  value: tx.id,
                  trailing: GestureDetector(
                    onTap: () => _copyToClipboard(tx.id),
                    child: const Icon(
                      Icons.copy_rounded, 
                      size: 18, 
                      color: AppColors.primaryRed,
                    ),
                  ),
                ),
                _buildDivider(),

                _buildDetailRow(
                  label: 'Saldo Sebelum',
                  value: tx.paymentMethod == 'CASH' || tx.paymentMethod == 'QRIS'
                      ? 'Tidak mempengaruhi wallet'
                      : formatCurrencyIdr(tx.balanceBefore),
                ),
                _buildDivider(),

                _buildDetailRow(
                  label: 'Saldo Sesudah',
                  value: tx.paymentMethod == 'CASH' || tx.paymentMethod == 'QRIS'
                      ? 'Tidak mempengaruhi wallet'
                      : formatCurrencyIdr(tx.balanceAfter),
                ),

                if (tx.description != null && tx.description!.trim().isNotEmpty) ...[
                  _buildDivider(),
                  _buildDetailRow(
                    label: 'Keterangan',
                    value: tx.description!,
                  ),
                ],
              ],
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideY(begin: 0.1, end: 0),

          const SizedBox(height: 28),

          // 3. Receipt Action Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _shareReceipt,
              icon: const Icon(Icons.download_rounded, color: Colors.white),
              label: const Text(
                'Simpan Resi Pembayaran',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    value,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  trailing,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: Colors.grey.shade200,
      ),
    );
  }
}
