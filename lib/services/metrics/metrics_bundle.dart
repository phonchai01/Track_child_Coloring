import 'dart:typed_data';

import 'entropy_service.dart';
import 'complexity_service.dart';
import 'coverage_blank_service.dart';
import 'cotl_outside_service.dart';

class MetricsResult {
  final double h, dstar, cotl, blank;
  MetricsResult({
    required this.h,
    required this.dstar,
    required this.cotl,
    required this.blank,
  });
}

class MetricsBundle {
  final _entropy = EntropyService();
  final _complex = ComplexityService();
  final _blank = CoverageBlankService();
  final _cotl = CotlOutsideService();

  Future<MetricsResult> computeAll({
    required Uint8List imageBytes,
    required Uint8List maskBytes,
  }) async {
    final h = _entropy.computeNormalizedEntropyFromBytes(imageBytes);
    final d = _complex.computeDStarFromBytes(imageBytes);
    final b = _blank.computeBlankInside(imageBytes: imageBytes, maskBytes: maskBytes);
    final c = _cotl.computeCotl(imageBytes: imageBytes, maskBytes: maskBytes);
    return MetricsResult(h: h, dstar: d, cotl: c, blank: b);
  }
}
