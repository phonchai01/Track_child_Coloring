import 'package:flutter/material.dart';
import '../../data/repositories/session_repo.dart';

class TrendsScreen extends StatefulWidget {
  const TrendsScreen({super.key});

  @override
  State<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen> {
  late Future<List<Map<String, dynamic>>> _future; // ← ใช้ Map ให้ตรงกับ SessionRepo

  @override
  void initState() {
    super.initState();
    _future = SessionRepo.instance.list(); // โหลดทั้งหมด (ใหม่ → เก่า)
  }

  String _fmtDouble(dynamic v) {
    if (v == null) return '-';
    if (v is num) return v.toStringAsFixed(3);
    return v.toString();
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trends')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snap.error}'));
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('ยังไม่มีข้อมูล'));
          }

          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final it = items[i];
              final templateKey = (it['templateKey'] ?? '-').toString();
              final age = it['age'] ?? '-';
              final ts = (it['timestamp'] ?? '').toString();

              final m = (it['metrics'] as Map?) ?? {};
              final z = (it['zscore'] as Map?) ?? {};

              return ListTile(
                title: Text('$templateKey • อายุ $age'),
                subtitle: Text(
                  'H:${_fmtDouble(m['h'])}  C:${_fmtDouble(m['c'])}  '
                  'Blank:${_fmtDouble(m['blank'])}  COTL:${_fmtDouble(m['cotl'])}\n'
                  'Z → H:${_fmtDouble(z['h'])}  C:${_fmtDouble(z['c'])}  '
                  'Blank:${_fmtDouble(z['blank'])}  COTL:${_fmtDouble(z['cotl'])}',
                ),
                trailing: Text(
                  ts.isEmpty ? '' : ts.replaceFirst('T', '\n').split('.').first,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                onTap: () {
                  // ภายหลังสามารถพาไปหน้ากราฟ/รายละเอียดได้
                },
              );
            },
          );
        },
      ),
    );
  }
}
