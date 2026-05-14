import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ClipItem {
  final int? id;
  final String content;
  final DateTime timestamp;
  final bool isFavorite;
  final bool isSynced; // New field

  ClipItem({
    this.id,
    required this.content,
    required this.timestamp,
    this.isFavorite = false,
    this.isSynced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isFavorite': isFavorite ? 1 : 0,
      'isSynced': isSynced ? 1 : 0,
    };
  }

  factory ClipItem.fromMap(Map<String, dynamic> map) {
    DateTime parsedTime = DateTime.now();
    if (map['timestamp'] != null) {
      try {
        final ts = map['timestamp'];
        if (ts is int) {
          parsedTime = DateTime.fromMillisecondsSinceEpoch(ts);
        } else {
          parsedTime = DateTime.parse(ts.toString());
        }
      } catch (_) {}
    }

    bool fav = false;
    if (map['isFavorite'] != null) {
      fav = map['isFavorite'] == 1 || map['isFavorite'] == true || map['isFavorite'] == '1';
    }

    bool syn = false;
    if (map['isSynced'] != null) {
      syn = map['isSynced'] == 1 || map['isSynced'] == true || map['isSynced'] == '1';
    }

    return ClipItem(
      id: map['id'],
      content: map['content']?.toString() ?? '',
      timestamp: parsedTime,
      isFavorite: fav,
      isSynced: syn,
    );
  }
}

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  static Database? _database;

  factory DBHelper() => _instance;

  DBHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'clipboard_history.db');
    return await openDatabase(
      path,
      version: 2, // Upgrade to version 2
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE clips (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        isFavorite INTEGER NOT NULL DEFAULT 0,
        isSynced INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE clips ADD COLUMN isSynced INTEGER NOT NULL DEFAULT 0');
    }
  }

  Future<int> insertClip(ClipItem clip) async {
    final db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'clips',
      orderBy: 'timestamp DESC',
      limit: 1,
    );
    
    if (maps.isNotEmpty) {
      if (maps.first['content'] == clip.content) {
        return -1;
      }
    }

    return await db.insert('clips', clip.toMap());
  }

  // New method to get unsynced clips
  Future<List<ClipItem>> getUnsyncedClips() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('clips', where: 'isSynced = 0');
    final List<ClipItem> results = [];
    for (var map in maps) {
      try {
        results.add(ClipItem.fromMap(map));
      } catch (_) {}
    }
    return results;
  }

  // Update sync status
  Future<void> markAsSynced(int id) async {
    final db = await database;
    await db.update('clips', {'isSynced': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<ClipItem>> getAllClips() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('clips', orderBy: 'timestamp DESC');
    final List<ClipItem> results = [];
    for (var map in maps) {
      try {
        results.add(ClipItem.fromMap(map));
      } catch (_) {}
    }
    return results;
  }

  Future<int> deleteClip(int id) async {
    final db = await database;
    return await db.delete('clips', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> toggleFavorite(int id, bool currentStatus) async {
    final db = await database;
    return await db.update(
      'clips',
      {'isFavorite': currentStatus ? 0 : 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('clips');
  }
}
