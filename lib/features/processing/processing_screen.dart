import 'package:flutter/material.dart';
import '../../routes.dart';
import '../../widgets/loading_indicator.dart';

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  @override
  void initState() {
    super.initState();
    _mockCompute();
  }

  Future<void> _mockCompute() async {
    // จำลองประมวลผลสั้น ๆ แล้วส่งค่าไปหน้า Result
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.result, arguments: {
      'h'    : null,       // ไว้ใส่ทีหลัง
      'dstar': null,       // ไว้ใส่ทีหลัง
      'cotl' : null,       // ไว้ใส่ทีหลัง
      'blank': null,       // แค่ให้ key มีอยู่ หน้าผลลัพธ์จะโชว์แถว Blank ได้เลย
      'z'    : {'h': null, 'd': null, 'cotl': null, 'blank': null},
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: LoadingIndicator()),
    );
  }
}
