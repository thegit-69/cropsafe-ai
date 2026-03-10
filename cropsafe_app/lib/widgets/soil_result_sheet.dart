import 'package:flutter/material.dart';
import '../models/data_models.dart';
import '../widgets/shared_widgets.dart';

class SoilResultSheet extends StatelessWidget {
  final VoidCallback onClose;

  const SoilResultSheet({super.key, required this.onClose});

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
          // Handle bar
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
                        'Soil Analysis Result',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937)),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Field A · Just now',
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
          // Scrollable body
          Flexible(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Score card
                  ScoreCard(
                    score: 62,
                    bgColor: const Color(0xFFFFFBEB),
                    borderColor: const Color(0xFFFDE68A),
                    scoreColor: const Color(0xFFD97706),
                    titleText: 'Moderate Soil Health',
                    subtitleText: '2 deficiencies detected by AI',
                  ),
                  const SizedBox(height: 16),

                  // Nutrient Breakdown
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
                          'Nutrient Breakdown',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF374151)),
                        ),
                        const SizedBox(height: 12),
                        ...soilNutrients.map((n) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: NutrientBar(
                                label: n.label,
                                value: n.value,
                                unit: n.unit,
                                ideal: n.ideal,
                                status: n.status,
                              ),
                            )),
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
                    emoji: '🌿',
                    title: 'Apply Urea Fertilizer',
                    description:
                        'Add 40 kg/ha urea to fix nitrogen deficiency before next irrigation cycle.',
                  ),
                  const SizedBox(height: 8),
                  const RecommendationCard(
                    emoji: '🪱',
                    title: 'Add Organic Matter',
                    description:
                        'Mix vermicompost or farmyard manure at 5 tonnes/ha to improve soil structure.',
                  ),
                  const SizedBox(height: 8),
                  const RecommendationCard(
                    emoji: '💧',
                    title: 'Irrigation Timing',
                    description:
                        'Irrigate within 48 hrs of applying fertilizer for better absorption.',
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
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
