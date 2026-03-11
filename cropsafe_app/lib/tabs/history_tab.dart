import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../models/data_models.dart';
import '../services/firestore_service.dart';
import '../widgets/shared_widgets.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  String _activeFilter = 'All';
  final _firestoreService = FirestoreService();

  List<SoilTestResult> _soilTests = [];
  List<CropScanResult> _cropScans = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _firestoreService.getSoilTests().listen((data) {
      if (mounted) setState(() { _soilTests = data; _loading = false; });
    });
    _firestoreService.getCropScans().listen((data) {
      if (mounted) setState(() { _cropScans = data; _loading = false; });
    });
  }

  // ── Convert Firestore models to display HistoryItems ──────
  List<HistoryItem> get _allItems {
    final items = <HistoryItem>[];

    var id = 1;
    for (final s in _soilTests) {
      final severity = s.score >= 70 ? 'low' : (s.score >= 50 ? 'medium' : 'high');
      items.add(HistoryItem(
        id: id++,
        firestoreId: s.id,
        type: 'soil',
        title: 'Soil Test',
        date: _formatDate(s.createdAt),
        time: _formatTime(s.createdAt),
        status: s.label,
        severity: severity,
        score: s.score,
        createdAt: s.createdAt,
      ));
    }

    for (final c in _cropScans) {
      final score = _cropScore(c.disease);
      final severity = score >= 80 ? 'low' : (score >= 50 ? 'medium' : 'high');
      items.add(HistoryItem(
        id: id++,
        firestoreId: c.id,
        type: 'crop',
        title: 'Crop Scan',
        date: _formatDate(c.createdAt),
        time: _formatTime(c.createdAt),
        status: c.disease == 'Healthy' ? 'Healthy Crop' : '${c.disease} Detected',
        severity: severity,
        score: score,
        createdAt: c.createdAt,
      ));
    }

    // Sort newest first by actual timestamp
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  int _cropScore(String disease) {
    switch (disease) {
      case 'Healthy':        return 95;
      case 'Powdery Mildew': return 60;
      case 'Leaf Spot':      return 50;
      case 'Rust':           return 40;
      case 'Blight':         return 25;
      default:               return 50;
    }
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $ampm';
  }

  // ── Delete a history item from Firestore ─────────────────
  Future<void> _deleteItem(HistoryItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Entry',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700)),
        content: Text(
          'Delete this ${item.type == 'soil' ? 'soil test' : 'crop scan'} record? This cannot be undone.',
          style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF6B7280))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(
                    color: Color(0xFFDC2626),
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (item.type == 'soil') {
      await _firestoreService.deleteSoilTest(item.firestoreId);
    } else {
      final cropScan = _cropScans
          .where((c) => c.id == item.firestoreId)
          .firstOrNull;
      await _firestoreService.deleteCropScan(
        item.firestoreId,
        imageUrl: cropScan?.imageUrl,
      );
    }
  }

  List<HistoryItem> get _filtered {
    final all = _allItems;
    switch (_activeFilter) {
      case 'Soil Tests': return all.where((i) => i.type == 'soil').toList();
      case 'Crop Scans': return all.where((i) => i.type == 'crop').toList();
      case 'Critical':   return all.where((i) => i.severity == 'high').toList();
      default:           return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          color: const Color(0xFF1F2937),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.history,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Analysis History',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                      Text('All your previous uploads & results',
                          style: TextStyle(
                              color: Color(0xFF9CA3AF), fontSize: 11)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Filter pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'Soil Tests', 'Crop Scans', 'Critical']
                      .map((f) {
                    final active = _activeFilter == f;
                    return GestureDetector(
                      onTap: () => setState(() => _activeFilter = f),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: active
                              ? Colors.white
                              : Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: active
                                ? Colors.white
                                : Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          f,
                          style: TextStyle(
                            color: active
                                ? const Color(0xFF1F2937)
                                : Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // Body
        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF15803D)),
                )
              : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Summary stats (real counts)
                Row(
                  children: [
                    Expanded(
                        child: _StatBox(
                            value: _allItems.length.toString(),
                            label: 'Total',
                            color: const Color(0xFF1F2937))),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _StatBox(
                            value: _allItems
                                .where((i) => i.severity == 'high')
                                .length
                                .toString(),
                            label: 'Critical',
                            color: const Color(0xFFDC2626))),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _StatBox(
                            value: _allItems
                                .where((i) => i.severity == 'low')
                                .length
                                .toString(),
                            label: 'Healthy',
                            color: const Color(0xFF15803D))),
                  ],
                ),
                const SizedBox(height: 14),

                // Empty state
                if (_filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        const Icon(Icons.history, size: 48, color: Color(0xFFD1D5DB)),
                        const SizedBox(height: 12),
                        Text(
                          _activeFilter == 'All'
                              ? 'No analysis yet.\nRun a Soil Test or Crop Scan to see results here.'
                              : 'No ${_activeFilter.toLowerCase()} found.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xFF9CA3AF)),
                        ),
                      ],
                    ),
                  ),

                // History cards
                ..._filtered.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _HistoryCard(
                        item: item,
                        onDelete: () => _deleteItem(item),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatBox(
      {required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFF9CA3AF))),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final HistoryItem item;
  final VoidCallback onDelete;
  const _HistoryCard({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isSoil = item.type == 'soil';
    final iconBg = isSoil
        ? const Color(0xFFFEF3C7)
        : const Color(0xFFDCFCE7);
    final iconColor = isSoil
        ? const Color(0xFFD97706)
        : const Color(0xFF15803D);
    final iconLabel = isSoil ? 'SOIL' : 'CROP';

    Color statusColor;
    switch (item.severity) {
      case 'high':
        statusColor = const Color(0xFFDC2626);
        break;
      case 'medium':
        statusColor = const Color(0xFFD97706);
        break;
      default:
        statusColor = const Color(0xFF15803D);
    }

    Color barColor;
    if (item.score > 80) {
      barColor = const Color(0xFF22C55E);
    } else if (item.score > 50) {
      barColor = const Color(0xFFFBBF24);
    } else {
      barColor = const Color(0xFFF87171);
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          // Icon block
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(14)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isSoil ? Icons.science_outlined : Icons.qr_code_scanner,
                  color: iconColor,
                  size: 20,
                ),
                const SizedBox(height: 2),
                Text(
                  iconLabel,
                  style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: iconColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SeverityBadge(severity: item.severity),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  item.status,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 11, color: Color(0xFF9CA3AF)),
                    const SizedBox(width: 4),
                    Text(
                      '${item.date} · ${item.time}',
                      style: const TextStyle(
                          fontSize: 10, color: Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: item.score / 100,
                          backgroundColor: const Color(0xFFF3F4F6),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(barColor),
                          minHeight: 5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${item.score}/100',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline,
                size: 20, color: Color(0xFFDC2626)),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
}
