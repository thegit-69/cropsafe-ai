import 'package:flutter/material.dart';
import '../widgets/shared_widgets.dart';

class CropResultSheet extends StatelessWidget {
  final VoidCallback onClose;

  const CropResultSheet({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
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
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                        'Wheat · Just now',
                        style:
                            TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
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
          // Body
          Flexible(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Score
                  ScoreCard(
                    score: 38,
                    bgColor: const Color(0xFFFEF2F2),
                    borderColor: const Color(0xFFFECACA),
                    scoreColor: const Color(0xFFDC2626),
                    titleText: '⚠️ Leaf Rust Detected',
                    subtitleText: 'High severity · Act immediately',
                  ),
                  const SizedBox(height: 16),

                  // Detection details
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
                          'Detection Details',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF374151)),
                        ),
                        const SizedBox(height: 12),
                        ...[
                          ['Disease', 'Wheat Leaf Rust (Puccinia triticina)'],
                          ['Affected Area', '~35% of leaf surface'],
                          ['Stage', 'Early-Mid progression'],
                          ['Spread Risk', 'High — act within 48 hrs'],
                        ].map(
                          (d) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    d[0],
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF6B7280)),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    d[1],
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1F2937)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Recommendations
                  const Text(
                    'AI Recommendations',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF374151)),
                  ),
                  const SizedBox(height: 8),
                  const RecommendationCard(
                    emoji: '💊',
                    title: 'Apply Fungicide',
                    description:
                        'Spray Propiconazole 25% EC at 0.1% concentration immediately. Repeat after 15 days.',
                  ),
                  const SizedBox(height: 8),
                  const RecommendationCard(
                    emoji: '🌾',
                    title: 'Remove Infected Leaves',
                    description:
                        'Manually remove heavily infected leaves to prevent further spread.',
                  ),
                  const SizedBox(height: 8),
                  const RecommendationCard(
                    emoji: '🚫',
                    title: 'Avoid Overhead Irrigation',
                    description:
                        'Switch to drip irrigation — moisture promotes rust spread.',
                  ),
                  const SizedBox(height: 8),
                  const RecommendationCard(
                    emoji: '👁️',
                    title: 'Monitor Daily',
                    description:
                        'Check adjoining field sections daily for 2 weeks to catch spread.',
                  ),
                  const SizedBox(height: 16),

                  // Save button
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
