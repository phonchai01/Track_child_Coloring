import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../../widgets/loading_indicator.dart';
import '../../services/metrics/zscore_service.dart';
import '../../data/repositories/session_repo.dart';
import '../result/result_summary_screen.dart';

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  bool _started = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _run();
  }

  double _readAsDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  Map<String, double> _extractMetricsDynamic(dynamic m) {
    final h = _readAsDouble(
      (m?.h) ?? (m?.H) ?? (m?.entropy) ?? (m?.entropyValue) ?? (m?['h']) ?? (m?['H']) ?? (m?['entropy']),
    );
    final c = _readAsDouble(
      (m?.c) ?? (m?.C) ?? (m?.complexity) ?? (m?.dstar) ?? (m?.Dstar) ?? (m?.dStar) ?? (m?['c']) ?? (m?['complexity']) ?? (m?['dstar']),
    );
    final blank = _readAsDouble(
      (m?.blank) ?? (m?.blankCoverage) ?? (m?.coverageBlank) ?? (m?['blank']) ?? (m?['blankCoverage']) ?? (m?['coverageBlank']),
    );
    final cotl = _readAsDouble(
      (m?.cotl) ?? (m?.cotlOutside) ?? (m?.outside) ?? (m?['cotl']) ?? (m?['cotlOutside']) ?? (m?['outside']),
    );
    return {'h': h, 'c': c, 'blank': blank, 'cotl': cotl};
  }

  Future<void> _run() async {
    try {
      final args = (ModalRoute.of(context)?.settings.arguments as Map?) ?? const {};

      final String templateKey = (args['templateKey'] ?? args['template'])?.toString() ?? '';
      final dynamic ageRaw = args['age'];
      final int age = (ageRaw is int) ? ageRaw : int.tryParse('${ageRaw ?? ''}') ?? 4;

      final Uint8List? imageBytes = args['imageBytes'] as Uint8List?;
      final Uint8List? maskBytes  = args['maskBytes']  as Uint8List?;

      final dynamic metricsObj = args['metrics'];
      if (metricsObj == null) {
        // ถ้าต้องคำนวณ metrics ที่นี่ ให้ใส่โค้ดของคุณแทนการ throw
        throw Exception('ไม่พบ metrics ใน arguments (คาดว่าหน้าก่อนคำนวณแล้วส่งมาที่นี่)');
      }

      final mm = _extractMetricsDynamic(metricsObj);

      // --- Z-Score ---
      final z = await ZScoreService.instance.compute(
        templateKey: templateKey,
        age: age,
        h: mm['h'] ?? 0.0,
        c: mm['c'] ?? 0.0,
        blank: mm['blank'] ?? 0.0,
        cotl: mm['cotl'] ?? 0.0,
      );

      // --- บันทึก session (อยู่ "ใน" ฟังก์ชัน async เท่านั้นนะ) ---
      await SessionRepo.instance.save(
        templateKey: templateKey,
        age: age,
        metrics: {
          'h': mm['h'] ?? 0.0,
          'c': mm['c'] ?? 0.0,
          'blank': mm['blank'] ?? 0.0,
          'cotl': mm['cotl'] ?? 0.0,
        },
        zscore: {
          'h': z.h,
          'c': z.c,
          'blank': z.blank,
          'cotl': z.cotl,
        },
        extra: {
          // ใส่ข้อมูลเพิ่มเติมได้ เช่น fileName, note ฯลฯ
        },
      );

      if (!mounted) return;

      // --- ไปหน้า Result ---
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const ResultSummaryScreen(),
          settings: RouteSettings(arguments: {
            ...args,
            'templateKey': templateKey,
            'age': age,
            'metrics': metricsObj,
            'zscore': z,
            'imageBytes': imageBytes,
            'maskBytes': maskBytes,
          }),
        ),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Processing')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'เกิดข้อผิดพลาดระหว่างประมวลผล:\n$_error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    return const Scaffold(
      body: Center(child: LoadingIndicator(message: 'กำลังประมวลผล...')),
    );
  }
}
