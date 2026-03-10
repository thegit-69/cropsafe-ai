// lib/widgets/crop_result_sheet.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/shared_widgets.dart';

class CropResultSheet extends StatelessWidget {
  final CropApiResult result;
  final VoidCallback onClose;

  const CropResultSheet({
    super.key,
    required this.result,
    required this.onClose,
  });

  // ── Map disease name to score and severity ─────────────────
  int _getScore() {
    switch (result.disease) {
      case 'Healthy':        return 95;
      case 'Powdery Mildew': return 60;
      case 'Leaf Spot':      return 50;
      case 'Rust':           return 40;
      case 'Blight':         return 25;
      default:               return 50;
    }
  }

  String _getSeverity() {
    final score = _getScore();
    if (score >= 80) return 'Healthy — No action needed';
    if (score >= 50) return 'Moderate severity — Monitor closely';
    return 'High severity — Act immediately';
  }

  Color _getScoreColor() {
    final score = _getScore();
    if (score >= 80) return const Color(0xFF15803D);
    if (score >= 50) return const Color(0xFFD97706);
    return const Color(0xFFDC2626);
  }

  Color _getBgColor() {
    final score = _getScore();
    if (score >= 80) return const Color(0xFFF0FDF4);
    if (score >= 50) return const Color(0xFFFFFBEB);
    return const Color(0xFFFEF2F2);
  }

  Color _getBorderColor() {
    final score = _getScore();
    if (score >= 80) return const Color(0xFFBBF7D0);
    if (score >= 50) return const Color(0xFFFDE68A);
    return const Color(0xFFFECACA);
  }

  String _getTitleEmoji() {
    if (result.disease == 'Healthy') return 'Crop is Healthy';
    return '${result.disease} Detected';
  }

  // ── Map confidence to percentage string ────────────────────
  String get _confidencePercent =>
      '${(result.confidence * 100).toStringAsFixed(0)}%';

  @override
  Widget build(BuildContext context) {
    final score      = _getScore();
    final scoreColor = _getScoreColor();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Crop Scan Result',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937)),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Just now',
                        style: TextStyle(
                            fontSize: 11, color: Color(0xFF9CA3AF)),
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
                    score:       score,
                    bgColor:     _getBgColor(),
                    borderColor: _getBorderColor(),
                    scoreColor:  scoreColor,
                    titleText:   _getTitleEmoji(),
                    subtitleText: _getSeverity(),
                  ),
                  const SizedBox(height: 16),

                  // ── Detection Details ──────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFF3F4F6)),
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
                          'Detection Details',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF374151)),
                        ),
                        const SizedBox(height: 12),
                        _DetailRow(
                          label: 'Disease',
                          value: result.disease,
                        ),
                        _DetailRow(
                          label: 'Confidence',
                          value: _confidencePercent,
                        ),
                        _DetailRow(
                          label: 'Severity',
                          value: _getSeverity().split(' — ')[0],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── AI Recommendation ──────────────────────
                  const Text(
                    'AI Recommendation',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF374151)),
                  ),
                  const SizedBox(height: 8),

                  RecommendationCard(
                    emoji: result.disease == 'Healthy' ? '✅' : '💊',
                    title: result.disease == 'Healthy'
                        ? 'Crop is Healthy'
                        : 'Treatment Required',
                    description: result.recommendation,
                  ),
                  const SizedBox(height: 16),

                  // ── Confidence Bar ─────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'AI Confidence',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280)),
                            ),
                            Text(
                              _confidencePercent,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: scoreColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: result.confidence,
                            backgroundColor: const Color(0xFFE5E7EB),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(scoreColor),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Save Button ────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onClose,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF15803D),
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Save to History',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700),
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

// ── Detail Row Widget ──────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937)),
          ),
        ],
      ),
    );
  }
}