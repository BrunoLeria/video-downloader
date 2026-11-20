import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:video_downloader/models/debug_report.dart';
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
      version: 2,
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
        await db.execute('''
          CREATE TABLE debug_reports (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            createdAt TEXT,
            originalUrl TEXT,
            normalizedUrl TEXT,
            platform TEXT,
            backendUrl TEXT,
            errorMessage TEXT,
            stackTrace TEXT,
            appVersion TEXT,
            deviceJson TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE debug_reports (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              createdAt TEXT,
              originalUrl TEXT,
              normalizedUrl TEXT,
              platform TEXT,
              backendUrl TEXT,
              errorMessage TEXT,
              stackTrace TEXT,
              appVersion TEXT,
              deviceJson TEXT
            )
          ''');
        }
      },
    );
  }

  Future<void> initialize() async {
    await database;
  }

  Future<int> insertDownload(DownloadHistoryItem item) async {
    final db = await database;
    return db.insert(
      'downloads',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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

  Future<int> insertDebugReport(DebugReport report) async {
    final db = await database;
    return db.insert('debug_reports', {
      'createdAt': report.createdAt.toUtc().toIso8601String(),
      'originalUrl': report.originalUrl,
      'normalizedUrl': report.normalizedUrl,
      'platform': report.platform,
      'backendUrl': report.backendUrl,
      'errorMessage': report.errorMessage,
      'stackTrace': report.stackTrace,
      'appVersion': report.appVersion,
      'deviceJson': jsonEncode(report.device),
    });
  }

  Future<List<DebugReport>> fetchDebugReports() async {
    final db = await database;
    final rows = await db.query('debug_reports', orderBy: 'id DESC');
    return rows.map((row) {
      return DebugReport(
        id: row['id'] as int?,
        createdAt:
            DateTime.tryParse(row['createdAt'] as String? ?? '') ??
            DateTime.now(),
        originalUrl: row['originalUrl'] as String? ?? '',
        normalizedUrl: row['normalizedUrl'] as String? ?? '',
        platform: row['platform'] as String? ?? 'unknown',
        backendUrl: row['backendUrl'] as String? ?? '',
        errorMessage: row['errorMessage'] as String? ?? '',
        stackTrace: row['stackTrace'] as String? ?? '',
        appVersion: row['appVersion'] as String? ?? '1.0.0+1',
        device:
            (jsonDecode(row['deviceJson'] as String? ?? '{}')
                as Map<String, dynamic>? ??
            const <String, dynamic>{}),
      );
    }).toList();
  }

  Future<void> deleteDebugReport(int id) async {
    final db = await database;
    await db.delete('debug_reports', where: 'id = ?', whereArgs: [id]);
  }
}
