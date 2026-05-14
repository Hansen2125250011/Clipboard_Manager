import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:clipboard_history_manager/main.dart';
import 'package:clipboard_history_manager/services/firebase_service.dart';
import 'package:clipboard_history_manager/screens/statistics_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = FirebaseService().currentUser;
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Pengaturan & Sinkronisasi', 
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w800, 
            color: theme.colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Account Profile Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? theme.colorScheme.surfaceContainer : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFECEEF0)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: isDark ? theme.colorScheme.primary : const Color(0xFF0056D2),
                  backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                  child: user?.photoURL == null ? Icon(Icons.person, color: isDark ? const Color(0xFF0B1326) : Colors.white, size: 30) : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? 'Pengguna Tamu',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18, color: theme.colorScheme.onSurface),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.email ?? 'Mode Lokal (Luring)',
                        style: GoogleFonts.inter(color: isDark ? Colors.white54 : const Color(0xFF737785), fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Settings Section
          Text('Tampilan', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: isDark ? Colors.white54 : const Color(0xFF737785))),
          const SizedBox(height: 12),
          // Theme Picker
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? theme.colorScheme.surfaceContainer : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFECEEF0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.palette_outlined, color: isDark ? theme.colorScheme.primary : const Color(0xFF0056D2)),
                      const SizedBox(width: 16),
                      Text(
                        'Tema Aplikasi', 
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode_outlined),
                      label: Text('Light'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode_outlined),
                      label: Text('Dark'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: Icon(Icons.settings_suggest_outlined),
                      label: Text('Sistem'),
                    ),
                  ],
                  selected: {themeProvider.themeMode},
                  onSelectionChanged: (Set<ThemeMode> newSelection) {
                    themeProvider.setThemeMode(newSelection.first);
                  },
                  style: SegmentedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    selectedBackgroundColor: (isDark ? theme.colorScheme.primary : const Color(0xFF0056D2)).withValues(alpha: 0.12),
                    selectedForegroundColor: isDark ? theme.colorScheme.primary : const Color(0xFF0056D2),
                    textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          Text('Aplikasi', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: isDark ? Colors.white54 : const Color(0xFF737785))),
          const SizedBox(height: 12),
          _buildSettingsTile(
            context: context,
            icon: Icons.bar_chart_rounded,
            title: 'Statistik Penggunaan',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StatisticsScreen())),
          ),
          const SizedBox(height: 32),
          _buildSettingsTile(
            context: context,
            icon: Icons.cloud_sync_rounded,
            title: 'Sinkronisasi Cloud',
            trailing: Switch(
              value: user != null, 
              onChanged: (v) {
                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Silakan login terlebih dahulu untuk mengaktifkan sinkronisasi cloud.'),
                      backgroundColor: isDark ? Colors.white : const Color(0xFF191C1E),
                    ),
                  );
                }
              }, 
              activeThumbColor: isDark ? theme.colorScheme.primary : const Color(0xFF0056D2),
            ),
          ),
          
          const SizedBox(height: 32),
          Text('Data', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: isDark ? Colors.white54 : const Color(0xFF737785))),
          const SizedBox(height: 12),
          _buildSettingsTile(
            context: context,
            icon: Icons.delete_sweep_rounded,
            title: 'Hapus Semua Riwayat',
            textColor: theme.colorScheme.error,
            onTap: () => _confirmClearAll(context),
          ),
          
          const SizedBox(height: 48),
          if (user != null)
            ElevatedButton(
              onPressed: () async {
                await FirebaseService().signOut();
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error.withValues(alpha: 0.12),
                foregroundColor: theme.colorScheme.error,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text('Keluar Akun', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Versi 1.0.0 • Material Design 3',
              style: GoogleFonts.inter(color: isDark ? Colors.white38 : const Color(0xFFC3C6D6), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
    Color? textColor,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surfaceContainer : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFECEEF0)),
      ),
      child: ListTile(
        leading: Icon(icon, color: textColor ?? (isDark ? theme.colorScheme.primary : const Color(0xFF0056D2))),
        title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textColor ?? theme.colorScheme.onSurface)),
        trailing: trailing ?? Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white38 : const Color(0xFFC3C6D6)),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _confirmClearAll(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Hapus Semua?', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
        content: Text('Seluruh data clipboard lokal akan dihapus permanen.', style: GoogleFonts.inter(color: isDark ? Colors.white70 : Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text('Batal', style: TextStyle(color: isDark ? Colors.white60 : Colors.black54)),
          ),
          TextButton(
            onPressed: () {
              context.read<ClipboardProvider>().clearAll();
              Navigator.pop(context);
            },
            child: Text('Hapus', style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
