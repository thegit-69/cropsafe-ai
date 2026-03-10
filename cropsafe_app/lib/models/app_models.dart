import 'package:cloud_firestore/cloud_firestore.dart';

class FieldModel {
  final String id;
  final String name;
  final String crop;
  final double acres;
  final double soilScore;
  final double cropScore;
  final DateTime createdAt;

  FieldModel({
    required this.id,
    required this.name,
    required this.crop,
    required this.acres,
    required this.soilScore,
    required this.cropScore,
    required this.createdAt,
  });

  factory FieldModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FieldModel(
      id: doc.id,
      name: data['name'] ?? '',
      crop: data['crop'] ?? '',
      acres: (data['acres'] ?? 0).toDouble(),
      soilScore: (data['soilScore'] ?? 0).toDouble(),
      cropScore: (data['cropScore'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'crop': crop,
    'acres': acres,
    'soilScore': soilScore,
    'cropScore': cropScore,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}

class SoilTestResult {
  final String id;
  final String fieldId;
  final int score;
  final String label;
  final Map<String, dynamic> breakdown;
  final List<Map<String, dynamic>> recommendations;
  final DateTime createdAt;

  SoilTestResult({
    required this.id,
    required this.fieldId,
    required this.score,
    required this.label,
    required this.breakdown,
    required this.recommendations,
    required this.createdAt,
  });

  factory SoilTestResult.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SoilTestResult(
      id: doc.id,
      fieldId: data['fieldId'] ?? '',
      score: data['score'] ?? 0,
      label: data['label'] ?? '',
      breakdown: Map<String, dynamic>.from(data['breakdown'] ?? {}),
      recommendations: List<Map<String, dynamic>>.from(
        (data['recommendations'] ?? []).map(
          (r) => Map<String, dynamic>.from(r),
        ),
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'fieldId': fieldId,
    'score': score,
    'label': label,
    'breakdown': breakdown,
    'recommendations': recommendations,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}

class CropScanResult {
  final String id;
  final String fieldId;
  final String disease;
  final double confidence;
  final String recommendation;
  final String? imageUrl;
  final DateTime createdAt;

  CropScanResult({
    required this.id,
    required this.fieldId,
    required this.disease,
    required this.confidence,
    required this.recommendation,
    this.imageUrl,
    required this.createdAt,
  });

  factory CropScanResult.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CropScanResult(
      id: doc.id,
      fieldId: data['fieldId'] ?? '',
      disease: data['disease'] ?? '',
      confidence: (data['confidence'] ?? 0).toDouble(),
      recommendation: data['recommendation'] ?? '',
      imageUrl: data['imageUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'fieldId': fieldId,
    'disease': disease,
    'confidence': confidence,
    'recommendation': recommendation,
    'imageUrl': imageUrl,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}

class AlertModel {
  final String id;
  final String text;
  final String severity; // 'warning', 'critical'
  final bool isRead;
  final DateTime createdAt;

  AlertModel({
    required this.id,
    required this.text,
    required this.severity,
    required this.isRead,
    required this.createdAt,
  });

  factory AlertModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AlertModel(
      id: doc.id,
      text: data['text'] ?? '',
      severity: data['severity'] ?? 'warning',
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'text': text,
    'severity': severity,
    'isRead': isRead,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
