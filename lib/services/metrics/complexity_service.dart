import 'dart:typed_data';
import 'dart:math' as math;
import 'package:image/image.dart' as img;

/// Shannon entropy normalize [0,1]
double _hNorm(List<double> p) {
  const eps = 1e-12;
  final n = p.length;
  double h = 0.0;
  for (final v in p) {
    final x = (v <= 0) ? eps : v;
    h -= x * math.log(x);
  }
  final hMax = math.log(n);
  return (hMax == 0) ? 0.0 : (h / hMax);
}

/// Jensen–Shannon divergence ระหว่าง P กับยูนิฟอร์ม
double _jsToUniform(List<double> p) {
  final n = p.length;
  final u = 1.0 / n;

  // S(P)
  const eps = 1e-12;
  double sP = 0.0;
  for (final v in p) {
    final x = (v <= 0) ? eps : v;
    sP -= x * math.log(x);
  }

  // S(U)
  final sU = math.log(n);

  // S(M)
  double sM = 0.0;
  for (final v in p) {
    final m = 0.5 * (v + u);
    final y = (m <= 0) ? eps : m;
    sM -= y * math.log(y);
  }

  return sM - 0.5 * sP - 0.5 * sU;
}

/// ค่ามากสุดของ JS(P||U) เมื่อ P = delta (1,0,0,...)
double _jsMaxAgainstUniform(int n) {
  final m0 = (1.0 + 1.0 / n) * 0.5;
  final m = (1.0 / n) * 0.5;
  double sM = 0.0;
  sM -= m0 * math.log(m0);
  sM -= (n - 1) * m * math.log(m);
  final sU = math.log(n);
  return sM - 0.5 * 0.0 - 0.5 * sU; // S(P=delta)=0
}

class ComplexityService {
  /// คำนวณ D* จาก "Permutation distribution (2x2)" -> 24 bins
  /// ขั้นตอน:
  /// 1) แปลงภาพเป็น gray
  /// 2) สไลด์หน้าต่าง 2x2 แบบ stride=1
  /// 3) คำนวณ ordinal permutation 4 จุด (เสมอแตกด้วยตำแหน่ง)
  /// 4) ได้ความถี่ 24 bins -> โปรบ p
  /// 5) H_norm = H(p)/Hmax;  D* = H_norm * (JS(p||U)/JSmax)
  double computeDStarFromBytes(Uint8List imageBytes) {
    final im = img.decodeImage(imageBytes);
    if (im == null || im.width < 2 || im.height < 2) return 0.0;

    final w = im.width, h = im.height;

    // ฮิสโตแกรม 24 bins
    final nBins = 24;
    final hist = List<int>.filled(nBins, 0);
    int total = 0;

    // เดิน 2x2
    for (int y = 0; y < h - 1; y++) {
      for (int x = 0; x < w - 1; x++) {
        // 2x2 (row-major): a b ; c d
        final a = _gray(im.getPixel(x, y));
        final b = _gray(im.getPixel(x + 1, y));
        final c = _gray(im.getPixel(x, y + 1));
        final d = _gray(im.getPixel(x + 1, y + 1));

        final idx = _ordinalIndex4(a, b, c, d); // 0..23
        hist[idx] += 1;
        total += 1;
      }
    }

    if (total == 0) return 0.0;

    // แปลงเป็นโปรบ
    final p = List<double>.generate(nBins, (i) => hist[i] / total);

    final hNorm = _hNorm(p);
    final js = _jsToUniform(p);
    final jsMax = _jsMaxAgainstUniform(nBins);
    final dStar = (jsMax <= 0) ? 0.0 : (hNorm * (js / jsMax));

    // bound ปลอดภัย
    return dStar.clamp(0.0, 1.0);
  }

  // ---------- helpers ----------
  static int _gray(int c) {
    final r = img.getRed(c), g = img.getGreen(c), b = img.getBlue(c);
    return (0.2126 * r + 0.7152 * g + 0.0722 * b).round().clamp(0, 255);
  }

  /// คืน index ของ permutation 4 จุด (0..23) ใช้ stable sort แตก ties ด้วยลำดับตำแหน่ง
  static int _ordinalIndex4(int a, int b, int c, int d) {
    final vals = [a, b, c, d];
    final idxs = [0, 1, 2, 3];

    idxs.sort((i, j) {
      final dv = vals[i] - vals[j];
      return (dv != 0) ? dv : (i - j); // tie-break by position
    });

    // map permutation -> lexicographic index (factorial number system)
    int index = 0;
    final used = [false, false, false, false];
    for (int k = 0; k < 4; k++) {
      int smallerUnused = 0;
      for (int v = 0; v < idxs[k]; v++) {
        if (!used[v]) smallerUnused++;
      }
      index = index * (4 - k) + smallerUnused;
      used[idxs[k]] = true;
    }
    return index;
  }
}
