// ─── Data Models ─────────────────────────────────────────────────────────────

class HistoryItem {
  final int id;
  final String type; // 'soil' or 'crop'
  final String title;
  final String date;
  final String time;
  final String status;
  final String severity; // 'high', 'medium', 'low'
  final int score;

  const HistoryItem({
    required this.id,
    required this.type,
    required this.title,
    required this.date,
    required this.time,
    required this.status,
    required this.severity,
    required this.score,
  });
}

class SoilNutrient {
  final String label;
  final double value;
  final String unit;
  final String ideal;
  final String status; // 'good' or 'low'

  const SoilNutrient({
    required this.label,
    required this.value,
    required this.unit,
    required this.ideal,
    required this.status,
  });
}

// ─── Mock Data ────────────────────────────────────────────────────────────────

final List<HistoryItem> historyItems = [
  const HistoryItem(
    id: 1,
    type: 'soil',
    title: 'Soil Test — Field A',
    date: 'Mar 8, 2026',
    time: '10:24 AM',
    status: 'Nitrogen Deficiency',
    severity: 'medium',
    score: 62,
  ),
  const HistoryItem(
    id: 2,
    type: 'crop',
    title: 'Crop Scan — Wheat',
    date: 'Mar 7, 2026',
    time: '2:10 PM',
    status: 'Leaf Rust Detected',
    severity: 'high',
    score: 38,
  ),
  const HistoryItem(
    id: 3,
    type: 'crop',
    title: 'Crop Scan — Rice',
    date: 'Mar 5, 2026',
    time: '11:05 AM',
    status: 'Healthy Crop',
    severity: 'low',
    score: 91,
  ),
  const HistoryItem(
    id: 4,
    type: 'soil',
    title: 'Soil Test — Field B',
    date: 'Mar 3, 2026',
    time: '9:30 AM',
    status: 'Low Phosphorus',
    severity: 'medium',
    score: 55,
  ),
  const HistoryItem(
    id: 5,
    type: 'crop',
    title: 'Crop Scan — Cotton',
    date: 'Feb 28, 2026',
    time: '4:45 PM',
    status: 'Aphid Infestation',
    severity: 'high',
    score: 29,
  ),
];

final List<SoilNutrient> soilNutrients = [
  const SoilNutrient(
      label: 'Nitrogen (N)',
      value: 42,
      unit: 'kg/ha',
      ideal: '80–120',
      status: 'low'),
  const SoilNutrient(
      label: 'Phosphorus (P)',
      value: 68,
      unit: 'kg/ha',
      ideal: '50–80',
      status: 'good'),
  const SoilNutrient(
      label: 'Potassium (K)',
      value: 85,
      unit: 'kg/ha',
      ideal: '80–120',
      status: 'good'),
  const SoilNutrient(
      label: 'pH Level', value: 6.8, unit: '', ideal: '6.0–7.5', status: 'good'),
  const SoilNutrient(
      label: 'Organic Matter',
      value: 1.2,
      unit: '%',
      ideal: '2–4%',
      status: 'low'),
];
