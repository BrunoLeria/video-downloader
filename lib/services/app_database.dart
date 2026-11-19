import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:video_downloader/models/download_history.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'video_downloader.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE downloads (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            platform TEXT,
            savedAt TEXT,
            fileSizeBytes INTEGER,
            status TEXT,
            filePath TEXT,
            url TEXT
          )
        ''');
      },
    );
  }

  Future<void> initialize() async {
    await database;
  }

  Future<int> insertDownload(DownloadHistoryItem item) async {
    final db = await database;
    return db.insert('downloads', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<DownloadHistoryItem>> fetchDownloads() async {
    final db = await database;
    final rows = await db.query('downloads', orderBy: 'id DESC');
    return rows.map(DownloadHistoryItem.fromMap).toList();
  }

  Future<void> deleteDownload(int id) async {
    final db = await database;
    await db.delete('downloads', where: 'id = ?', whereArgs: [id]);
  }
}
