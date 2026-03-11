import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_models.dart';
import '../screens/login_screen.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/weather_service.dart';

class HomeTab extends StatefulWidget {
  final VoidCallback onGoToSoil;
  final VoidCallback onGoToCrop;
  final VoidCallback onGoToHistory;

  const HomeTab({
    super.key,
    required this.onGoToSoil,
    required this.onGoToCrop,
    required this.onGoToHistory,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _firestoreService = FirestoreService();
  final _weatherService   = WeatherService();
  int _soilTests = 0;
  int _cropScans = 0;
  int _issuesFound = 0;

  WeatherData? _weather;
  bool _weatherLoading = true;

  List<FieldModel> _fields = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
    _loadWeather();
    _firestoreService.getFields().listen((data) {
      if (mounted) setState(() => _fields = data);
    });
  }

  String _scoreLabel(double score) {
    final s = score > 1 ? score : score * 100;
    if (s >= 80) return 'Healthy';
    if (s >= 50) return 'Moderate';
    return 'At Risk';
  }

  int _toInt(double score) =>
      score > 1 ? score.round() : (score * 100).round();

  Future<void> _loadWeather() async {
    try {
      final data = await _weatherService.fetchWeather();
      if (mounted) setState(() { _weather = data; _weatherLoading = false; });
    } catch (_) {
      if (mounted) setState(() { _weather = WeatherData.fallback; _weatherLoading = false; });
    }
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _firestoreService.getStats();
      if (mounted) {
        setState(() {
          _soilTests   = stats['soilTests'] ?? 0;
          _cropScans   = stats['cropScans'] ?? 0;
          _issuesFound = stats['issuesFound'] ?? 0;
        });
      }
    } catch (_) {}
  }

  String get _userName {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.displayName == null || user!.displayName!.isEmpty) return 'Farmer';
    final parts = user.displayName!.trim().split(' ');
    return parts.first;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // ── Green header ────────────────────────────────────────────
          Container(
            color: const Color(0xFF15803D),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            child: Column(
              children: [
                // Top row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Good Morning,',
                            style: TextStyle(
                                color: Color(0xFFBBF7D0), fontSize: 12),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$_userName 👋',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Stack(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(Icons.notifications_outlined,
                              color: Colors.white, size: 20),
                        ),
                        Positioned(
                          top: 6,
                          right: 14,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF87171),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: const Color(0xFF15803D), width: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const _ProfileSheet(),
                      ),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Center(
                          child: Text(
                            'RK',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Weather strip
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _weatherLoading
                      ? const Center(
                          child: SizedBox(
                            height: 36,
                            child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                          ),
                        )
                      : Row(
                          children: [
                            Text(
                              _weather?.emoji ?? '🌡️',
                              style: const TextStyle(fontSize: 28),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_weather?.temperature.round() ?? '--'}°C · ${_weather?.city ?? '...'}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    '${_weather?.condition ?? ''} · ${_weather?.isGoodForFieldWork == true ? 'Good for field work' : 'Not ideal for field work'}',
                                    style: const TextStyle(
                                        color: Color(0xFFBBF7D0), fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                _weatherStat('💧', '${_weather?.humidity ?? '--'}%'),
                                const SizedBox(width: 12),
                                _weatherStat('🌬️', '${_weather?.windSpeed.round() ?? '--'}km/h'),
                                const SizedBox(width: 12),
                                _weatherStat('🌡️', '${_weather?.temperature.round() ?? '--'}°'),
                              ],
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),

          // ── Cards below header ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Transform.translate(
              offset: const Offset(0, -24),
              child: Column(
                children: [
                  // Quick action cards
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.science_outlined,
                          iconBg: const Color(0xFFFEF3C7),
                          iconColor: const Color(0xFFD97706),
                          title: 'Soil Test',
                          subtitle: 'Analyze nutrients & pH',
                          actionText: 'Start Test',
                          actionColor: const Color(0xFFD97706),
                          onTap: widget.onGoToSoil,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.qr_code_scanner,
                          iconBg: const Color(0xFFDCFCE7),
                          iconColor: const Color(0xFF15803D),
                          title: 'Crop Scan',
                          subtitle: 'Detect pest & disease',
                          actionText: 'Scan Now',
                          actionColor: const Color(0xFF15803D),
                          onTap: widget.onGoToCrop,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // AI Alerts
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                '⚡ AI Alerts',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF374151)),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                '2 new',
                                style: TextStyle(
                                    color: Color(0xFFDC2626),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _AlertBanner(
                          emoji: '🧪',
                          message:
                              'Low nitrogen in Field A — apply urea fertilizer within 3 days.',
                          bg: const Color(0xFFFFFBEB),
                          border: const Color(0xFFFDE68A),
                          textColor: const Color(0xFF92400E),
                        ),
                        const SizedBox(height: 8),
                        _AlertBanner(
                          emoji: '🌾',
                          message:
                              'Leaf rust risk high in your wheat crop — scan immediately.',
                          bg: const Color(0xFFFEF2F2),
                          border: const Color(0xFFFECACA),
                          textColor: const Color(0xFF991B1B),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // My Fields
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'My Fields',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF374151)),
                              ),
                            ),
                            GestureDetector(
                              onTap: widget.onGoToHistory,
                              child: const Text(
                                'View All',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF15803D)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (_fields.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Center(
                              child: Text(
                                'No fields added yet.',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF9CA3AF)),
                              ),
                            ),
                          )
                        else
                          ...() {
                            final display = _fields.take(2).toList();
                            final rows = <Widget>[];
                            for (var i = 0; i < display.length; i++) {
                              final f = display[i];
                              rows.add(_FieldRow(
                                name: f.name,
                                crop: '${f.crop} · ${f.acres} acres',
                                soilScore: _toInt(f.soilScore),
                                cropScore: _toInt(f.cropScore),
                                soilLabel: _scoreLabel(f.soilScore),
                                cropLabel: _scoreLabel(f.cropScore),
                                onTap: widget.onGoToHistory,
                              ));
                              if (i < display.length - 1) {
                                rows.add(const Divider(
                                    height: 20,
                                    color: Color(0xFFF3F4F6)));
                              }
                            }
                            return rows;
                          }(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Stats row
                  Row(
                    children: [
                      Expanded(
                          child: _StatCard(
                              emoji: '🧪',
                              value: _soilTests.toString(),
                              label: 'Soil Tests',
                              bg: const Color(0xFFFFFBEB))),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _StatCard(
                              emoji: '🌿',
                              value: _cropScans.toString(),
                              label: 'Crop Scans',
                              bg: const Color(0xFFF0FDF4))),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _StatCard(
                              emoji: '⚠️',
                              value: _issuesFound.toString(),
                              label: 'Issues Found',
                              bg: const Color(0xFFEFF6FF))),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _weatherStat(String emoji, String value) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 1),
        Text(value,
            style: const TextStyle(color: Colors.white, fontSize: 10)),
      ],
    );
  }

  Widget _card({required Widget child}) {
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

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String actionText;
  final Color actionColor;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.actionText,
    required this.actionColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 10),
            Text(title,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937))),
            const SizedBox(height: 2),
            Text(subtitle,
                style: const TextStyle(
                    fontSize: 11, color: Color(0xFF9CA3AF))),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(actionText,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: actionColor)),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 12, color: actionColor),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertBanner extends StatelessWidget {
  final String emoji;
  final String message;
  final Color bg;
  final Color border;
  final Color textColor;

  const _AlertBanner({
    required this.emoji,
    required this.message,
    required this.bg,
    required this.border,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style:
                  TextStyle(color: textColor, fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  final String name;
  final String crop;
  final int soilScore;
  final int cropScore;
  final String soilLabel;
  final String cropLabel;
  final VoidCallback? onTap;

  const _FieldRow({
    required this.name,
    required this.crop,
    required this.soilScore,
    required this.cropScore,
    required this.soilLabel,
    required this.cropLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
      children: [
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.grass,
                  color: Color(0xFF15803D), size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937))),
                  Text(crop,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF9CA3AF))),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                size: 18, color: Color(0xFFD1D5DB)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
                child: _MiniBar(
                    label: 'Soil',
                    score: soilScore,
                    statusLabel: soilLabel)),
            const SizedBox(width: 12),
            Expanded(
                child: _MiniBar(
                    label: 'Crop',
                    score: cropScore,
                    statusLabel: cropLabel)),
          ],
        ),
      ],
      ),
    );
  }
}

class _MiniBar extends StatelessWidget {
  final String label;
  final int score;
  final String statusLabel;

  const _MiniBar(
      {required this.label,
      required this.score,
      required this.statusLabel});

  @override
  Widget build(BuildContext context) {
    final isGood = score > 80;
    final color =
        isGood ? const Color(0xFF22C55E) : const Color(0xFFF87171);
    final labelColor =
        isGood ? const Color(0xFF15803D) : const Color(0xFFDC2626);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: Color(0xFF9CA3AF))),
            Text(statusLabel,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: labelColor)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: score / 100,
            backgroundColor: const Color(0xFFF3F4F6),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 5,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Color bg;

  const _StatCard(
      {required this.emoji,
      required this.value,
      required this.label,
      required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration:
                BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
            child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 16))),
          ),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2937))),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: Color(0xFF9CA3AF)),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── Profile Sheet ─────────────────────────────────────────────────────────────

class _ProfileSheet extends StatefulWidget {
  const _ProfileSheet();

  @override
  State<_ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends State<_ProfileSheet> {
  final _authService = AuthService();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _farmCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  bool _saving = false;
  bool _loggingOut = false;

  @override
  void initState() {
    super.initState();
    final user = _authService.currentUser;
    _nameCtrl.text = user?.displayName ?? 'Team KALKI';
    _phoneCtrl.text = user?.phoneNumber ?? '';
    _farmCtrl.text = '';
    _locationCtrl.text = '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _farmCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    setState(() => _loggingOut = true);
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.92,
      minChildSize: 0.5,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: scrollCtrl,
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Avatar + title
            Center(
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF15803D),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: const Center(
                      child: Text(
                        'RK',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildField('Full Name', _nameCtrl, Icons.person_outline),
            const SizedBox(height: 14),
            _buildField(
              'Phone Number',
              _phoneCtrl,
              Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 14),
            _buildField('Farm Name', _farmCtrl, Icons.agriculture_outlined),
            const SizedBox(height: 14),
            _buildField(
                'Location / District', _locationCtrl, Icons.location_on_outlined),
            const SizedBox(height: 28),
            // Save button
            ElevatedButton(
              onPressed: _saving
                  ? null
                  : () {
                      setState(() => _saving = true);
                      Future.delayed(const Duration(milliseconds: 600), () {
                        if (mounted) {
                          setState(() => _saving = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profile updated'),
                              backgroundColor: Color(0xFF15803D),
                            ),
                          );
                          Navigator.pop(context);
                        }
                      });
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF15803D),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Save Changes',
                      style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 12),
            // Logout button
            OutlinedButton.icon(
              onPressed: _loggingOut ? null : _logout,
              icon: _loggingOut
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Color(0xFFDC2626)))
                  : const Icon(Icons.logout,
                      color: Color(0xFFDC2626), size: 18),
              label: Text(
                _loggingOut ? 'Logging out…' : 'Log Out',
                style: const TextStyle(
                  color: Color(0xFFDC2626),
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFECACA)),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
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
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon:
                Icon(icon, size: 18, color: const Color(0xFF9CA3AF)),
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
                  const BorderSide(color: Color(0xFF15803D), width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}
