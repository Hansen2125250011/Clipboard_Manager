import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final isDark = theme.brightness == Brightness.dark;
    final timeStr = DateFormat('EEEE, dd MMMM yyyy • HH:mm').format(clip.timestamp);
    final isLink = clip.content.startsWith('http');

    final primaryAccent = isDark ? theme.colorScheme.primary : const Color(0xFF0056D2);
    final linkAccent = isDark ? const Color(0xFF70B5FF) : const Color(0xFF006591);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text(
          'Detail Item', 
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w800, 
            color: theme.colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              clip.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
              size: 24,
              color: clip.isFavorite ? primaryAccent : (isDark ? Colors.white54 : const Color(0xFF737785)),
            ),
            onPressed: () {
              context.read<ClipboardProvider>().toggleFavorite(clip);
            },
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, size: 24, color: theme.colorScheme.error),
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
                color: (isLink ? linkAccent : primaryAccent).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isLink ? 'Link' : 'Teks',
                style: GoogleFonts.inter(
                  color: isLink ? linkAccent : primaryAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              clip.content,
              style: GoogleFonts.inter(
                fontSize: 18,
                height: 1.6,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 32),
            Divider(color: isDark ? Colors.white12 : const Color(0xFFECEEF0)),
            const SizedBox(height: 16),
            _buildInfoRow(context, Icons.calendar_today_outlined, 'Dibuat pada', timeStr),
            const SizedBox(height: 16),
            _buildInfoRow(context, Icons.sync_rounded, 'Status Sinkronisasi', clip.isSynced ? 'Sudah disinkronkan' : 'Menunggu sinkronisasi'),
            const SizedBox(height: 48),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _copyToClipboard(context, clip.content),
                    icon: Icon(Icons.copy_all_rounded, color: isDark ? const Color(0xFF0B1326) : Colors.white),
                    label: Text(
                      'Salin Teks',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFF0B1326) : Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Fluttertoast.showToast(
                        msg: "Fitur Bagikan belum tersedia",
                        toastLength: Toast.LENGTH_SHORT,
                        backgroundColor: isDark ? Colors.white : const Color(0xFF191C1E),
                        textColor: isDark ? const Color(0xFF0B1326) : Colors.white,
                      );
                    },
                    icon: Icon(Icons.share_outlined, color: theme.colorScheme.onSurface),
                    label: Text(
                      'Bagikan',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: isDark ? Colors.white24 : const Color(0xFFECEEF0)),
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

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Icon(icon, size: 22, color: isDark ? Colors.white54 : const Color(0xFF737785)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label, 
                style: GoogleFonts.inter(fontSize: 12, color: isDark ? Colors.white54 : const Color(0xFF737785)),
              ),
              const SizedBox(height: 2),
              Text(
                value, 
                style: GoogleFonts.inter(
                  fontSize: 14, 
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Clipboard.setData(ClipboardData(text: text));
    Fluttertoast.showToast(
      msg: "Berhasil disalin",
      backgroundColor: isDark ? Colors.white : const Color(0xFF191C1E),
      textColor: isDark ? const Color(0xFF0B1326) : Colors.white,
    );
  }

  void _confirmDelete(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Hapus Item?', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
        content: Text('Item ini akan dihapus dari riwayat lokal.', style: GoogleFonts.inter(color: isDark ? Colors.white70 : Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text('Batal', style: TextStyle(color: isDark ? Colors.white60 : Colors.black54)),
          ),
          TextButton(
            onPressed: () {
              context.read<ClipboardProvider>().deleteClip(clip.id!);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close detail screen
            },
            child: Text('Hapus', style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
