import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/child_profile.dart';

class ChildRepo {
  ChildRepo._();
  static final ChildRepo instance = ChildRepo._();
  static const String _fileName = 'child_profiles.jsonl';

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final f = File('${dir.path}/$_fileName');
    if (!await f.exists()) await f.create(recursive: true);
    return f;
  }

  Future<void> add(ChildProfile p) async {
    final f = await _getFile();
    await f.writeAsString('${jsonEncode(p.toJson())}\n',
        mode: FileMode.append, flush: true);
  }

  Future<List<ChildProfile>> list() async {
    final f = await _getFile();
    if (!await f.exists()) return [];
    final lines = await f.readAsLines();
    final out = <ChildProfile>[];
    for (final l in lines) {
      final s = l.trim();
      if (s.isEmpty) continue;
      try {
        out.add(ChildProfile.fromJson(jsonDecode(s)));
      } catch (_) {}
    }
    out.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return out;
  }

  /// 🔥 เมธอดใหม่: ลบโปรไฟล์ตามชื่อ (ชื่อซ้ำจะถูกลบทั้งหมด)
  Future<void> deleteByName(String name) async {
    final all = await list();
    final remain = all.where((p) => p.name != name).toList();
    final f = await _getFile();
    final sink = f.openWrite();
    for (final p in remain) {
      sink.writeln(jsonEncode(p.toJson()));
    }
    await sink.close();
  }
}
