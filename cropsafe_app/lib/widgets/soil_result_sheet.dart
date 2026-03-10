// lib/widgets/soil_result_sheet.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/shared_widgets.dart';

class SoilResultSheet extends StatelessWidget {
  final SoilApiResult result;
  final VoidCallback onClose;

  const SoilResultSheet({
    super.key,
    required this.result,
    required this.onClose,
  });

  // ── Score color based on value ─────────────────────────────
  Color _getScoreColor() {
    if (result.score >= 85) return const Color(0xFF15803D);
    if (result.score >= 70) return const Color(0xFF16A34A);
    if (result.score >= 50) return const Color(0xFFD97706);
    if (result.score >= 30) return const Color(0xFFEA580C);
    return const Color(0xFFDC2626);
  }

  Color _getBgColor() {
    if (result.score >= 70) return const Color(0xFFF0FDF4);
    if (result.score >= 50) return const Color(0xFFFFFBEB);
    return const Color(0xFFFEF2F2);
  }

  Color _getBorderColor() {
    if (result.score >= 70) return const Color(0xFFBBF7D0);
    if (result.score >= 50) return const Color(0xFFFDE68A);
    return const Color(0xFFFECACA);
  }

  // ── Status chip colors ─────────────────────────────────────
  Color _statusBg(String status) {
    if (status == 'OK')           return const Color(0xFFDCFCE7);
    if (status.contains('High')) return const Color(0xFFFEF3C7);
    return const Color(0xFFFEE2E2);
  }

  Color _statusText(String status) {
    if (status == 'OK')           return const Color(0xFF15803D);
    if (status.contains('High')) return const Color(0xFFD97706);
    return const Color(0xFFDC2626);
  }

  @override
  Widget build(BuildContext context) {
    final scoreColor = _getScoreColor();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // ── Handle ─────────────────────────────────────────
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // ── Header ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 16),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Soil Analysis Result',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937)),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Just now',
                        style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF9CA3AF)),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onClose,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.close,
                        size: 18, color: Color(0xFF6B7280)),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),

          // ── Scrollable Body ────────────────────────────────
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Score Card ─────────────────────────────
                  ScoreCard(
                    score:       result.score,
                    bgColor:     _getBgColor(),
                    borderColor: _getBorderColor(),
                    scoreColor:  scoreColor,
                    titleText:   result.label,
                    subtitleText:
                        '${result.deficienciesCount} deficiencies detected by AI',
                  ),
                  const SizedBox(height: 16),

                  // ── Nutrient Breakdown ─────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border:
                          Border.all(color: const Color(0xFFF3F4F6)),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nutrient Breakdown',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF374151)),
                        ),
                        const SizedBox(height: 12),
                        ...result.breakdown.map((item) => Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 14),
                              child: _BreakdownRow(
                                item: item,
                                statusBg:
                                    _statusBg(item.status),
                                statusText:
                                    _statusText(item.status),
                              ),
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── AI Recommendations ─────────────────────
                  const Text(
                    'AI Recommendations',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF374151)),
                  ),
                  const SizedBox(height: 8),
                  ...result.recommendations
                      .asMap()
                      .entries
                      .map((entry) {
                    final emojis = [
                      '🌿', '🪱', '💧', '🌱', '📊', '⚗️', '🔬'
                    ];
                    final emoji =
                        emojis[entry.key % emojis.length];
                    final rec = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: RecommendationCard(
                        emoji: emoji,
                        title: rec.title,
                        description: rec.detail,
                      ),
                    );
                  }),
                  const SizedBox(height: 16),

                  // ── Save Button ────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onClose,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF15803D),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Save to History',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Breakdown Row Widget ───────────────────────────────────────
class _BreakdownRow extends StatelessWidget {
  final SoilBreakdownItem item;
  final Color statusBg;
  final Color statusText;

  const _BreakdownRow({
    required this.item,
    required this.statusBg,
    required this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    // Progress bar fill based on score out of 20
    final progress = (item.score / 20).clamp(0.0, 1.0);
    final barColor = item.status == 'OK'
        ? const Color(0xFF22C55E)
        : item.status.contains('High')
            ? const Color(0xFFFBBF24)
            : const Color(0xFFF87171);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // Label row
        Row(
          children: [
            Expanded(
              child: Text(
                item.parameter,
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF6B7280)),
              ),
            ),
            Text(
              '${item.value}${item.unit}',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937)),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(10)),
              child: Text(
                item.status,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: statusText),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFFF3F4F6),
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 3),

        // Ideal range
        Text(
          'Ideal: ${item.ideal}',
          style: const TextStyle(
              fontSize: 10, color: Color(0xFF9CA3AF)),
        ),
      ],
    );
  }
}