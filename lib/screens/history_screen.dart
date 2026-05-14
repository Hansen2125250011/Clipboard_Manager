import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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
    final provider = context.watch<ClipboardProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB), 
      body: RefreshIndicator(
        onRefresh: () => context.read<ClipboardProvider>().loadClips(),
        child: CustomScrollView(
          slivers: [
          SliverAppBar.large(
            backgroundColor: const Color(0xFFF7F9FB),
            title: Text(
              'Riwayat Clipboard',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                color: const Color(0xFF191C1E),
                letterSpacing: -0.01,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.star_outline_rounded, color: Color(0xFF424654)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FavoritesScreen()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Color(0xFF424654)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SearchBar(
                    controller: _searchController,
                    hintText: 'Cari riwayat...',
                    leading: const Icon(Icons.search, color: Color(0xFF737785)),
                    onChanged: (value) {
                      context.read<ClipboardProvider>().setSearchQuery(value);
                    },
                    elevation: WidgetStateProperty.all(0),
                    backgroundColor: WidgetStateProperty.all(const Color(0xFFECEEF0)),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    textStyle: WidgetStateProperty.all(
                      const TextStyle(fontFamily: 'Inter', fontSize: 16),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      _buildCategoryChip('Semua'),
                      _buildCategoryChip('Teks'),
                      _buildCategoryChip('Link'),
                      _buildCategoryChip('Penting'),
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
                        const Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: Color(0xFFC3C6D6),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada riwayat',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontFamily: 'Inter',
                            color: const Color(0xFF737785),
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
        backgroundColor: const Color(0xFFBA1A1A),
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
        child: const Icon(Icons.delete_sweep_outlined),
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        showCheckmark: false,
        backgroundColor: const Color(0xFFECEEF0),
        selectedColor: const Color(0xFF0056D2),
        labelStyle: TextStyle(
          fontFamily: 'Inter',
          color: isSelected ? Colors.white : const Color(0xFF424654),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }

  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Hapus Semua?', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
        content: const Text('Semua riwayat clipboard akan dihapus secara permanen.', style: TextStyle(fontFamily: 'Inter')),
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

class SnippetCard extends StatelessWidget {
  final ClipItem clip;

  const SnippetCard({super.key, required this.clip});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeStr = DateFormat('HH:mm • dd MMM').format(clip.timestamp);
    final isLink = clip.content.startsWith('http');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // Stitch Card radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFECEEF0), width: 1),
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
                        color: isLink ? const Color(0xFF006591).withOpacity(0.1) : const Color(0xFF0056D2).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isLink ? Icons.link : Icons.short_text,
                            size: 14,
                            color: isLink ? const Color(0xFF006591) : const Color(0xFF0040A1),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isLink ? 'Link' : 'Teks',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontFamily: 'Inter',
                              color: isLink ? const Color(0xFF006591) : const Color(0xFF0040A1),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          timeStr,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontFamily: 'Inter',
                            color: const Color(0xFF737785),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: Icon(
                            clip.isFavorite ? Icons.star : Icons.star_border,
                            size: 20,
                            color: clip.isFavorite ? const Color(0xFF0056D2) : const Color(0xFF737785),
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
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontFamily: 'Inter',
                    color: const Color(0xFF191C1E),
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
                          const Icon(
                            Icons.copy_all_rounded,
                            size: 18,
                            color: Color(0xFF0040A1),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Copy to Clipboard',
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontFamily: 'Inter',
                              color: const Color(0xFF0040A1),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Color(0xFFBA1A1A)),
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
    Clipboard.setData(ClipboardData(text: text));
    Fluttertoast.showToast(
      msg: "Berhasil disalin ke clipboard",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: const Color(0xFF191C1E),
      textColor: Colors.white,
      fontSize: 14.0
    );
  }
}
