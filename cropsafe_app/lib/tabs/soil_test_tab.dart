// lib/tabs/soil_test_tab.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../services/ocr_service.dart';
import '../widgets/soil_result_sheet.dart';
import '../widgets/shared_widgets.dart';

class SoilTestTab extends StatefulWidget {
  const SoilTestTab({super.key});

  @override
  State<SoilTestTab> createState() => _SoilTestTabState();
}

class _SoilTestTabState extends State<SoilTestTab> {
  bool _isLoading = false;
  bool _isScanning = false;
  String? _errorMessage;
  String? _successMessage;
  String? _selectedField;
  File? _scannedImage;

  final _phCtrl = TextEditingController();
  final _nitrogenCtrl = TextEditingController();
  final _phosphorusCtrl = TextEditingController();
  final _potassiumCtrl = TextEditingController();
  final _moistureCtrl = TextEditingController();

  @override
  void dispose() {
    _phCtrl.dispose();
    _nitrogenCtrl.dispose();
    _phosphorusCtrl.dispose();
    _potassiumCtrl.dispose();
    _moistureCtrl.dispose();
    super.dispose();
  }

  // ── Pick image and run OCR ─────────────────────────────────
  Future<void> _pickAndScan(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 2048,
      maxHeight: 2048,
    );
    if (picked == null) return;

    final file = File(picked.path);
    setState(() {
      _isScanning = true;
      _errorMessage = null;
      _successMessage = null;
      _scannedImage = file;
    });

    try {
      final result = await OcrService.extractSoilValues(file);
      if (!mounted) return;

      if (!result.hasAnyValue) {
        setState(() {
          _isScanning = false;
          _errorMessage =
              'Could not detect soil values from this image. '
              'Try a clearer photo or enter values manually.';
        });
        return;
      }

      // Auto-fill the fields
      if (result.ph != null) _phCtrl.text = result.ph!.toString();
      if (result.nitrogen != null) {
        _nitrogenCtrl.text = result.nitrogen!.toString();
      }
      if (result.phosphorus != null) {
        _phosphorusCtrl.text = result.phosphorus!.toString();
      }
      if (result.potassium != null) {
        _potassiumCtrl.text = result.potassium!.toString();
      }
      if (result.moisture != null) {
        _moistureCtrl.text = result.moisture!.toString();
      }

      final missing = 5 - result.fieldsFound;
      setState(() {
        _isScanning = false;
        _successMessage = missing == 0
            ? 'All ${result.fieldsFound} values extracted successfully!'
            : '${result.fieldsFound}/5 values extracted. Fill remaining fields manually.';
      });
    } on OcrException catch (e) {
      if (!mounted) return;
      setState(() {
        _isScanning = false;
        _errorMessage = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isScanning = false;
        _errorMessage =
            'Scan failed. Please try again or enter values manually.';
      });
    }
  }

  // ── Validate, parse, call API ──────────────────────────────
  Future<void> _analyze() async {
    // Validate all fields filled
    final fields = {
      'pH Level': _phCtrl.text.trim(),
      'Nitrogen': _nitrogenCtrl.text.trim(),
      'Phosphorus': _phosphorusCtrl.text.trim(),
      'Potassium': _potassiumCtrl.text.trim(),
      'Moisture': _moistureCtrl.text.trim(),
    };

    for (final entry in fields.entries) {
      if (entry.value.isEmpty) {
        setState(
          () => _errorMessage =
              '${entry.key} is required. Please fill all fields.',
        );
        return;
      }
    }

    // Parse to numbers
    final ph = double.tryParse(_phCtrl.text.trim());
    final nitrogen = double.tryParse(_nitrogenCtrl.text.trim());
    final phosphorus = double.tryParse(_phosphorusCtrl.text.trim());
    final potassium = double.tryParse(_potassiumCtrl.text.trim());
    final moisture = double.tryParse(_moistureCtrl.text.trim());

    if (ph == null ||
        nitrogen == null ||
        phosphorus == null ||
        potassium == null ||
        moisture == null) {
      setState(() => _errorMessage = 'Please enter valid numbers only.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Call FastAPI
    try {
      final result = await ApiService.analyzeSoil(
        nitrogen: nitrogen,
        phosphorus: phosphorus,
        potassium: potassium,
        ph: ph,
        moisture: moisture,
      );

      if (!mounted) return;

      // Show result immediately — Firebase save runs in background
      setState(() => _isLoading = false);
      _showResult(result);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Analysis failed. Make sure the server is running.';
      });
    }
  }

  // ── Show result sheet ──────────────────────────────────────
  void _showResult(SoilApiResult result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SoilResultSheet(
        result: result,
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Header ─────────────────────────────────────────
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
                child: const Icon(
                  Icons.science_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Soil Test',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'AI Nutrient and Deficiency Analysis',
                    style: TextStyle(color: Color(0xFFFDE68A), fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Body ───────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Photo Upload Card ──────────────────────
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📸 Upload Soil Report Photo',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Take a photo of your lab soil report — AI will extract values automatically',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _isScanning
                          ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 36),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFBEB),
                                border: Border.all(
                                  color: const Color(0xFFFDE68A),
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Column(
                                children: [
                                  SizedBox(
                                    width: 36,
                                    height: 36,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFFD97706),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'Analyzing report with Gemini AI...',
                                    style: TextStyle(
                                      color: Color(0xFF92400E),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Extracting pH, N, P, K, Moisture',
                                    style: TextStyle(
                                      color: Color(0xFFD97706),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 28),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFBEB),
                                border: Border.all(
                                  color: const Color(0xFFFDE68A),
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  if (_scannedImage != null) ...[
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        _scannedImage!,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                  ] else ...[
                                    Container(
                                      width: 52,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF3C7),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt_outlined,
                                        color: Color(0xFFD97706),
                                        size: 26,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                  Text(
                                    _scannedImage != null
                                        ? 'Scan another report'
                                        : 'Tap to upload or take photo',
                                    style: const TextStyle(
                                      color: Color(0xFF92400E),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'JPG or PNG supported',
                                    style: TextStyle(
                                      color: Color(0xFFD97706),
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _UploadButton(
                                        icon: Icons.camera_alt_outlined,
                                        label: 'Camera',
                                        primary: true,
                                        onTap: () =>
                                            _pickAndScan(ImageSource.camera),
                                      ),
                                      const SizedBox(width: 10),
                                      _UploadButton(
                                        icon: Icons.photo_library_outlined,
                                        label: 'Gallery',
                                        primary: false,
                                        onTap: () =>
                                            _pickAndScan(ImageSource.gallery),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Divider ────────────────────────────────
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'OR enter manually',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Manual Input ───────────────────────────
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🧪 Enter Soil Values',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _InputField(
                              label: 'pH Level',
                              hint: 'e.g. 6.8',
                              ctrl: _phCtrl,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InputField(
                              label: 'Nitrogen (N)',
                              hint: 'e.g. 42',
                              unit: 'kg/ha',
                              ctrl: _nitrogenCtrl,
                            ),
                          ),
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
                              ctrl: _phosphorusCtrl,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InputField(
                              label: 'Potassium (K)',
                              hint: 'e.g. 85',
                              unit: 'kg/ha',
                              ctrl: _potassiumCtrl,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _InputField(
                        label: 'Soil Moisture (%)',
                        hint: 'e.g. 45',
                        ctrl: _moistureCtrl,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Select Field',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          underline: const SizedBox(),
                          value: _selectedField,
                          hint: const Text(
                            'Choose field...',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'a',
                              child: Text('Field A — Wheat (5 acres)'),
                            ),
                            DropdownMenuItem(
                              value: 'b',
                              child: Text('Field B — Rice (3.5 acres)'),
                            ),
                            DropdownMenuItem(
                              value: 'c',
                              child: Text('Field C — Cotton (7 acres)'),
                            ),
                          ],
                          onChanged: (v) => setState(() => _selectedField = v),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Success Message ───────────────────────
                if (_successMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: Color(0xFF15803D),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _successMessage!,
                            style: const TextStyle(
                              color: Color(0xFF15803D),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // ── Error Message ──────────────────────────
                if (_errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Color(0xFFDC2626),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Color(0xFFDC2626),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // ── Analyze Button ─────────────────────────
                _isLoading
                    ? const LoadingCard(
                        bgColor: Color(0xFFD97706),
                        title: 'AI is analyzing your soil data...',
                        subtitle: 'Detecting nutrient deficiencies',
                      )
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _analyze,
                          icon: const Icon(Icons.science_outlined, size: 18),
                          label: const Text('Analyze Soil with AI'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD97706),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),
                const SizedBox(height: 16),

                // ── Info Banner ────────────────────────────
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Color(0xFF3B82F6),
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Our AI detects nitrogen, phosphorus, potassium deficiencies and provides fertilizer recommendations tailored to your crop and region.',
                          style: TextStyle(
                            color: Color(0xFF1D4ED8),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Section Card ───────────────────────────────────────────────
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ── Upload Button ──────────────────────────────────────────────
class _UploadButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool primary;
  final VoidCallback? onTap;

  const _UploadButton({
    required this.icon,
    required this.label,
    required this.primary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (primary) {
      return ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 14),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD97706),
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      );
    }
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 14),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFD97706),
        side: const BorderSide(color: Color(0xFFFDE68A)),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ── Input Field ────────────────────────────────────────────────
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: hint,
            suffixText: unit.isNotEmpty ? unit : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
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
              borderSide: const BorderSide(color: Color(0xFFD97706), width: 2),
            ),
            hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
          ),
          style: const TextStyle(fontSize: 13, color: Color(0xFF1F2937)),
        ),
      ],
    );
  }
}
