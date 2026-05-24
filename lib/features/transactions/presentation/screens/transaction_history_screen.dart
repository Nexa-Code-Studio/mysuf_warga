import 'package:flutter/material.dart';
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

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends ConsumerState<TransactionHistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<WalletTransaction> _transactions = [];
  
  int _page = 1;
  final int _size = 15;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadMoreTransactions();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) {
        _loadMoreTransactions();
      }
    }
  }

  Future<void> _loadMoreTransactions() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(walletApiRepositoryProvider);
      final result = await repository.fetchTransactions(page: _page, size: _size);
      
      final List<dynamic> itemsRaw = result['items'] as List<dynamic>? ?? [];
      final List<WalletTransaction> newItems = itemsRaw
          .map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
          .toList();

      setState(() {
        _transactions.addAll(newItems);
        _page++;
        _isLoading = false;
        if (newItems.length < _size) {
          _hasMore = false;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _page = 1;
      _transactions.clear();
      _hasMore = true;
      _errorMessage = null;
    });
    await _loadMoreTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Riwayat Transaksi',
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
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primaryRed,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_transactions.isEmpty && _isLoading && _page == 1) {
      return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        itemCount: 5,
        itemBuilder: (context, index) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: LoadingSkeleton(height: 80),
        ),
      );
    }

    if (_transactions.isEmpty && _errorMessage != null && _page == 1) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height - 150,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(20),
          child: ErrorState(
            title: 'Gagal Memuat Transaksi',
            message: _errorMessage!,
            onRetry: _refresh,
          ),
        ),
      );
    }

    if (_transactions.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height - 150,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 80,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              const Text(
                'Belum Ada Transaksi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Semua aktivitas top up dan pembayaran Anda akan muncul di sini.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ).animate().fadeIn(duration: 300.ms),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: _transactions.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _transactions.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed),
                ),
              ),
            ),
          );
        }

        final tx = _transactions[index];
        return _buildTransactionCard(tx)
            .animate()
            .fadeIn(duration: 250.ms, delay: (index % 6 * 40).ms)
            .slideY(begin: 0.1, end: 0, duration: 250.ms);
      },
    );
  }

  Widget _buildTransactionCard(WalletTransaction tx) {
    final isIncoming = tx.transactionFlow == TransactionFlow.inflow;
    final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(tx.createdAt);
    
    IconData icon;
    Color iconColor;
    Color bgIconColor;

    switch (tx.type) {
      case TransactionType.topUp:
        icon = Icons.add_card_rounded;
        iconColor = AppColors.success;
        bgIconColor = AppColors.success.withOpacity(0.1);
        break;
      case TransactionType.fuelPurchase:
        icon = Icons.local_gas_station_rounded;
        iconColor = AppColors.primaryRed;
        bgIconColor = AppColors.primaryRed.withOpacity(0.1);
        break;
      case TransactionType.refund:
        icon = Icons.replay_rounded;
        iconColor = Colors.blue;
        bgIconColor = Colors.blue.withOpacity(0.1);
        break;
      case TransactionType.adminAdjustment:
        icon = Icons.tune_rounded;
        iconColor = Colors.orange;
        bgIconColor = Colors.orange.withOpacity(0.1);
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('/transactions/${tx.id}'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: bgIconColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.description ?? tx.type.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isIncoming ? '+' : '-'} ${formatCurrencyIdr(tx.amount)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: isIncoming ? AppColors.success : Colors.black87,
                      ),
                    ),
                    if (tx.status != WalletTransactionStatus.success) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: tx.status == WalletTransactionStatus.pending
                              ? Colors.orange.withOpacity(0.1)
                              : AppColors.primaryRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tx.status.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: tx.status == WalletTransactionStatus.pending
                                ? Colors.orange
                                : AppColors.primaryRed,
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
