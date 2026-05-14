import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clipboard_history_manager/main.dart';
import 'package:clipboard_history_manager/database/db_helper.dart';
import 'package:clipboard_history_manager/screens/settings_screen.dart';
import 'package:clipboard_history_manager/screens/detail_screen.dart';
import 'package:clipboard_history_manager/screens/favorites_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface, 
      body: RefreshIndicator(
        onRefresh: () => context.read<ClipboardProvider>().loadClips(),
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              backgroundColor: theme.colorScheme.surface,
              title: Text(
                'Riwayat Clipboard',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: SearchBar(
                      controller: _searchController,
                      hintText: 'Cari riwayat...',
                      hintStyle: WidgetStateProperty.all(
                        TextStyle(color: isDark ? Colors.white38 : const Color(0xFF737785)),
                      ),
                      leading: Icon(Icons.search, color: isDark ? Colors.white54 : const Color(0xFF737785)),
                      onChanged: (value) {
                        context.read<ClipboardProvider>().setSearchQuery(value);
                      },
                      elevation: WidgetStateProperty.all(0),
                      backgroundColor: WidgetStateProperty.all(
                        isDark ? theme.colorScheme.surfaceContainer : const Color(0xFFECEEF0),
                      ),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.transparent,
                          ),
                        ),
                      ),
                      textStyle: WidgetStateProperty.all(
                        GoogleFonts.inter(fontSize: 16, color: theme.colorScheme.onSurface),
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        _buildCategoryChip('Semua', isDark),
                        _buildCategoryChip('Teks', isDark),
                        _buildCategoryChip('Link', isDark),
                        _buildCategoryChip('Penting', isDark),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Consumer<ClipboardProvider>(
              builder: (context, provider, child) {
                final filteredClips = provider.filteredClips;

                if (filteredClips.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: isDark ? Colors.white24 : const Color(0xFFC3C6D6),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada riwayat',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: isDark ? Colors.white54 : const Color(0xFF737785),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final clip = filteredClips[index];
                        return SnippetCard(clip: clip);
                      },
                      childCount: filteredClips.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _confirmClearAll(context),
        elevation: 4,
        backgroundColor: isDark ? theme.colorScheme.error : const Color(0xFFBA1A1A),
        foregroundColor: isDark ? const Color(0xFF0B1326) : Colors.white,
        shape: const StadiumBorder(),
        child: const Icon(Icons.delete_sweep_outlined),
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isDark) {
    final theme = Theme.of(context);
    final provider = context.watch<ClipboardProvider>();
    final isSelected = provider.selectedCategory == label;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (value) {
          context.read<ClipboardProvider>().setSelectedCategory(label);
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected 
              ? Colors.transparent 
              : (isDark ? Colors.white12 : const Color(0xFFECEEF0)),
          ),
        ),
        showCheckmark: false,
        backgroundColor: isDark ? theme.colorScheme.surfaceContainer : const Color(0xFFECEEF0),
        selectedColor: isDark ? theme.colorScheme.primary : const Color(0xFF0056D2),
        labelStyle: GoogleFonts.inter(
          color: isSelected 
            ? (isDark ? const Color(0xFF0B1326) : Colors.white) 
            : (isDark ? Colors.white70 : const Color(0xFF424654)),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 14,
        ),
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
        title: Text(
          'Hapus Semua?', 
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
        ),
        content: Text(
          'Semua riwayat clipboard akan dihapus secara permanen.', 
          style: GoogleFonts.inter(color: isDark ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: isDark ? Colors.white60 : Colors.black54)),
          ),
          TextButton(
            onPressed: () {
              Provider.of<ClipboardProvider>(context, listen: false).clearAll();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
            child: const Text('Hapus Semua', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class SnippetCard extends StatelessWidget {
  final ClipItem clip;

  const SnippetCard({super.key, required this.clip});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final timeStr = DateFormat('HH:mm • dd MMM').format(clip.timestamp);
    final isLink = clip.content.startsWith('http');

    final primaryAccent = isDark ? theme.colorScheme.primary : const Color(0xFF0056D2);
    final linkAccent = isDark ? const Color(0xFF70B5FF) : const Color(0xFF006591);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surfaceContainer : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFECEEF0), 
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DetailScreen(clip: clip)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isLink ? linkAccent : primaryAccent).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isLink ? Icons.link : Icons.short_text,
                            size: 14,
                            color: isLink ? linkAccent : primaryAccent,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isLink ? 'Link' : 'Teks',
                            style: GoogleFonts.inter(
                              color: isLink ? linkAccent : primaryAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          timeStr,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : const Color(0xFF737785),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: Icon(
                            clip.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                            size: 22,
                            color: clip.isFavorite ? primaryAccent : (isDark ? Colors.white38 : const Color(0xFF737785)),
                          ),
                          onPressed: () {
                            Provider.of<ClipboardProvider>(context, listen: false).toggleFavorite(clip);
                          },
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  clip.content,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: theme.colorScheme.onSurface,
                    height: 1.5,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => _copyToClipboard(context, clip.content),
                      child: Row(
                        children: [
                          Icon(
                            Icons.copy_all_rounded,
                            size: 18,
                            color: primaryAccent,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Copy to Clipboard',
                            style: GoogleFonts.inter(
                              color: primaryAccent,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline_rounded, size: 20, color: theme.colorScheme.error),
                      onPressed: () {
                        Provider.of<ClipboardProvider>(context, listen: false).deleteClip(clip.id!);
                      },
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Clipboard.setData(ClipboardData(text: text));
    Fluttertoast.showToast(
      msg: "Berhasil disalin ke clipboard",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: isDark ? Colors.white : const Color(0xFF191C1E),
      textColor: isDark ? const Color(0xFF0B1326) : Colors.white,
      fontSize: 14.0
    );
  }
}
