// lib/services/api_service.dart

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Change this to your actual IP or ngrok URL
  static const String baseUrl = 'http://10.60.223.131:8000';

  // ── Crop Disease Analysis ──────────────────────────────────
  static Future<CropApiResult> analyzeCrop(File imageFile) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/crop/predict_crop'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      final response = await request.send().timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final body = await response.stream.bytesToString();
        final json = jsonDecode(body);
        return CropApiResult.fromJson(json);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Crop analysis failed: $e');
    }
  }

  // ── Soil Health Analysis ───────────────────────────────────
  static Future<SoilApiResult> analyzeSoil({
    required double nitrogen,
    required double phosphorus,
    required double potassium,
    required double ph,
    required double moisture,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/soil/predict_soil'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nitrogen':   nitrogen,
          'phosphorus': phosphorus,
          'potassium':  potassium,
          'ph':         ph,
          'moisture':   moisture,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return SoilApiResult.fromJson(json);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Soil analysis failed: $e');
    }
  }
}

// ── Crop API Response Model ────────────────────────────────────
class CropApiResult {
  final String disease;
  final double confidence;
  final String recommendation;

  CropApiResult({
    required this.disease,
    required this.confidence,
    required this.recommendation,
  });

  factory CropApiResult.fromJson(Map<String, dynamic> json) {
    return CropApiResult(
      disease:        json['disease'] ?? 'Unknown',
      confidence:     (json['confidence'] ?? 0.0).toDouble(),
      recommendation: json['recommendation'] ?? '',
    );
  }
}

// ── Soil API Response Model ────────────────────────────────────
class SoilBreakdownItem {
  final String parameter;
  final double value;
  final String unit;
  final String status;
  final String ideal;
  final double score;

  SoilBreakdownItem({
    required this.parameter,
    required this.value,
    required this.unit,
    required this.status,
    required this.ideal,
    required this.score,
  });

  factory SoilBreakdownItem.fromJson(Map<String, dynamic> json) {
    return SoilBreakdownItem(
      parameter: json['parameter'] ?? '',
      value:     (json['value'] ?? 0.0).toDouble(),
      unit:      json['unit'] ?? '',
      status:    json['status'] ?? 'OK',
      ideal:     json['ideal'] ?? '',
      score:     (json['score'] ?? 0.0).toDouble(),
    );
  }
}

class SoilRecommendationItem {
  final String title;
  final String detail;

  SoilRecommendationItem({
    required this.title,
    required this.detail,
  });

  factory SoilRecommendationItem.fromJson(Map<String, dynamic> json) {
    return SoilRecommendationItem(
      title:  json['title'] ?? '',
      detail: json['detail'] ?? '',
    );
  }
}

class SoilApiResult {
  final int score;
  final String label;
  final int deficienciesCount;
  final List<SoilBreakdownItem> breakdown;
  final List<SoilRecommendationItem> recommendations;

  SoilApiResult({
    required this.score,
    required this.label,
    required this.deficienciesCount,
    required this.breakdown,
    required this.recommendations,
  });

  factory SoilApiResult.fromJson(Map<String, dynamic> json) {
    return SoilApiResult(
      score:             json['score'] ?? 0,
      label:             json['label'] ?? '',
      deficienciesCount: json['deficiencies_count'] ?? 0,
      breakdown: (json['breakdown'] as List? ?? [])
          .map((e) => SoilBreakdownItem.fromJson(e))
          .toList(),
      recommendations: (json['recommendations'] as List? ?? [])
          .map((e) => SoilRecommendationItem.fromJson(e))
          .toList(),
    );
  }
}