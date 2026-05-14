import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:clipboard_history_manager/database/db_helper.dart';
import 'package:clipboard_history_manager/main.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DetailScreen extends StatelessWidget {
  final ClipItem clip;

  const DetailScreen({super.key, required this.clip});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeStr = DateFormat('EEEE, dd MMMM yyyy • HH:mm').format(clip.timestamp);
    final isLink = clip.content.startsWith('http');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Detail Item', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(
              clip.isFavorite ? Icons.star : Icons.star_border,
              color: clip.isFavorite ? const Color(0xFF0056D2) : const Color(0xFF737785),
            ),
            onPressed: () {
              context.read<ClipboardProvider>().toggleFavorite(clip);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFBA1A1A)),
            onPressed: () {
              _confirmDelete(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isLink ? const Color(0xFF006591).withOpacity(0.1) : const Color(0xFF0056D2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isLink ? 'Link' : 'Teks',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isLink ? const Color(0xFF006591) : const Color(0xFF0040A1),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              clip.content,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 18,
                height: 1.6,
                color: const Color(0xFF191C1E),
              ),
            ),
            const SizedBox(height: 32),
            const Divider(color: Color(0xFFECEEF0)),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.calendar_today_outlined, 'Dibuat pada', timeStr),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.sync, 'Status Sinkronisasi', clip.isSynced ? 'Sudah disinkronkan' : 'Menunggu sinkronisasi'),
            const SizedBox(height: 48),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _copyToClipboard(context, clip.content),
                    icon: const Icon(Icons.copy),
                    label: const Text('Salin Teks'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0056D2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Share implementation
                      // In a real app, use share_plus package
                    },
                    icon: const Icon(Icons.share_outlined),
                    label: const Text('Bagikan'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(color: Color(0xFFECEEF0)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF737785)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF737785))),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    Fluttertoast.showToast(msg: "Berhasil disalin");
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Item?'),
        content: const Text('Item ini akan dihapus dari riwayat lokal.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              context.read<ClipboardProvider>().deleteClip(clip.id!);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close detail screen
            },
            child: const Text('Hapus', style: TextStyle(color: Color(0xFFBA1A1A))),
          ),
        ],
      ),
    );
  }
}
