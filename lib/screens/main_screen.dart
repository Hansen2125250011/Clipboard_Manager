import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clipboard_history_manager/screens/history_screen.dart';
import 'package:clipboard_history_manager/screens/favorites_screen.dart';
import 'package:clipboard_history_manager/screens/statistics_screen.dart';
import 'package:clipboard_history_manager/screens/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HistoryScreen(),
    const FavoritesScreen(),
    const StatisticsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? theme.colorScheme.primary : const Color(0xFF0056D2);

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: theme.colorScheme.surface,
        indicatorColor: primaryColor.withValues(alpha: 0.12),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.history_rounded, color: _selectedIndex == 0 ? primaryColor : (isDark ? Colors.white38 : const Color(0xFF737785))),
            label: 'Riwayat',
          ),
          NavigationDestination(
            icon: Icon(Icons.star_rounded, color: _selectedIndex == 1 ? primaryColor : (isDark ? Colors.white38 : const Color(0xFF737785))),
            label: 'Tersimpan',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_rounded, color: _selectedIndex == 2 ? primaryColor : (isDark ? Colors.white38 : const Color(0xFF737785))),
            label: 'Statistik',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_rounded, color: _selectedIndex == 3 ? primaryColor : (isDark ? Colors.white38 : const Color(0xFF737785))),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}
