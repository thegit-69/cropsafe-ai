import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/app_models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  // ─── USER PROFILE ──────────────────────────────────────────

  Future<void> createUserProfile(User user) async {
    final doc = _db.collection('users').doc(user.uid);
    final snapshot = await doc.get();
    if (!snapshot.exists) {
      await doc.set({
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'photoUrl': user.photoURL ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final doc = await _db.collection('users').doc(_uid).get();
    return doc.data();
  }

  // ─── FIELDS ────────────────────────────────────────────────

  Stream<List<FieldModel>> getFields() {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('fields')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => FieldModel.fromFirestore(doc)).toList(),
        );
  }

  Future<DocumentReference> addField(FieldModel field) {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('fields')
        .add(field.toMap());
  }

  Future<void> updateFieldScores(
    String fieldId,
    double soilScore,
    double cropScore,
  ) {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('fields')
        .doc(fieldId)
        .update({'soilScore': soilScore, 'cropScore': cropScore});
  }

  // ─── SOIL TESTS ────────────────────────────────────────────

  Stream<List<SoilTestResult>> getSoilTests() {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('soil_tests')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => SoilTestResult.fromFirestore(doc))
              .toList(),
        );
  }

  Future<DocumentReference> addSoilTest(SoilTestResult result) {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('soil_tests')
        .add(result.toMap());
  }

  // ─── CROP SCANS ────────────────────────────────────────────

  Stream<List<CropScanResult>> getCropScans() {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('crop_scans')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => CropScanResult.fromFirestore(doc))
              .toList(),
        );
  }

  Future<DocumentReference> addCropScan(CropScanResult result) {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('crop_scans')
        .add(result.toMap());
  }

  // ─── ALERTS ────────────────────────────────────────────────

  Stream<List<AlertModel>> getAlerts() {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('alerts')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => AlertModel.fromFirestore(doc)).toList(),
        );
  }

  Future<DocumentReference> addAlert(AlertModel alert) {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('alerts')
        .add(alert.toMap());
  }

  Future<void> markAlertRead(String alertId) {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('alerts')
        .doc(alertId)
        .update({'isRead': true});
  }

  // ─── STATS ─────────────────────────────────────────────────

  Future<Map<String, int>> getStats() async {
    final soilSnap = await _db
        .collection('users')
        .doc(_uid)
        .collection('soil_tests')
        .count()
        .get();
    final cropSnap = await _db
        .collection('users')
        .doc(_uid)
        .collection('crop_scans')
        .count()
        .get();

    // Count crop scans where disease is not "Healthy" as issues
    final issuesSnap = await _db
        .collection('users')
        .doc(_uid)
        .collection('crop_scans')
        .where('disease', isNotEqualTo: 'Healthy')
        .count()
        .get();

    return {
      'soilTests': soilSnap.count ?? 0,
      'cropScans': cropSnap.count ?? 0,
      'issuesFound': issuesSnap.count ?? 0,
    };
  }

  // ─── IMAGE UPLOAD ──────────────────────────────────────────

  Future<String> uploadCropImage(File imageFile) async {
    final fileName =
        'crop_scans/$_uid/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child(fileName);
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  // ─── SEED INITIAL DATA ────────────────────────────────────

  Future<void> seedInitialData() async {
    final fieldsSnap = await _db
        .collection('users')
        .doc(_uid)
        .collection('fields')
        .limit(1)
        .get();

    if (fieldsSnap.docs.isNotEmpty) return; // Already has data

    // Add sample fields
    final fieldARef = await addField(
      FieldModel(
        id: '',
        name: 'Field A',
        crop: 'Wheat',
        acres: 5.0,
        soilScore: 0.62,
        cropScore: 0.38,
        createdAt: DateTime.now(),
      ),
    );

    final fieldBRef = await addField(
      FieldModel(
        id: '',
        name: 'Field B',
        crop: 'Rice',
        acres: 3.5,
        soilScore: 0.88,
        cropScore: 0.91,
        createdAt: DateTime.now(),
      ),
    );

    // Add sample alerts
    await addAlert(
      AlertModel(
        id: '',
        text: 'Low nitrogen in Field A — apply urea fertilizer within 3 days.',
        severity: 'warning',
        isRead: false,
        createdAt: DateTime.now(),
      ),
    );

    await addAlert(
      AlertModel(
        id: '',
        text: 'Leaf rust risk high in your wheat crop — scan immediately.',
        severity: 'critical',
        isRead: false,
        createdAt: DateTime.now(),
      ),
    );

    // Add a sample soil test
    await addSoilTest(
      SoilTestResult(
        id: '',
        fieldId: fieldARef.id,
        score: 62,
        label: 'Moderate Soil Health',
        breakdown: {
          'nitrogen': {'value': 42, 'status': 'Low'},
          'phosphorus': {'value': 68, 'status': 'OK'},
          'potassium': {'value': 85, 'status': 'OK'},
          'ph': {'value': 6.8, 'status': 'OK'},
          'moisture': {'value': 45, 'status': 'OK'},
        },
        recommendations: [
          {
            'title': 'Apply Urea Fertilizer',
            'detail': 'Add 40 kg/ha urea to fix nitrogen deficiency.',
          },
        ],
        createdAt: DateTime.now(),
      ),
    );

    // Add a sample crop scan
    await addCropScan(
      CropScanResult(
        id: '',
        fieldId: fieldBRef.id,
        disease: 'Healthy',
        confidence: 0.95,
        recommendation: 'No action needed. Crop is healthy.',
        createdAt: DateTime.now(),
      ),
    );
  }
}
