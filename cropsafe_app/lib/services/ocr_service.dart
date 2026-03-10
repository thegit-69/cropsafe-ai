// lib/services/ocr_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Extracted soil values from OCR via Gemini Vision.
class SoilOcrResult {
  final double? ph;
  final double? nitrogen;
  final double? phosphorus;
  final double? potassium;
  final double? moisture;
  final int fieldsFound;

  SoilOcrResult({
    this.ph,
    this.nitrogen,
    this.phosphorus,
    this.potassium,
    this.moisture,
  }) : fieldsFound = [
         ph,
         nitrogen,
         phosphorus,
         potassium,
         moisture,
       ].where((v) => v != null).length;

  bool get hasAnyValue => fieldsFound > 0;
}

class OcrService {
  static GenerativeModel? _model;

  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  static GenerativeModel _getModel() {
    _model ??= GenerativeModel(
      model: 'gemini-3-flash-preview',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.1,
        responseMimeType: 'application/json',
      ),
    );
    return _model!;
  }

  /// Send the soil report image to Gemini and extract values.
  static Future<SoilOcrResult> extractSoilValues(File imageFile) async {
    if (_apiKey.isEmpty) {
      throw OcrException(
        'Gemini API key not found. '
        'Add GEMINI_API_KEY to your .env file.',
      );
    }

    // Read image bytes and detect mime type
    final bytes = await imageFile.readAsBytes();
    final mime = _detectMimeType(imageFile.path);

    final prompt = TextPart('''
You are analyzing a soil analysis lab report image.
Extract the following soil parameters from the report.
If a value is not present or unreadable, use null.

Return ONLY a JSON object in this exact format (no markdown, no explanation):
{
  "ph": <number or null>,
  "nitrogen": <number or null>,
  "phosphorus": <number or null>,
  "potassium": <number or null>,
  "moisture": <number or null>
}

Guidelines:
- pH: Look for "pH", "Soil pH", "pH (1:2.5)" etc. Value should be between 0-14.
- Nitrogen: Look for "N", "Nitrogen", "NO3-N", "N (Kg/ha)". Return value in kg/ha or ppm as shown.
- Phosphorus: Look for "P", "Phosphorus", "P2O5", "P₂O₅ (Kg/ha)". Return value as shown.
- Potassium: Look for "K", "Potassium", "K2O", "K₂O (Kg/ha)". Return value as shown.
- Moisture: Look for "Moisture", "Soil Moisture". Value should be 0-100.
- If the report has multiple samples, use values from the FIRST sample only.
- Extract the exact numeric value shown in the report.
''');

    final imagePart = DataPart(mime, bytes);

    try {
      final response = await _getModel().generateContent([
        Content.multi([prompt, imagePart]),
      ]);

      final text = response.text;
      if (text == null || text.isEmpty) {
        throw OcrException('Gemini returned an empty response.');
      }

      return _parseResponse(text);
    } on GenerativeAIException catch (e) {
      if (e.message.contains('API_KEY')) {
        throw OcrException('Invalid Gemini API key. Please check your key.');
      }
      if (e.message.contains('SAFETY')) {
        throw OcrException(
          'Image was blocked by safety filters. Try a clearer photo.',
        );
      }
      throw OcrException('Gemini API error: ${e.message}');
    } on SocketException {
      throw OcrException(
        'No internet connection. Please check your network and try again.',
      );
    } on HttpException {
      throw OcrException('Network error. Please try again.');
    }
  }

  /// Parse the JSON response from Gemini.
  static SoilOcrResult _parseResponse(String text) {
    // Strip markdown code fences if present
    var cleaned = text.trim();
    if (cleaned.startsWith('```')) {
      cleaned = cleaned
          .replaceFirst(RegExp(r'^```(?:json)?\s*'), '')
          .replaceFirst(RegExp(r'\s*```$'), '');
    }

    try {
      final json = jsonDecode(cleaned) as Map<String, dynamic>;

      return SoilOcrResult(
        ph: _toDouble(json['ph']),
        nitrogen: _toDouble(json['nitrogen']),
        phosphorus: _toDouble(json['phosphorus']),
        potassium: _toDouble(json['potassium']),
        moisture: _toDouble(json['moisture']),
      );
    } on FormatException {
      throw OcrException(
        'Could not parse Gemini response. Please try again with a clearer image.',
      );
    }
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static String _detectMimeType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'heic':
      case 'heif':
        return 'image/heic';
      default:
        return 'image/jpeg';
    }
  }
}

/// Custom exception for OCR-specific errors with user-friendly messages.
class OcrException implements Exception {
  final String message;
  OcrException(this.message);

  @override
  String toString() => message;
}
