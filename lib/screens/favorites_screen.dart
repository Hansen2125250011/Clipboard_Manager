import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clipboard_history_manager/main.dart';
import 'package:clipboard_history_manager/screens/history_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9FB),
        title: const Text(
          'Item Tersimpan',
          style: TextStyle(fontWeight: FontWeight.bold),
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
                  const Icon(Icons.star_border_rounded, size: 64, color: Color(0xFFC3C6D6)),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada item favorit',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF737785),
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
