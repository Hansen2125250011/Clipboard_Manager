import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clipboard_history_manager/database/db_helper.dart';
import 'package:clipboard_history_manager/screens/history_screen.dart';
import 'package:clipboard_history_manager/screens/login_screen.dart';
import 'package:clipboard_history_manager/services/firebase_service.dart';
import 'package:clipboard_history_manager/services/clipboard_listener.dart';
import 'package:clipboard_history_manager/screens/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase Error: $e');
  }
  
  final clipboardProvider = ClipboardProvider()..loadClips();
  final watcher = MyClipboardWatcher(clipboardProvider);
  watcher.start();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: clipboardProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clipboard Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0056D2),
          primary: const Color(0xFF0040A1),
          surface: const Color(0xFFF7F9FB),
          onSurface: const Color(0xFF191C1E),
          secondary: const Color(0xFF515F74),
          error: const Color(0xFFBA1A1A),
        ),
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _shouldShowOnboarding(),
      builder: (context, onboardingSnapshot) {
        if (onboardingSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (onboardingSnapshot.data == true) {
          return const OnboardingScreen();
        }

        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, authSnapshot) {
            if (authSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            if (authSnapshot.hasData) {
              return const HistoryScreen();
            }
            return const LoginScreen();
          },
        );
      },
    );
  }

  Future<bool> _shouldShowOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('showOnboarding') ?? true;
  }
}

class ClipboardProvider with ChangeNotifier {
  List<ClipItem> _clips = [];
  List<ClipItem> get clips => _clips;
  final FirebaseService _firebaseService = FirebaseService();
  bool _isSyncing = false;

  // New fields for filtering
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Computed filtered list
  List<ClipItem> get filteredClips {
    return _clips.where((clip) {
      final matchesSearch = clip.content.toLowerCase().contains(_searchQuery);
      var matchesCategory = true;
      if (_selectedCategory == 'Link') {
        matchesCategory = clip.content.contains('http');
      } else if (_selectedCategory == 'Penting') {
        matchesCategory = clip.isFavorite;
      } else if (_selectedCategory == 'Teks') {
        matchesCategory = !clip.content.contains('http');
      }
      return matchesSearch && matchesCategory;
    }).toList();
  }

  Future<void> loadClips() async {
    _clips = await DBHelper().getAllClips();
    notifyListeners();
    
    // Background tasks
    _syncUnsyncedItems();
    fetchFromCloud();
  }

  Future<void> fetchFromCloud() async {
    if (_firebaseService.currentUser == null) return;
    
    final cloudClips = await _firebaseService.fetchAllClips();
    if (cloudClips.isEmpty) return;

    bool addedAny = false;
    for (var cloudClip in cloudClips) {
      final String content = cloudClip['content'];
      // Check if already in local _clips (by content)
      final exists = _clips.any((c) => c.content == content);
      
      if (!exists) {
        final newClip = ClipItem(
          content: content,
          timestamp: cloudClip['timestamp'],
          isFavorite: cloudClip['isFavorite'] ?? false,
          isSynced: true,
        );
        await DBHelper().insertClip(newClip);
        addedAny = true;
      }
    }

    if (addedAny) {
      _clips = await DBHelper().getAllClips();
      notifyListeners();
    }
  }

  Future<void> _syncUnsyncedItems() async {
    if (_isSyncing || _firebaseService.currentUser == null) return;
    
    _isSyncing = true;
    final unsynced = await DBHelper().getUnsyncedClips();
    
    if (unsynced.isNotEmpty) {
      debugPrint('Menyinkronkan ${unsynced.length} data ke Cloud...');
      for (var clip in unsynced) {
        try {
          await _firebaseService.syncClip(clip.content);
          await DBHelper().markAsSynced(clip.id!);
          
          // Update in-memory sync status
          final index = _clips.indexWhere((c) => c.id == clip.id);
          if (index != -1) {
            _clips[index] = ClipItem(
              id: _clips[index].id,
              content: _clips[index].content,
              timestamp: _clips[index].timestamp,
              isFavorite: _clips[index].isFavorite,
              isSynced: true,
            );
          }
        } catch (e) {
          debugPrint('Gagal sinkron id ${clip.id}: $e');
        }
      }
      notifyListeners();
    }
    _isSyncing = false;
  }

  Future<void> addClip(String content) async {
    // Basic duplicate check in memory
    if (_clips.isNotEmpty && _clips.first.content == content) return;

    final newClip = ClipItem(
      content: content, 
      timestamp: DateTime.now(),
      isSynced: false,
    );
    
    final id = await DBHelper().insertClip(newClip);
    if (id != -1) {
      // Add to memory immediately
      final clipWithId = ClipItem(
        id: id,
        content: newClip.content,
        timestamp: newClip.timestamp,
        isFavorite: newClip.isFavorite,
        isSynced: false,
      );
      _clips.insert(0, clipWithId);
      notifyListeners();

      // Try to sync immediately
      try {
        await _firebaseService.syncClip(content);
        await DBHelper().markAsSynced(id);
        
        // Update sync status in memory
        final index = _clips.indexWhere((c) => c.id == id);
        if (index != -1) {
          _clips[index] = ClipItem(
            id: id,
            content: content,
            timestamp: clipWithId.timestamp,
            isFavorite: clipWithId.isFavorite,
            isSynced: true,
          );
          notifyListeners();
        }
      } catch (_) {}
    }
  }

  Future<void> deleteClip(int id) async {
    // Remove from memory immediately
    _clips.removeWhere((clip) => clip.id == id);
    notifyListeners();
    
    // Background delete
    await DBHelper().deleteClip(id);
  }

  Future<void> toggleFavorite(ClipItem clip) async {
    final index = _clips.indexWhere((c) => c.id == clip.id);
    if (index != -1) {
      // Update in memory immediately
      final updatedClip = ClipItem(
        id: clip.id,
        content: clip.content,
        timestamp: clip.timestamp,
        isFavorite: !clip.isFavorite,
        isSynced: clip.isSynced,
      );
      _clips[index] = updatedClip;
      notifyListeners();

      // Background DB update
      await DBHelper().toggleFavorite(clip.id!, clip.isFavorite);
      
      // Sync to cloud
      await _firebaseService.updateFavorite(clip.content, !clip.isFavorite);
    }
  }

  Future<void> clearAll() async {
    _clips.clear();
    notifyListeners();
    await DBHelper().clearAll();
  }
}
