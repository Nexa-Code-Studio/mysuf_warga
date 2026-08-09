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
import '../../../wallet/data/wallet_providers.dart';

// ─── Filter State Model ───────────────────────────────────────────────────────

enum TxPeriod { all, week, month }

enum TxSortField { date, amount }

enum TxSortDir { desc, asc }

class TxFilter {
  final TxPeriod period;
  final DateTime? selectedWeek;   // start-of-week Monday
  final DateTime? selectedMonth;  // year+month only
  final TxSortField sortField;
  final TxSortDir sortDir;

  const TxFilter({
    this.period = TxPeriod.all,
    this.selectedWeek,
    this.selectedMonth,
    this.sortField = TxSortField.date,
    this.sortDir = TxSortDir.desc,
  });

  TxFilter copyWith({
    TxPeriod? period,
    DateTime? selectedWeek,
    DateTime? selectedMonth,
    TxSortField? sortField,
    TxSortDir? sortDir,
    bool clearWeek = false,
    bool clearMonth = false,
  }) {
    return TxFilter(
      period: period ?? this.period,
      selectedWeek: clearWeek ? null : (selectedWeek ?? this.selectedWeek),
      selectedMonth: clearMonth ? null : (selectedMonth ?? this.selectedMonth),
      sortField: sortField ?? this.sortField,
      sortDir: sortDir ?? this.sortDir,
    );
  }

  bool get isActive =>
      period != TxPeriod.all ||
      sortField != TxSortField.date ||
      sortDir != TxSortDir.desc;
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<WalletTransaction> _transactions = [];

  int _page = 1;
  final int _size = 50;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _errorMessage;
  TxFilter _filter = const TxFilter();

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

  Future<void> _loadMoreTransactions() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(walletApiRepositoryProvider);
      final result =
          await repository.fetchTransactions(page: _page, size: _size);

      final List<dynamic> itemsRaw =
          result['items'] as List<dynamic>? ?? [];
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

  // ─── Filtering & Sorting ──────────────────────────────────────────────────

  List<WalletTransaction> get _filteredTransactions {
    List<WalletTransaction> result = List.from(_transactions);

    final now = DateTime.now();

    if (_filter.period == TxPeriod.week) {
      final weekStart = _filter.selectedWeek ??
          DateTime(now.year, now.month, now.day)
              .subtract(Duration(days: now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 7));
      result = result
          .where((tx) =>
              tx.createdAt.isAfter(weekStart) &&
              tx.createdAt.isBefore(weekEnd))
          .toList();
    } else if (_filter.period == TxPeriod.month) {
      final target = _filter.selectedMonth ?? DateTime(now.year, now.month);
      result = result
          .where((tx) =>
              tx.createdAt.year == target.year &&
              tx.createdAt.month == target.month)
          .toList();
    }

    result.sort((a, b) {
      int cmp;
      if (_filter.sortField == TxSortField.date) {
        cmp = a.createdAt.compareTo(b.createdAt);
      } else {
        cmp = a.amount.compareTo(b.amount);
      }
      return _filter.sortDir == TxSortDir.asc ? cmp : -cmp;
    });

    return result;
  }

  // ─── Filter Modal ─────────────────────────────────────────────────────────

  void _showFilterModal() {
    // Hide bottom nav while modal is open
    ref.read(bottomNavVisibleProvider.notifier).setVisible(false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterModal(
        initialFilter: _filter,
        onApply: (newFilter) {
          setState(() => _filter = newFilter);
        },
      ),
    ).whenComplete(() {
      // Restore bottom nav when modal closes
      if (mounted) {
        ref.read(bottomNavVisibleProvider.notifier).setVisible(true);
      }
    });
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isTitleVisible = ref.watch(bottomNavVisibleProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: AppColors.primaryRed,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: isTitleVisible
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Riwayat Transaksi',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                IconButton(
                                  onPressed: _showFilterModal,
                                  icon: const Icon(Icons.tune_rounded),
                                  color: AppColors.textPrimary,
                                  tooltip: 'Filter',
                                ),
                                if (_filter.isActive)
                                  Positioned(
                                    top: 6,
                                    right: 6,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primaryRed,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_transactions.isEmpty && _isLoading && _page == 1) {
      return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 5,
        itemBuilder: (context, index) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: LoadingSkeleton(height: 80),
        ),
      );
    }

    if (_transactions.isEmpty && _errorMessage != null && _page == 1) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          ErrorState(
            title: 'Gagal Memuat Transaksi',
            message: _errorMessage!,
            onRetry: _refresh,
          ),
        ],
      );
    }

    final displayed = _filteredTransactions;

    if (displayed.isEmpty) {
      return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    _filter.isActive
                        ? 'Tidak Ada Transaksi'
                        : 'Belum Ada Transaksi',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _filter.isActive
                        ? 'Tidak ada transaksi sesuai filter yang dipilih.'
                        : 'Semua aktivitas top up dan pembayaran Anda akan muncul di sini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  if (_filter.isActive) ...[
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () =>
                          setState(() => _filter = const TxFilter()),
                      icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
                      label: const Text('Hapus Filter'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryRed,
                        side: const BorderSide(color: AppColors.primaryRed),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        minimumSize: Size.zero,
                      ),
                    ),
                  ]
                ],
              ).animate().fadeIn(duration: 300.ms),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: displayed.length + (_hasMore && !_filter.isActive ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == displayed.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primaryRed),
                ),
              ),
            ),
          );
        }
        final tx = displayed[index];
        return _buildTransactionCard(tx)
            .animate()
            .fadeIn(duration: 250.ms, delay: (index % 6 * 40).ms)
            .slideY(begin: 0.1, end: 0, duration: 250.ms);
      },
    );
  }

  Widget _buildTransactionCard(WalletTransaction tx) {
    final isIncoming = tx.transactionFlow == TransactionFlow.inflow;
    final isUsingWalletBalance = tx.transactionFlow == TransactionFlow.outflow &&
        tx.balanceAfter < tx.balanceBefore;
    final formattedDate =
        DateFormat('dd MMM yyyy, HH:mm').format(tx.createdAt);

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
      case TransactionType.transfer:
        icon = Icons.swap_horiz;
        iconColor = AppColors.primaryRed;
        bgIconColor = AppColors.primaryRed.withOpacity(0.1);
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
                        color: isIncoming
                            ? AppColors.success
                            : (isUsingWalletBalance
                                ? AppColors.primaryRed
                                : Colors.black87),
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
                            color:
                                tx.status == WalletTransactionStatus.pending
                                    ? Colors.orange
                                    : AppColors.primaryRed,
                          ),
                        ),
                      ),
                    ],
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

// ─── Filter Modal ─────────────────────────────────────────────────────────────

class _FilterModal extends StatefulWidget {
  final TxFilter initialFilter;
  final ValueChanged<TxFilter> onApply;

  const _FilterModal({required this.initialFilter, required this.onApply});

  @override
  State<_FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<_FilterModal> {
  late TxFilter _local;

  @override
  void initState() {
    super.initState();
    _local = widget.initialFilter;
  }

  void _apply() {
    widget.onApply(_local);
    Navigator.of(context).pop();
  }

  void _reset() {
    setState(() => _local = const TxFilter());
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter & Urutkan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  TextButton(
                    onPressed: _reset,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryRed,
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                    ),
                    child: const Text('Reset'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Period ──────────────────────────────────────────────────
              _SectionLabel(label: 'Periode'),
              const SizedBox(height: 10),
              Row(
                children: [
                  _PeriodChip(
                    label: 'Semua',
                    selected: _local.period == TxPeriod.all,
                    onTap: () => setState(() =>
                        _local = _local.copyWith(period: TxPeriod.all)),
                  ),
                  const SizedBox(width: 8),
                  _PeriodChip(
                    label: 'Seminggu',
                    selected: _local.period == TxPeriod.week,
                    onTap: () {
                      final now = DateTime.now();
                      final startOfWeek = DateTime(now.year, now.month, now.day)
                          .subtract(Duration(days: now.weekday - 1));
                      setState(() => _local = _local.copyWith(
                            period: TxPeriod.week,
                            selectedWeek: startOfWeek,
                          ));
                    },
                  ),
                  const SizedBox(width: 8),
                  _PeriodChip(
                    label: 'Sebulan',
                    selected: _local.period == TxPeriod.month,
                    onTap: () {
                      final now = DateTime.now();
                      setState(() => _local = _local.copyWith(
                            period: TxPeriod.month,
                            selectedMonth: DateTime(now.year, now.month),
                          ));
                    },
                  ),
                ],
              ),

              // Week Picker
              if (_local.period == TxPeriod.week) ...[
                const SizedBox(height: 16),
                _SectionLabel(label: 'Pilih Minggu'),
                const SizedBox(height: 10),
                _WeekPicker(
                  selectedWeek: _local.selectedWeek ?? (() {
                    final now = DateTime.now();
                    return DateTime(now.year, now.month, now.day)
                        .subtract(Duration(days: now.weekday - 1));
                  })(),
                  onChanged: (week) => setState(
                      () => _local = _local.copyWith(selectedWeek: week)),
                ),
              ],

              // Month Picker
              if (_local.period == TxPeriod.month) ...[
                const SizedBox(height: 16),
                _SectionLabel(label: 'Pilih Bulan'),
                const SizedBox(height: 10),
                _MonthPicker(
                  selectedMonth: _local.selectedMonth ?? (() {
                    final now = DateTime.now();
                    return DateTime(now.year, now.month);
                  })(),
                  onChanged: (month) => setState(
                      () => _local = _local.copyWith(selectedMonth: month)),
                ),
              ],

              const SizedBox(height: 20),

              // ── Sort Field ───────────────────────────────────────────────
              _SectionLabel(label: 'Urutkan Berdasarkan'),
              const SizedBox(height: 10),
              Row(
                children: [
                  _PeriodChip(
                    label: 'Tanggal',
                    selected: _local.sortField == TxSortField.date,
                    onTap: () => setState(() => _local =
                        _local.copyWith(sortField: TxSortField.date)),
                  ),
                  const SizedBox(width: 8),
                  _PeriodChip(
                    label: 'Nominal',
                    selected: _local.sortField == TxSortField.amount,
                    onTap: () => setState(() => _local =
                        _local.copyWith(sortField: TxSortField.amount)),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Sort Direction ───────────────────────────────────────────
              _SectionLabel(label: 'Urutan'),
              const SizedBox(height: 10),
              Row(
                children: [
                  _PeriodChip(
                    label: '↓ Terbaru / Terbesar',
                    selected: _local.sortDir == TxSortDir.desc,
                    onTap: () => setState(
                        () => _local = _local.copyWith(sortDir: TxSortDir.desc)),
                  ),
                  const SizedBox(width: 8),
                  _PeriodChip(
                    label: '↑ Terlama / Terkecil',
                    selected: _local.sortDir == TxSortDir.asc,
                    onTap: () => setState(
                        () => _local = _local.copyWith(sortDir: TxSortDir.asc)),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── Apply Button ─────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _apply,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Terapkan Filter'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Week Picker ──────────────────────────────────────────────────────────────

class _WeekPicker extends StatefulWidget {
  final DateTime selectedWeek;
  final ValueChanged<DateTime> onChanged;

  const _WeekPicker({required this.selectedWeek, required this.onChanged});

  @override
  State<_WeekPicker> createState() => _WeekPickerState();
}

class _WeekPickerState extends State<_WeekPicker> {
  // The month/year context being browsed for week selection
  late DateTime _browseMonth;

  @override
  void initState() {
    super.initState();
    _browseMonth = DateTime(widget.selectedWeek.year, widget.selectedWeek.month);
  }

  /// Get all week-start Mondays that overlap with _browseMonth
  List<DateTime> get _weeksInMonth {
    final List<DateTime> weeks = [];
    // Start from the Monday of the first week overlapping this month
    DateTime d = DateTime(_browseMonth.year, _browseMonth.month, 1);
    d = d.subtract(Duration(days: d.weekday - 1)); // back to Monday
    while (d.month <= _browseMonth.month || d.year < _browseMonth.year) {
      if (d.isBefore(DateTime(_browseMonth.year, _browseMonth.month + 1, 1))) {
        weeks.add(d);
      }
      d = d.add(const Duration(days: 7));
      if (d.year > _browseMonth.year + 1) break;
    }
    return weeks;
  }

  @override
  Widget build(BuildContext context) {
    final weeks = _weeksInMonth;
    return Column(
      children: [
        // Month/Year Navigation Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => setState(() {
                _browseMonth = DateTime(_browseMonth.year, _browseMonth.month - 1);
              }),
              icon: const Icon(Icons.chevron_left_rounded),
              color: AppColors.textPrimary,
            ),
            Text(
              DateFormat('MMMM yyyy').format(_browseMonth),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            IconButton(
              onPressed: DateTime(_browseMonth.year, _browseMonth.month)
                          .isBefore(DateTime(DateTime.now().year, DateTime.now().month))
                  ? () => setState(() {
                      _browseMonth = DateTime(_browseMonth.year, _browseMonth.month + 1);
                    })
                  : null,
              icon: const Icon(Icons.chevron_right_rounded),
              color: AppColors.textPrimary,
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Week chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: weeks.map((weekStart) {
            final weekEnd = weekStart.add(const Duration(days: 6));
            final label =
                '${DateFormat('d MMM').format(weekStart)} – ${DateFormat('d MMM').format(weekEnd)}';
            final isSelected = widget.selectedWeek == weekStart;
            return _PeriodChip(
              label: label,
              selected: isSelected,
              onTap: () => widget.onChanged(weekStart),
              compact: true,
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ─── Month Picker ─────────────────────────────────────────────────────────────

class _MonthPicker extends StatefulWidget {
  final DateTime selectedMonth;
  final ValueChanged<DateTime> onChanged;

  const _MonthPicker({required this.selectedMonth, required this.onChanged});

  @override
  State<_MonthPicker> createState() => _MonthPickerState();
}

class _MonthPickerState extends State<_MonthPicker> {
  late int _browseYear;
  final int _minYear = DateTime.now().year - 3;

  @override
  void initState() {
    super.initState();
    _browseYear = widget.selectedMonth.year;
  }

  static const _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Column(
      children: [
        // Year Navigation Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: _browseYear > _minYear
                  ? () => setState(() => _browseYear--)
                  : null,
              icon: const Icon(Icons.chevron_left_rounded),
              color: AppColors.textPrimary,
            ),
            Text(
              '$_browseYear',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            IconButton(
              onPressed: _browseYear < now.year
                  ? () => setState(() => _browseYear++)
                  : null,
              icon: const Icon(Icons.chevron_right_rounded),
              color: AppColors.textPrimary,
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Month grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.2,
          ),
          itemCount: 12,
          itemBuilder: (context, i) {
            final month = i + 1;
            final isSelected = widget.selectedMonth.year == _browseYear &&
                widget.selectedMonth.month == month;
            final isFuture = _browseYear > now.year ||
                (_browseYear == now.year && month > now.month);
            return GestureDetector(
              onTap: isFuture
                  ? null
                  : () => widget.onChanged(DateTime(_browseYear, month)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryRed.withOpacity(0.08)
                      : isFuture
                          ? Colors.grey.shade50
                          : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryRed : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  _monthNames[i],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.primaryRed
                        : isFuture
                            ? Colors.grey.shade400
                            : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ─── Reusable Chip ────────────────────────────────────────────────────────────

class _PeriodChip extends StatelessWidget {

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 14,
          vertical: compact ? 7 : 9,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryRed.withOpacity(0.08)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.primaryRed : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: compact ? 12 : 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.primaryRed : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 13,
        color: AppColors.textSecondary,
        letterSpacing: 0.3,
      ),
    );
  }
}
