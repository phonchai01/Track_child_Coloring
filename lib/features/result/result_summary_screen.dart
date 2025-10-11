import 'package:flutter/material.dart';
import '../../routes.dart';
import '../../widgets/app_drawer.dart';

class ResultSummaryScreen extends StatelessWidget {
  const ResultSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = (ModalRoute.of(context)!.settings.arguments ?? {}) as Map;

    return Scaffold(
      appBar: AppBar(title: const Text('ผลลัพธ์ครั้งนี้')),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _metricRow('H (entropy)', data['h']),
            _metricRow('D* (complexity)', data['dstar']),
            _metricRow('COTL (ออกนอกเส้น)', data['cotl']),
            _metricRow('Blank (ในเส้น)', data['blank']),        // ← เพิ่มบรรทัดนี้
            const Divider(height: 32),
            _metricRow('Z(H)', data['z']?['h']),
            _metricRow('Z(D*)', data['z']?['d']),
            _metricRow('Z(COTL)', data['z']?['cotl']),
            _metricRow('Z(Blank)', data['z']?['blank']),         // ← และบรรทัดนี้ (ถ้าจะโชว์)
            const Spacer(),
            FilledButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.trends),
              child: const Text('ดูกราฟความคืบหน้า'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricRow(String name, Object? value) {
    return ListTile(
      dense: true,
      title: Text(name),
      trailing: Text(value?.toString() ?? '-'),
    );
  }
}
