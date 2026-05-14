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
    final user = FirebaseService().currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9FB),
        title: const Text('Pengaturan & Sinkronisasi', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Account Profile Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFECEEF0)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF0056D2),
                  backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                  child: user?.photoURL == null ? const Icon(Icons.person, color: Colors.white, size: 30) : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? 'Pengguna',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        user?.email ?? 'Tidak ada email',
                        style: const TextStyle(color: Color(0xFF737785), fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          Text('Aplikasi', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF737785))),
          const SizedBox(height: 12),
          _buildSettingsTile(
            icon: Icons.bar_chart_rounded,
            title: 'Statistik Penggunaan',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StatisticsScreen())),
          ),
          _buildSettingsTile(
            icon: Icons.sync_rounded,
            title: 'Sinkronisasi Cloud',
            trailing: Switch(value: true, onChanged: (v) {}, activeColor: const Color(0xFF0056D2)),
          ),
          
          const SizedBox(height: 32),
          Text('Data', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF737785))),
          const SizedBox(height: 12),
          _buildSettingsTile(
            icon: Icons.delete_sweep_rounded,
            title: 'Hapus Semua Riwayat',
            textColor: const Color(0xFFBA1A1A),
            onTap: () => _confirmClearAll(context),
          ),
          
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () async {
              await FirebaseService().signOut();
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBA1A1A).withOpacity(0.1),
              foregroundColor: const Color(0xFFBA1A1A),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Keluar Akun', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'Versi 1.0.0',
              style: TextStyle(color: Color(0xFFC3C6D6), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
    Color? textColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFECEEF0)),
      ),
      child: ListTile(
        leading: Icon(icon, color: textColor ?? const Color(0xFF0056D2)),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
        trailing: trailing ?? const Icon(Icons.chevron_right_rounded, color: Color(0xFFC3C6D6)),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Semua?'),
        content: const Text('Seluruh data clipboard lokal akan dihapus permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              context.read<ClipboardProvider>().clearAll();
              Navigator.pop(context);
            },
            child: const Text('Hapus', style: TextStyle(color: Color(0xFFBA1A1A))),
          ),
        ],
      ),
    );
  }
}
