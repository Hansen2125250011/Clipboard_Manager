import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:clipboard_history_manager/main.dart';
import 'package:clipboard_history_manager/screens/history_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        automaticallyImplyLeading: false,
        title: Text(
          'Item Tersimpan',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: Consumer<ClipboardProvider>(
        builder: (context, provider, child) {
          final favoriteClips = provider.clips.where((c) => c.isFavorite).toList();

          if (favoriteClips.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star_border_rounded, 
                    size: 64, 
                    color: isDark ? Colors.white24 : const Color(0xFFC3C6D6),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada item favorit',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: isDark ? Colors.white54 : const Color(0xFF737785),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favoriteClips.length,
            itemBuilder: (context, index) {
              return SnippetCard(clip: favoriteClips[index]);
            },
          );
        },
      ),
    );
  }
}
