import 'package:flutter/material.dart';
import '../../widgets/app_drawer.dart';

class TrendsScreen extends StatelessWidget {
  const TrendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold( // ← ต้องไม่มี const ตรงนี้
      appBar: AppBar(title: const Text('กราฟความคืบหน้า')),
      drawer: const AppDrawer(),
      body: const Center(child: Text('Line charts (H, D*, COTL, Blank)')),
    );
  }
}
