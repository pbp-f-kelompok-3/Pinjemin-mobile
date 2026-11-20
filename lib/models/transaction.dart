class RentalTransaction {
  const RentalTransaction({
    required this.id,
    required this.itemName,
    required this.status,
    this.paymentStatus,
    this.createdAt,
    this.startDate,
    this.endDate,
    this.total,
    this.pickupLocation,
    this.partnerName,
  });

  factory RentalTransaction.fromJson(Map<String, dynamic> json) {
    final item = _asMap(_first(json, ['item', 'barang', 'product']));
    final owner = _asMap(_first(json, ['owner', 'pemilik']));
    final renter = _asMap(_first(json, ['renter', 'peminjam']));
    final partner =
        _first(json, ['partner_name', 'nama_lawan_transaksi']) ??
        item?['owner_name'] ??
        owner?['name'] ??
        renter?['name'];

    return RentalTransaction(
      id: '${_first(json, ['id', 'order_id', 'kode_pesanan']) ?? '-'}',
      itemName:
          '${_first(json, ['item_name', 'barang_nama', 'nama_barang', 'title', 'name']) ?? item?['name'] ?? item?['nama'] ?? 'Barang Pinjemin'}',
      status:
          '${_first(json, ['status', 'order_status', 'status_pesanan']) ?? 'menunggu'}',
      paymentStatus: _stringOrNull(
        _first(json, [
          'payment_status',
          'status_pembayaran',
          'pembayaran_status',
        ]),
      ),
      createdAt: _dateTimeOrNull(
        _first(json, ['created_at', 'tanggal_pesan', 'ordered_at']),
      ),
      startDate: _dateTimeOrNull(
        _first(json, ['start_date', 'tanggal_mulai', 'tanggal_pinjam']),
      ),
      endDate: _dateTimeOrNull(
        _first(json, ['end_date', 'tanggal_selesai', 'tanggal_kembali']),
      ),
      total: _numberOrNull(
        _first(json, ['total', 'total_price', 'total_harga', 'biaya_total']),
      ),
      pickupLocation: _stringOrNull(
        _first(json, [
              'pickup_location',
              'pickup_name',
              'lokasi_penjemputan',
            ]) ??
            _asMap(json['pickup'])?['label'],
      ),
      partnerName: partner == null ? null : '$partner',
    );
  }

  final String id;
  final String itemName;
  final String status;
  final String? paymentStatus;
  final DateTime? createdAt;
  final DateTime? startDate;
  final DateTime? endDate;
  final num? total;
  final String? pickupLocation;
  final String? partnerName;

  String get normalizedStatus => _normalize(status);

  String get statusLabel => switch (normalizedStatus) {
    'pending' || 'waiting' => 'Menunggu',
    'approved' => 'Disetujui',
    'active' => 'Berlangsung',
    'completed' => 'Selesai',
    'cancelled' => 'Dibatalkan',
    'rejected' => 'Ditolak',
    _ => status.isEmpty ? 'Menunggu' : status,
  };

  bool get isOngoing => const {
    'pending',
    'waiting',
    'approved',
    'active',
  }.contains(normalizedStatus);
  bool get isCompleted => normalizedStatus == 'completed';
  bool get isCancelled =>
      const {'cancelled', 'rejected'}.contains(normalizedStatus);
}

Object? _first(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value != null && value != '') return value;
  }
  return null;
}

Map<String, dynamic>? _asMap(Object? value) =>
    value is Map<String, dynamic> ? value : null;

String? _stringOrNull(Object? value) =>
    value == null || value.toString().trim().isEmpty ? null : value.toString();

DateTime? _dateTimeOrNull(Object? value) {
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

num? _numberOrNull(Object? value) {
  if (value is num) return value;
  if (value is String) {
    final normalized = value
        .replaceAll(RegExp(r'[^0-9,.-]'), '')
        .replaceAll(',', '.');
    return num.tryParse(normalized);
  }
  return null;
}

String _normalize(String value) {
  final status = value.trim().toLowerCase().replaceAll(RegExp(r'[\s-]+'), '_');
  return switch (status) {
    'menunggu' ||
    'pending' ||
    'requested' ||
    'menunggu_pembayaran' => 'pending',
    'waiting' || 'menunggu_persetujuan' => 'waiting',
    'disetujui' || 'approved' || 'accepted' || 'confirmed' => 'approved',
    'berlangsung' || 'active' || 'ongoing' || 'dipinjam' => 'active',
    'selesai' || 'completed' || 'returned' => 'completed',
    'dibatalkan' || 'cancelled' || 'canceled' => 'cancelled',
    'ditolak' || 'rejected' => 'rejected',
    _ => status,
  };
}
