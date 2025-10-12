import 'dart:typed_data';
import 'dart:math' as math;
import 'package:image/image.dart' as img;

/// Shannon entropy แบบ normalize เป็น [0,1] จากการแจกแจงความน่าจะเป็น p
double _shannonNormalized(List<double> p) {
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

class EntropyService {
  /// คำนวณ Entropy แบบ normalize จากภาพ (แปลงเป็น gray แล้วทำฮิสโตแกรม 256 bin)
  double computeNormalizedEntropyFromBytes(Uint8List imageBytes) {
    final im = img.decodeImage(imageBytes);
    if (im == null) return 0.0;

    // ทำเป็น gray + ฮิสโตแกรม 0..255
    final w = im.width, h = im.height;
    final hist = List<int>.filled(256, 0);
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final c = im.getPixel(x, y);
        final r = img.getRed(c), g = img.getGreen(c), b = img.getBlue(c);
        final v = (0.2126 * r + 0.7152 * g + 0.0722 * b).round().clamp(0, 255);
        hist[v] += 1;
      }
    }

    // แปลงเป็นความน่าจะเป็น
    final total = (w * h).toDouble();
    if (total <= 0) return 0.0;
    final p = List<double>.generate(256, (i) => hist[i] / total);

    return _shannonNormalized(p);
  }
}
