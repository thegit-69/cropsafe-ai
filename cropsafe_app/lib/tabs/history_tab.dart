import 'package:flutter/material.dart';
import '../models/data_models.dart';
import '../widgets/shared_widgets.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  String _activeFilter = 'All';

  List<HistoryItem> get _filtered {
    switch (_activeFilter) {
      case 'Soil Tests':
        return historyItems.where((i) => i.type == 'soil').toList();
      case 'Crop Scans':
        return historyItems.where((i) => i.type == 'crop').toList();
      case 'Critical':
        return historyItems.where((i) => i.severity == 'high').toList();
      default:
        return historyItems;
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Summary stats
                Row(
                  children: [
                    Expanded(
                        child: _StatBox(
                            value: '20',
                            label: 'Total',
                            color: const Color(0xFF1F2937))),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _StatBox(
                            value: '5',
                            label: 'Critical',
                            color: const Color(0xFFDC2626))),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _StatBox(
                            value: '6',
                            label: 'Resolved',
                            color: const Color(0xFF15803D))),
                  ],
                ),
                const SizedBox(height: 14),

                // History cards
                ..._filtered.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _HistoryCard(item: item),
                    )),

                // Load more
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        'Load More History',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280)),
                      ),
                    ),
                  ),
                ),
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
  const _HistoryCard({required this.item});

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
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right,
              size: 18, color: Color(0xFFD1D5DB)),
        ],
      ),
    );
  }
}
