import 'package:flutter/material.dart';
import '../widgets/crop_result_sheet.dart';
import '../widgets/shared_widgets.dart';

class CropTab extends StatefulWidget {
  const CropTab({super.key});

  @override
  State<CropTab> createState() => _CropTabState();
}

class _CropTabState extends State<CropTab> {
  bool _isLoading = false;
  String _selectedCrop = '';

  final _crops = [
    {'name': 'Wheat', 'emoji': '🌾'},
    {'name': 'Rice', 'emoji': '🍚'},
    {'name': 'Cotton', 'emoji': '☁️'},
    {'name': 'Maize', 'emoji': '🌽'},
    {'name': 'Soybean', 'emoji': '🫘'},
    {'name': 'Tomato', 'emoji': '🍅'},
  ];

  Future<void> _analyze() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    setState(() => _isLoading = false);
    _showResult();
  }

  void _showResult() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CropResultSheet(
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          color: const Color(0xFF15803D),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.qr_code_scanner,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Crop Disease Scanner',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                  Text('AI-powered pest & disease detection',
                      style: TextStyle(
                          color: Color(0xFFBBF7D0), fontSize: 11)),
                ],
              ),
            ],
          ),
        ),

        // Body
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image upload
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('📷 Upload Crop Image',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF374151))),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          border: Border.all(
                              color: const Color(0xFFBBF7D0), width: 1.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius:
                                      BorderRadius.circular(16)),
                              child: const Icon(Icons.camera_alt_outlined,
                                  color: Color(0xFF15803D), size: 28),
                            ),
                            const SizedBox(height: 10),
                            const Text('Take or upload crop photo',
                                style: TextStyle(
                                    color: Color(0xFF14532D),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            const Text(
                                'Clear leaf/stem photos work best',
                                style: TextStyle(
                                    color: Color(0xFF22C55E),
                                    fontSize: 11)),
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                _GreenButton(
                                    icon: Icons.camera_alt_outlined,
                                    label: 'Camera',
                                    primary: true),
                                const SizedBox(width: 10),
                                _GreenButton(
                                    icon: Icons.photo_library_outlined,
                                    label: 'Gallery',
                                    primary: false),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Crop selector
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('🌾 Select Your Crop',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF374151))),
                      const SizedBox(height: 12),
                      GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1.1,
                        children: _crops.map((c) {
                          final isSelected =
                              _selectedCrop == c['name'];
                          return GestureDetector(
                            onTap: () => setState(
                                () => _selectedCrop = c['name']!),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFF0FDF4)
                                    : const Color(0xFFF9FAFB),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF22C55E)
                                      : const Color(0xFFE5E7EB),
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius:
                                    BorderRadius.circular(14),
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Text(c['emoji']!,
                                      style: const TextStyle(
                                          fontSize: 22)),
                                  const SizedBox(height: 4),
                                  Text(
                                    c['name']!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? const Color(0xFF15803D)
                                          : const Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // What AI Detects
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('🔍 What AI Detects',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF374151))),
                      const SizedBox(height: 10),
                      ...[
                        [
                          Icons.shield_outlined,
                          const Color(0xFFDC2626),
                          'Fungal & bacterial diseases (rust, blight, mildew)'
                        ],
                        [
                          Icons.warning_amber_outlined,
                          const Color(0xFFD97706),
                          'Pest infestations (aphids, bollworm, stem borer)'
                        ],
                        [
                          Icons.eco_outlined,
                          const Color(0xFF15803D),
                          'Nutrient deficiency symptoms on leaves'
                        ],
                        [
                          Icons.bar_chart,
                          const Color(0xFF3B82F6),
                          'Disease severity & spread risk level'
                        ],
                      ].map(
                        (d) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Icon(d[0] as IconData,
                                  color: d[1] as Color, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(d[2] as String,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF6B7280))),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Analyze button
                _isLoading
                    ? LoadingCard(
                        bgColor: const Color(0xFF15803D),
                        title: 'AI is scanning your crop...',
                        subtitle: 'Detecting diseases & pests',
                      )
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _analyze,
                          icon: const Icon(Icons.qr_code_scanner,
                              size: 18),
                          label: const Text('Scan Crop with AI'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF15803D),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 16),
                            textStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(16)),
                            elevation: 2,
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

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: child,
    );
  }
}

class _GreenButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool primary;

  const _GreenButton(
      {required this.icon, required this.label, required this.primary});

  @override
  Widget build(BuildContext context) {
    if (primary) {
      return ElevatedButton.icon(
        onPressed: () {},
        icon: Icon(icon, size: 14),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF15803D),
          foregroundColor: Colors.white,
          textStyle:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      );
    }
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 14),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF15803D),
        side: const BorderSide(color: Color(0xFF86EFAC)),
        textStyle:
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
