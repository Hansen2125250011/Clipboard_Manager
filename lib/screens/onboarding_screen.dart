import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clipboard_history_manager/screens/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Selamat Datang di Clipboard Manager',
      description: 'Kelola riwayat salinan Anda dengan aman, cepat, dan terorganisasi dalam satu tempat terpusat.',
      icon: Icons.assignment_turned_in_rounded,
      color: const Color(0xFF0056D2),
    ),
    OnboardingData(
      title: 'Penyimpanan Latar Belakang',
      description: 'Aplikasi secara otomatis menangkap teks dan tautan yang Anda salin tanpa mengganggu alur kerja Anda.',
      icon: Icons.history_edu_rounded,
      color: const Color(0xFF0040A1),
    ),
    OnboardingData(
      title: 'Kategori & Pencarian Cepat',
      description: 'Temukan kembali salinan penting Anda dalam hitungan detik menggunakan pencarian cerdas dan filter kategori otomatis.',
      icon: Icons.saved_search_rounded,
      color: const Color(0xFF006591),
    ),
    OnboardingData(
      title: 'Sinkronisasi Cloud Terenkripsi',
      description: 'Akses seluruh riwayat salinan Anda dari perangkat mana pun dengan aman melalui sinkronisasi cloud waktu-nyata.',
      icon: Icons.cloud_sync_rounded,
      color: const Color(0xFF0056D2),
    ),
  ];

  void _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showOnboarding', false);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index], isDark);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => _buildDot(index, isDark),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        _finishOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? theme.colorScheme.primary : const Color(0xFF0056D2),
                      foregroundColor: isDark ? const Color(0xFF0B1326) : Colors.white,
                      minimumSize: const Size(140, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 4,
                      shadowColor: (isDark ? theme.colorScheme.primary : const Color(0xFF0056D2)).withValues(alpha: 0.3),
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1 ? 'Mulai' : 'Lanjut',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingData data, bool isDark) {
    final theme = Theme.of(context);
    final accentColor = isDark ? theme.colorScheme.primary : data.color;

    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 200,
            width: 200,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, size: 100, color: accentColor),
          ),
          const SizedBox(height: 64),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: isDark ? Colors.white70 : const Color(0xFF424654),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index, bool isDark) {
    final theme = Theme.of(context);
    final activeColor = isDark ? theme.colorScheme.primary : const Color(0xFF0056D2);
    final inactiveColor = isDark ? theme.colorScheme.surfaceContainer : const Color(0xFFECEEF0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: _currentPage == index ? activeColor : inactiveColor,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
