import 'package:flutter/material.dart';
import '../tabs/home_tab.dart';
import '../tabs/soil_test_tab.dart';
import '../tabs/crop_tab.dart';
import '../tabs/history_tab.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final _tabs = const [
    _NavItem(
      label: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      activeColor: Color(0xFF15803D),
    ),
    _NavItem(
      label: 'Soil Test',
      icon: Icons.science_outlined,
      activeIcon: Icons.science,
      activeColor: Color(0xFFD97706),
    ),
    _NavItem(
      label: 'Crop',
      icon: Icons.grass_outlined,
      activeIcon: Icons.grass,
      activeColor: Color(0xFF15803D),
    ),
    _NavItem(
      label: 'History',
      icon: Icons.history,
      activeIcon: Icons.history,
      activeColor: Color(0xFF374151),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            HomeTab(
              onGoToSoil: () => setState(() => _currentIndex = 1),
              onGoToCrop: () => setState(() => _currentIndex = 2),
              onGoToHistory: () => setState(() => _currentIndex = 3),
            ),
            const SoilTestTab(),
            const CropTab(),
            const HistoryTab(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFF3F4F6), width: 1)),
          boxShadow: [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 12,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_tabs.length, (i) {
                final tab = _tabs[i];
                final active = _currentIndex == i;
                return GestureDetector(
                  onTap: () => setState(() => _currentIndex = i),
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: 72,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          active ? tab.activeIcon : tab.icon,
                          color: active
                              ? tab.activeColor
                              : const Color(0xFF9CA3AF),
                          size: 22,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          tab.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: active
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: active
                                ? tab.activeColor
                                : const Color(0xFF9CA3AF),
                          ),
                        ),
                        const SizedBox(height: 2),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: active ? 4 : 0,
                          height: active ? 4 : 0,
                          decoration: BoxDecoration(
                            color: tab.activeColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final Color activeColor;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.activeColor,
  });
}
