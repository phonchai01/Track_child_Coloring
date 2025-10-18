import 'package:flutter/material.dart';
import '../../data/repositories/session_repo.dart';
import '../result/result_summary_screen.dart';

class HistoryListScreen extends StatefulWidget {
  const HistoryListScreen({super.key});

  @override
  State<HistoryListScreen> createState() => _HistoryListScreenState();
}

class _HistoryListScreenState extends State<HistoryListScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = SessionRepo.instance.list();
  }

  String _fmtDouble(dynamic v) {
    if (v == null) return '-';
    if (v is num) return v.toStringAsFixed(3);
    return v.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ประวัติการประมวลผล')),
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
            return const Center(child: Text('ยังไม่มีประวัติ'));
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
                  // เปิดดูรายละเอียดด้วย ResultSummaryScreen
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const ResultSummaryScreen(),
                    settings: RouteSettings(arguments: {
                      'templateKey': templateKey,
                      'age': age,
                      'metrics': {
                        'h': m['h'],
                        'c': m['c'],
                        'blank': m['blank'],
                        'cotl': m['cotl'],
                      },
                      'zscore': _fromMapZ(z),
                    }),
                  ));
                },
              );
            },
          );
        },
      ),
    );
  }

  /// แปลง map zscore -> object ที่ ResultSummaryScreen ใช้ได้
  /// ถ้า ResultSummaryScreen ใช้ class ZScoreResult แบบ strict
  /// สามารถเปลี่ยนไปส่งเป็น map ได้เหมือน metrics (และแก้นิดในหน้า Result)
  dynamic _fromMapZ(Map z) {
    // ส่งเป็น map ธรรมดา เพื่อไม่ผูกกับ class ก็ได้:
    return {
      'h': z['h'] ?? 0.0,
      'c': z['c'] ?? 0.0,
      'blank': z['blank'] ?? 0.0,
      'cotl': z['cotl'] ?? 0.0,
    };
  }
}
