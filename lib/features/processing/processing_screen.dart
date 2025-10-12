import 'package:flutter/material.dart';
import '../../routes.dart';
import '../../widgets/loading_indicator.dart';
import '../../data/repositories/session_repo.dart';
import '../../data/models/session.dart';
import '../../services/metrics/metrics_bundle.dart';

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key});
  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  @override
  void initState() {
    super.initState();
    _mockCompute(); // ตอนนี้ยังใช้ mock; จะเปลี่ยนเป็น _computeAndSave() เมื่อถ่ายรูปจริง
  }

  // ไว้ใช้จริงภายหลัง
  Future<void> _computeAndSave({
    required String templateKey,
    required List<int> imageBytes,
    required List<int> maskBytes,
  }) async {
    final bundle = MetricsBundle();
    final res = await bundle.computeAll(imageBytes: imageBytes, maskBytes: maskBytes);

    final s = Session(
      createdAt: DateTime.now(),
      templateKey: templateKey,
      h: res.h,
      dstar: res.dstar,
      cotl: res.cotl,
      blank: res.blank,
    );
    await SessionRepo().insert(s);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.result, arguments: {
      'h': res.h,
      'dstar': res.dstar,
      'cotl': res.cotl,
      'blank': res.blank,
      'z': {'h': null, 'd': null, 'cotl': null, 'blank': null},
    });
  }

  // ชั่วคราวให้ flow เด้งไปหน้าผลลัพธ์ได้
  Future<void> _mockCompute() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.result, arguments: {
      'h': 0.0, 'dstar': 0.0, 'cotl': 0.0, 'blank': 0.0,
      'z': {'h': null, 'd': null, 'cotl': null, 'blank': null},
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: LoadingIndicator()));
  }
}
