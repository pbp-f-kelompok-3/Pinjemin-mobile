import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../models/transaction.dart';
import '../../services/auth_service.dart';
import '../../services/transaction_api.dart';
import '../../widgets/left_drawer.dart';
import '../../widgets/pinjemin_app_bar.dart';

enum _HistoryFilter { all, ongoing, completed, cancelled }

class DaftarTransaksiPage extends StatefulWidget {
  const DaftarTransaksiPage({super.key, this.api});

  /// Optional API injection keeps the page easy to test and preview.
  final TransactionApi? api;

  @override
  State<DaftarTransaksiPage> createState() => _DaftarTransaksiPageState();
}

class _DaftarTransaksiPageState extends State<DaftarTransaksiPage> {
  late final TransactionApi _api;
  late final bool _ownsApi;
  late Future<List<RentalTransaction>> _history;
  _HistoryFilter _filter = _HistoryFilter.all;

  @override
  void initState() {
    super.initState();
    _ownsApi = widget.api == null;
    _api = widget.api ?? TransactionApi(context.read<CookieRequest>());
    _history = _api.history();
  }

  @override
  void dispose() {
    if (_ownsApi) _api.close();
    super.dispose();
  }

  void _reload() => setState(() => _history = _api.history());

  List<RentalTransaction> _filtered(List<RentalTransaction> transactions) =>
      transactions.where((transaction) {
        return switch (_filter) {
          _HistoryFilter.all => true,
          _HistoryFilter.ongoing => transaction.isOngoing,
          _HistoryFilter.completed => transaction.isCompleted,
          _HistoryFilter.cancelled => transaction.isCancelled,
        };
      }).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PinjeminAppBar(title: 'Transaksi'),
      drawer: const LeftDrawer(),
      body: FutureBuilder<List<RentalTransaction>>(
        future: _history,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final error = snapshot.error;
            return _LoadError(
              message: error is ApiException
                  ? error.message
                  : kBadResponseMessage,
              onRetry: _reload,
            );
          }

          final transactions = snapshot.data ?? const <RentalTransaction>[];
          final visible = _filtered(transactions);
          return RefreshIndicator(
            onRefresh: () async {
              final future = _api.history();
              setState(() => _history = future);
              try {
                await future;
              } catch (_) {
                // FutureBuilder displays the request failure with a retry action.
              }
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: [
                Text(
                  'Riwayat transaksi',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Pantau status peminjamanmu dan transaksi barang yang kamu pinjamkan.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                _FilterBar(
                  selected: _filter,
                  onChanged: (filter) => setState(() => _filter = filter),
                ),
                const SizedBox(height: 16),
                if (transactions.isEmpty)
                  const _EmptyHistory()
                else if (visible.isEmpty)
                  _EmptyFilter(filter: _filter)
                else ...[
                  Text(
                    '${visible.length} transaksi',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 10),
                  for (final transaction in visible) ...[
                    _TransactionCard(
                      transaction: transaction,
                      onTap: () => _showDetails(transaction),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDetails(RentalTransaction transaction) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => _TransactionDetails(transaction: transaction),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onChanged});

  final _HistoryFilter selected;
  final ValueChanged<_HistoryFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    const labels = {
      _HistoryFilter.all: 'Semua',
      _HistoryFilter.ongoing: 'Berlangsung',
      _HistoryFilter.completed: 'Selesai',
      _HistoryFilter.cancelled: 'Dibatalkan',
    };
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _HistoryFilter.values.map((filter) {
          final active = selected == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(labels[filter]!),
              selected: active,
              onSelected: (_) => onChanged(filter),
              showCheckmark: false,
              selectedColor: PinjeminTheme.brandYellow,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: active
                    ? PinjeminTheme.brandYellow
                    : const Color(0xFFECE9EA),
              ),
              labelStyle: TextStyle(
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: PinjeminTheme.ink,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.transaction, required this.onTap});

  final RentalTransaction transaction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<PinjeminColors>()!;
    final statusColor = _statusColor(transaction.normalizedStatus, colors);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colors.softYellow.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.inventory_2_outlined),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.itemName,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Pesanan #${transaction.id}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusBadge(
                    label: transaction.statusLabel,
                    color: statusColor,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _dateRange(transaction.startDate, transaction.endDate) ??
                          'Dipesan ${_formatDate(transaction.createdAt) ?? '—'}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  if (transaction.total != null)
                    Text(
                      _formatRupiah(transaction.total!),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.schedule_outlined, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      transaction.paymentStatus == null
                          ? 'Dibuat ${_formatDate(transaction.createdAt) ?? '—'}'
                          : 'Pembayaran: ${_paymentLabel(transaction.paymentStatus!)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  Text(
                    'Detail',
                    style: theme.textTheme.labelLarge?.copyWith(fontSize: 13),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.chevron_right, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      label,
      style: Theme.of(context).textTheme.labelSmall
          ?.copyWith(color: color, fontWeight: FontWeight.w700),
    ),
  );
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 44),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba lagi'),
          ),
        ],
      ),
    ),
  );
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 56, horizontal: 24),
    child: Column(
      children: [
        Icon(Icons.receipt_long_outlined, size: 52, color: Color(0xFF8A8A8A)),
        SizedBox(height: 12),
        Text(
          'Belum ada transaksi',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 4),
        Text(
          'Transaksi peminjaman dan barang yang kamu pinjamkan akan muncul di sini.',
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

class _EmptyFilter extends StatelessWidget {
  const _EmptyFilter({required this.filter});

  final _HistoryFilter filter;

  @override
  Widget build(BuildContext context) {
    final label = switch (filter) {
      _HistoryFilter.all => 'transaksi',
      _HistoryFilter.ongoing => 'transaksi yang sedang berlangsung',
      _HistoryFilter.completed => 'transaksi selesai',
      _HistoryFilter.cancelled => 'transaksi yang dibatalkan',
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Text('Tidak ada $label.', textAlign: TextAlign.center),
    );
  }
}

class _TransactionDetails extends StatelessWidget {
  const _TransactionDetails({required this.transaction});

  final RentalTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Detail transaksi', style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Pesanan #${transaction.id}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 18),
            _DetailRow(label: 'Barang', value: transaction.itemName),
            _DetailRow(label: 'Status', value: transaction.statusLabel),
            if (transaction.paymentStatus != null)
              _DetailRow(
                label: 'Pembayaran',
                value: _paymentLabel(transaction.paymentStatus!),
              ),
            if (transaction.partnerName != null)
              _DetailRow(label: 'Dengan', value: transaction.partnerName!),
            if (transaction.startDate != null || transaction.endDate != null)
              _DetailRow(
                label: 'Jadwal',
                value: _dateRange(transaction.startDate, transaction.endDate)!,
              ),
            if (transaction.pickupLocation != null)
              _DetailRow(
                label: 'Titik jemput',
                value: transaction.pickupLocation!,
              ),
            _DetailRow(
              label: 'Tanggal pesanan',
              value: _formatDate(transaction.createdAt) ?? '—',
            ),
            if (transaction.total != null)
              _DetailRow(
                label: 'Total biaya',
                value: _formatRupiah(transaction.total!),
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 124,
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        Expanded(
          child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    ),
  );
}

Color _statusColor(String status, PinjeminColors colors) => switch (status) {
  'completed' => colors.positive,
  'cancelled' || 'rejected' => const Color(0xFFC4161C),
  'active' || 'approved' => const Color(0xFF1976D2),
  _ => const Color(0xFF9A6700),
};

String _paymentLabel(String status) {
  final normalized = status.trim().toLowerCase();
  return switch (normalized) {
    'paid' || 'lunas' || 'berhasil' || 'success' => 'Lunas',
    'pending' || 'menunggu' || 'belum_dibayar' => 'Menunggu pembayaran',
    'failed' || 'gagal' => 'Gagal',
    'refunded' || 'dikembalikan' => 'Dikembalikan',
    _ => status,
  };
}

String? _dateRange(DateTime? start, DateTime? end) {
  if (start == null && end == null) return null;
  if (start == null) return 'Sampai ${_formatDate(end)}';
  if (end == null) return 'Mulai ${_formatDate(start)}';
  return '${_formatDate(start)} – ${_formatDate(end)}';
}

String? _formatDate(DateTime? date) {
  if (date == null) return null;
  final local = date.toLocal();
  return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
}

String _formatRupiah(num amount) {
  final digits = amount.round().toString();
  final grouped = digits.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
  return 'Rp $grouped';
}
