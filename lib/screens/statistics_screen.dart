import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:clipboard_history_manager/main.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = context.watch<ClipboardProvider>();
    final clips = provider.clips;
    
    final totalCount = clips.length;
    final favoriteCount = clips.where((c) => c.isFavorite).length;
    final linkCount = clips.where((c) => c.content.startsWith('http')).length;
    final textCount = totalCount - linkCount;

    final primaryAccent = isDark ? theme.colorScheme.primary : const Color(0xFF0056D2);
    final linkAccent = isDark ? const Color(0xFF70B5FF) : const Color(0xFF006591);
    final favAccent = isDark ? const Color(0xFFFF8B94) : const Color(0xFFBA1A1A);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Statistik Penggunaan', 
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
          _buildSummaryCard(context, totalCount, primaryAccent),
          const SizedBox(height: 32),
          
          // Visualisasi Grafik Distribusi Item Kustom
          Text(
            'Distribusi Kategori',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18, color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 16),
          if (totalCount > 0) ...[
            Container(
              height: 16,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isDark ? Colors.white12 : const Color(0xFFECEEF0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  children: [
                    if (textCount > 0)
                      Expanded(
                        flex: textCount,
                        child: Container(color: primaryAccent),
                      ),
                    if (linkCount > 0)
                      Expanded(
                        flex: linkCount,
                        child: Container(color: linkAccent),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendDot('Teks', primaryAccent),
                const SizedBox(width: 24),
                _buildLegendDot('Tautan', linkAccent),
                const SizedBox(width: 24),
                _buildLegendDot('Favorit', favAccent),
              ],
            ),
          ] else ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Belum ada data untuk divisualisasikan',
                  style: GoogleFonts.inter(color: isDark ? Colors.white38 : const Color(0xFF737785), fontSize: 13),
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 32),
          Text(
            'Detail Kategori',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18, color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 16),
          _buildStatItem(context, Icons.short_text, 'Teks Biasa', textCount, primaryAccent),
          _buildStatItem(context, Icons.link, 'Tautan/Link', linkCount, linkAccent),
          _buildStatItem(context, Icons.star_rounded, 'Item Penting', favoriteCount, favAccent),
          
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? theme.colorScheme.surfaceContainer : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFECEEF0)),
            ),
            child: Column(
              children: [
                Icon(Icons.insights_rounded, size: 48, color: primaryAccent),
                const SizedBox(height: 16),
                Text(
                  'Aktivitas Tersimpan',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.onSurface),
                ),
                const SizedBox(height: 8),
                Text(
                  'Anda telah menyimpan $totalCount item di dalam memori clipboard lokal Anda.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: isDark ? Colors.white70 : const Color(0xFF424654), fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context, int total, Color accentColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
            ? [accentColor.withValues(alpha: 0.3), accentColor.withValues(alpha: 0.1)] 
            : [const Color(0xFF0056D2), const Color(0xFF0040A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? accentColor.withValues(alpha: 0.3) : Colors.transparent),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: const Color(0xFF0056D2).withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Riwayat',
            style: GoogleFonts.inter(color: isDark ? Colors.white70 : Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            total.toString(),
            style: GoogleFonts.inter(
              color: isDark ? accentColor : Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Semua data tersimpan secara aman.',
            style: GoogleFonts.inter(color: isDark ? Colors.white54 : Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String label, int count, Color color) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surfaceContainer : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFECEEF0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15, color: theme.colorScheme.onSurface),
          ),
          const Spacer(),
          Text(
            count.toString(),
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
