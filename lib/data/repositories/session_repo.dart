import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/session.dart';

class SessionRepo {
  static final SessionRepo _i = SessionRepo._();
  SessionRepo._();
  factory SessionRepo() => _i;

  Database? _db;

  Future<Database> _open() async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'coloring_metrics.db');
    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, v) async {
        await db.execute('''
          CREATE TABLE sessions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            created_at TEXT NOT NULL,
            template_key TEXT NOT NULL,
            h REAL NOT NULL,
            dstar REAL NOT NULL,
            cotl REAL NOT NULL,
            blank REAL NOT NULL
          );
        ''');
        await db.execute('CREATE INDEX idx_sessions_tmpl ON sessions(template_key);');
        await db.execute('CREATE INDEX idx_sessions_time ON sessions(created_at);');
      },
    );
    return _db!;
  }

  Future<int> insert(Session s) async {
    final db = await _open();
    return db.insert('sessions', s.toMap());
  }

  Future<List<Session>> listAll({String? templateKey, int limit = 200}) async {
    final db = await _open();
    final where = templateKey != null ? 'WHERE template_key=?' : '';
    final args = templateKey != null ? [templateKey] : <Object?>[];
    final rows = await db.rawQuery(
      'SELECT * FROM sessions $where ORDER BY created_at ASC LIMIT ?',
      [...args, limit],
    );
    return rows.map(Session.fromMap).toList();
  }

  Future<void> clearAll() async {
    final db = await _open();
    await db.delete('sessions');
  }
}
