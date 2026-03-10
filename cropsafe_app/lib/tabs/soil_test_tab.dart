import 'package:flutter/material.dart';
import '../widgets/soil_result_sheet.dart';
import '../widgets/shared_widgets.dart';

class SoilTestTab extends StatefulWidget {
  const SoilTestTab({super.key});

  @override
  State<SoilTestTab> createState() => _SoilTestTabState();
}

class _SoilTestTabState extends State<SoilTestTab> {
  bool _isLoading = false;
  final _phCtrl = TextEditingController();
  final _nitrogenCtrl = TextEditingController();
  final _phosphorusCtrl = TextEditingController();
  final _potassiumCtrl = TextEditingController();
  final _moistureCtrl = TextEditingController();

  Future<void> _analyze() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isLoading = false);
    _showResult();
  }

  void _showResult() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SoilResultSheet(
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
          color: const Color(0xFFD97706),
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
                child: const Icon(Icons.science_outlined,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Soil Test',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                  Text('AI Nutrient & Deficiency Analysis',
                      style: TextStyle(
                          color: Color(0xFFFDE68A), fontSize: 11)),
                ],
              ),
            ],
          ),
        ),

        // Scrollable body
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Photo upload card
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('📸 Upload Soil Report Photo',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF374151))),
                      const SizedBox(height: 4),
                      const Text(
                          'Take a photo of your lab soil report — AI will extract values automatically',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF9CA3AF))),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 28),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          border: Border.all(
                              color: const Color(0xFFFDE68A),
                              style: BorderStyle.solid,
                              width: 1.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(16)),
                              child: const Icon(Icons.camera_alt_outlined,
                                  color: Color(0xFFD97706), size: 26),
                            ),
                            const SizedBox(height: 8),
                            const Text('Tap to upload or take photo',
                                style: TextStyle(
                                    color: Color(0xFF92400E),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            const Text('JPG, PNG or PDF supported',
                                style: TextStyle(
                                    color: Color(0xFFD97706), fontSize: 11)),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _UploadButton(
                                    icon: Icons.camera_alt_outlined,
                                    label: 'Camera',
                                    primary: true),
                                const SizedBox(width: 10),
                                _UploadButton(
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

                // Divider
                Row(
                  children: const [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('OR enter manually',
                          style: TextStyle(
                              fontSize: 11, color: Color(0xFF9CA3AF))),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),

                // Manual input
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('🧪 Enter Soil Values',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF374151))),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                              child: _InputField(
                                  label: 'pH Level',
                                  hint: 'e.g. 6.8',
                                  ctrl: _phCtrl)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _InputField(
                                  label: 'Nitrogen (N)',
                                  hint: 'e.g. 42',
                                  unit: 'kg/ha',
                                  ctrl: _nitrogenCtrl)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                              child: _InputField(
                                  label: 'Phosphorus (P)',
                                  hint: 'e.g. 68',
                                  unit: 'kg/ha',
                                  ctrl: _phosphorusCtrl)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _InputField(
                                  label: 'Potassium (K)',
                                  hint: 'e.g. 85',
                                  unit: 'kg/ha',
                                  ctrl: _potassiumCtrl)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _InputField(
                          label: 'Soil Moisture (%)',
                          hint: 'e.g. 45',
                          ctrl: _moistureCtrl),
                      const SizedBox(height: 12),
                      const Text('Select Field',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280))),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          border:
                              Border.all(color: const Color(0xFFE5E7EB)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          underline: const SizedBox(),
                          hint: const Text('Choose field...',
                              style: TextStyle(
                                  fontSize: 13, color: Color(0xFF9CA3AF))),
                          items: const [
                            DropdownMenuItem(
                                value: 'a',
                                child:
                                    Text('Field A — Wheat (5 acres)')),
                            DropdownMenuItem(
                                value: 'b',
                                child:
                                    Text('Field B — Rice (3.5 acres)')),
                            DropdownMenuItem(
                                value: 'c',
                                child: Text(
                                    'Field C — Cotton (7 acres)')),
                          ],
                          onChanged: (_) {},
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Analyze button / loading
                _isLoading
                    ? LoadingCard(
                        bgColor: const Color(0xFFD97706),
                        title: 'AI is analyzing your soil data...',
                        subtitle: 'Detecting nutrient deficiencies',
                      )
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _analyze,
                          icon: const Icon(Icons.science_outlined,
                              size: 18),
                          label: const Text('Analyze Soil with AI'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD97706),
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            elevation: 2,
                          ),
                        ),
                      ),
                const SizedBox(height: 16),

                // Info banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.info_outline,
                          color: Color(0xFF3B82F6), size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Our AI detects nitrogen, phosphorus, potassium deficiencies and provides fertilizer recommendations tailored to your crop and region.',
                          style: TextStyle(
                              color: Color(0xFF1D4ED8),
                              fontSize: 12,
                              height: 1.4),
                        ),
                      ),
                    ],
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

class _UploadButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool primary;

  const _UploadButton(
      {required this.icon, required this.label, required this.primary});

  @override
  Widget build(BuildContext context) {
    if (primary) {
      return ElevatedButton.icon(
        onPressed: () {},
        icon: Icon(icon, size: 14),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD97706),
          foregroundColor: Colors.white,
          textStyle:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      );
    }
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 14),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFD97706),
        side: const BorderSide(color: Color(0xFFFDE68A)),
        textStyle:
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final String hint;
  final String unit;
  final TextEditingController ctrl;

  const _InputField({
    required this.label,
    required this.hint,
    this.unit = '',
    required this.ctrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280))),
        const SizedBox(height: 4),
        TextFormField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hint,
            suffixText: unit.isNotEmpty ? unit : null,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFFD97706), width: 2),
            ),
            hintStyle: const TextStyle(
                fontSize: 13, color: Color(0xFF9CA3AF)),
          ),
          style: const TextStyle(fontSize: 13, color: Color(0xFF1F2937)),
        ),
      ],
    );
  }
}
