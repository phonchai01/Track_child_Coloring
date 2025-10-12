import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../../routes.dart';
import '../../widgets/loading_indicator.dart';
import '../../services/metrics/metrics_bundle.dart';

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _run();
  }

  Future<void> _run() async {
    // อ่าน arguments อย่างปลอดภัยหลังจาก context พร้อมแล้ว
    final args = (ModalRoute.of(context)?.settings.arguments as Map?) ?? const {};
    final Uint8List? imageBytes = args['imageBytes'] as Uint8List?;
    final Uint8List? maskBytes  = args['maskBytes'] as Uint8List?;
    final String templateKey    = (args['templateKey'] as String?) ?? 'template';

    if (imageBytes == null) {
      // ไม่มีภาพ → กลับหน้าก่อน
      if (!mounted) return;
      Navigator.pop(context);
      return;
    }

    try {
      // คำนวณจริง (Blank/COTL จะเป็น 0 ถ้ายังไม่มี mask)
      final bundle = MetricsBundle();
      final res = await bundle.computeAll(
        imageBytes: imageBytes,
        maskBytes : maskBytes ?? Uint8List(0),
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.result,
        arguments: {
          'h'    : double.parse(res.h.toStringAsFixed(4)),
          'dstar': double.parse(res.dstar.toStringAsFixed(4)),
          'cotl' : double.parse(res.cotl.toStringAsFixed(4)),
          'blank': double.parse(res.blank.toStringAsFixed(4)),
          'z'    : {'h': null, 'd': null, 'cotl': null, 'blank': null},
          'templateKey': templateKey,
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการประมวลผล: $e')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: LoadingIndicator()),
    );
  }
}
