import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// รูปแบบข้อมูลที่ยืดหยุ่น:
/// - templateKey: String
/// - age: int
/// - metrics: { h, c, blank, cotl }
/// - zscore:  { h, c, blank, cotl }
/// - timestamp: ISO8601
/// - extra: Map (อะไรก็ได้)
class SessionRepo {
  SessionRepo._();
  static final SessionRepo instance = SessionRepo._();

  static const String _fileName = 'sessions.jsonl';

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final f = File('${dir.path}/$_fileName');
    if (!await f.exists()) {
      await f.create(recursive: true);
    }
    return f;
  }

  /// บันทึก 1 session เป็น 1 บรรทัด (JSONL)
  Future<void> save({
    required String templateKey,
    required int age,
    required Map<String, double> metrics, // {h,c,blank,cotl}
    required Map<String, double> zscore,  // {h,c,blank,cotl}
    DateTime? timestamp,
    Map<String, dynamic>? extra,
  }) async {
    final file = await _getFile();
    final rec = <String, dynamic>{
      'templateKey': templateKey,
      'age': age,
      'metrics': metrics,
      'zscore': zscore,
      'timestamp': (timestamp ?? DateTime.now()).toIso8601String(),
      if (extra != null) ...{'extra': extra},
    };
    await file.writeAsString('${jsonEncode(rec)}\n', mode: FileMode.append, flush: true);
  }

  /// อ่านทั้งหมด (ใหม่สุดอยู่ล่างไฟล์ → จะ reverse ให้ใหม่สุดมาก่อน)
  Future<List<Map<String, dynamic>>> list({int? limit}) async {
    final file = await _getFile();
    final exists = await file.exists();
    if (!exists) return [];

    final lines = await file.readAsLines();
    final out = <Map<String, dynamic>>[];
    for (final line in lines) {
      final l = line.trim();
      if (l.isEmpty) continue;
      try {
        final m = jsonDecode(l) as Map<String, dynamic>;
        out.add(m);
      } catch (_) {
        // ข้ามบรรทัดเสีย
      }
    }
    out.sort((a, b) {
      final at = DateTime.tryParse(a['timestamp'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bt = DateTime.tryParse(b['timestamp'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bt.compareTo(at); // ใหม่ → เก่า
    });
    if (limit != null && out.length > limit) {
      return out.sublist(0, limit);
    }
    return out;
  }

  /// เคลียร์ทั้งหมด (ใช้ตอนรีเซ็ต/ทดสอบ)
  Future<void> clearAll() async {
    final file = await _getFile();
    if (await file.exists()) {
      await file.writeAsString('', flush: true);
    }
  }
}
