import 'package:flutter/material.dart';
import '../../widgets/app_drawer.dart';

class HistoryListScreen extends StatelessWidget {
  const HistoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // mock ข้อมูลประวัติ
    final items = List.generate(8, (i) => DateTime.now().subtract(Duration(days: i)));

    return Scaffold(
      appBar: AppBar(title: const Text('ประวัติการถ่าย')),
      drawer: const AppDrawer(),
      body: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 0),
        itemBuilder: (context, i) {
          final dt = items[i];
          return ListTile(
            leading: const Icon(Icons.image),
            title: Text('Session ${i + 1}'),
            subtitle: Text(dt.toString()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {}, // ภายหลังเปิดรายละเอียด
          );
        },
      ),
    );
  }
}
