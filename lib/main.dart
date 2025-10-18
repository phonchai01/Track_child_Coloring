import 'package:flutter/material.dart';
import 'routes.dart';

void main() {
  runApp(const ColoringApp());
}

class ColoringApp extends StatelessWidget {
  const ColoringApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coloring Metrics',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      ),
      initialRoute: AppRoutes.profilePicker, // ✅ ให้เริ่มที่หน้าเลือกโปรไฟล์
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
