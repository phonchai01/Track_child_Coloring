import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../services/metrics/zscore_service.dart';

class ResultSummaryScreen extends StatelessWidget {
  const ResultSummaryScreen({super.key});

  double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  Map<String, double> _extractMetricsDynamic(dynamic m) {
    final h = _toDouble(
      (m?.h) ??
          (m?.H) ??
          (m?.entropy) ??
          (m?.entropyValue) ??
          (m?['h']) ??
          (m?['H']) ??
          (m?['entropy']),
    );

    final c = _toDouble(
      (m?.c) ??
          (m?.C) ??
          (m?.complexity) ??
          (m?.dstar) ??
          (m?.Dstar) ??
          (m?.dStar) ??
          (m?['c']) ??
          (m?['complexity']) ??
          (m?['dstar']),
    );

    final blank = _toDouble(
      (m?.blank) ??
          (m?.blankCoverage) ??
          (m?.coverageBlank) ??
          (m?['blank']) ??
          (m?['blankCoverage']) ??
          (m?['coverageBlank']),
    );

    final cotl = _toDouble(
      (m?.cotl) ??
          (m?.cotlOutside) ??
          (m?.outside) ??
          (m?['cotl']) ??
          (m?['cotlOutside']) ??
          (m?['outside']),
    );

    return {'h': h, 'c': c, 'blank': blank, 'cotl': cotl};
  }

  Widget _metricTile(String label, double value) {
    return ListTile(
      title: Text(label),
      trailing: Text(value.toStringAsFixed(4)),
      dense: true,
    );
  }

  Widget _zBadge(double z) {
    String label;
    if (z <= -2) {
      label = 'ต่ำมาก (≤ -2σ)';
    } else if (z < -1) {
      label = 'ต่ำ (-1σ)';
    } else if (z > 2) {
      label = 'สูงมาก (≥ 2σ)';
    } else if (z > 1) {
      label = 'สูง (+1σ)';
    } else {
      label = 'ปกติ';
    }
    return Chip(label: Text('${z.toStringAsFixed(2)} • $label'));
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final String templateKey =
        (args?['templateKey'] ?? args?['template'])?.toString() ?? '-';

    final dynamic ageRaw = args?['age'];
    final int age = (ageRaw is int) ? ageRaw : int.tryParse('${ageRaw ?? ''}') ?? 0;

    final dynamic metricsObj = args?['metrics'];
    final z = args?['zscore'] as ZScoreResult?;
    final Uint8List? previewBytes = args?['imageBytes'] as Uint8List?;

    final mm = _extractMetricsDynamic(metricsObj);

    return Scaffold(
      appBar: AppBar(title: const Text('สรุปผลการประมวลผล')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (previewBytes != null) ...[
            AspectRatio(
              aspectRatio: 1,
              child: Image.memory(previewBytes, fit: BoxFit.contain),
            ),
            const SizedBox(height: 16),
          ],

          Card(
            child: ListTile(
              title: Text('เทมเพลต: $templateKey'),
              subtitle: Text('อายุ: ${age == 0 ? "-" : "$age ขวบ"}'),
            ),
          ),
          const SizedBox(height: 12),

          // ค่าดิบ (อ่านแบบ dynamic)
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ListTile(
                  title: Text('ค่าตัวชี้วัด (ดิบ)'),
                  dense: true,
                ),
                _metricTile('H (Entropy)', mm['h'] ?? 0.0),
                _metricTile('D* / C (Complexity)', mm['c'] ?? 0.0),
                _metricTile('Blank (ในเส้น)', mm['blank'] ?? 0.0),
                _metricTile('COTL (นอกเส้น)', mm['cotl'] ?? 0.0),
                const SizedBox(height: 8),
              ],
            ),
          ),
          const SizedBox(height: 12),

          if (z != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Z-Score', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _zBadge(z.h),
                        _zBadge(z.c),
                        _zBadge(z.blank),
                        _zBadge(z.cotl),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ย้อนกลับ'),
          ),
        ],
      ),
    );
  }
}
