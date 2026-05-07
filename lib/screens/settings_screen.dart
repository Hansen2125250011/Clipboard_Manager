import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clipboard_history_manager/main.dart';
import 'package:clipboard_history_manager/services/firebase_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  final user = FirebaseService().currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9FB),
        title: const Text(
          'Pengaturan',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Akun'),
          _buildSettingCard(
            icon: Icons.account_circle_outlined,
            title: user?.displayName ?? 'Pengguna',
            subtitle: user?.email ?? 'Tidak ada email',
            trailing: TextButton(
              onPressed: () async {
                await FirebaseService().signOut();
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Keluar', style: TextStyle(color: Color(0xFFBA1A1A))),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Umum'),
          _buildSettingCard(
            icon: Icons.notifications_active_outlined,
            title: 'Notifikasi Background',
            subtitle: 'Selalu aktif untuk menangkap riwayat share',
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Data'),
          _buildSettingCard(
            icon: Icons.delete_outline,
            title: 'Hapus Semua Riwayat',
            subtitle: 'Tindakan ini tidak dapat dibatalkan',
            textColor: const Color(0xFFBA1A1A),
            onTap: () => _confirmClearAll(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.bold,
          color: Color(0xFF0056D2),
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFECEEF0)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: textColor ?? const Color(0xFF424654)),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            color: textColor ?? const Color(0xFF191C1E),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontFamily: 'Inter', fontSize: 12),
        ),
        trailing: trailing,
      ),
    );
  }

  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Hapus Semua?'),
        content: const Text('Semua riwayat clipboard akan dihapus secara permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<ClipboardProvider>(context, listen: false).clearAll();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFBA1A1A)),
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );
  }
}
