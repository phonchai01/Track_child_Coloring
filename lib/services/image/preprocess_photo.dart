import 'dart:math' as math;
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class PreprocessPhoto {
  /// ทำให้กระดาษขาวขึ้น (คงสี): gray-world WB + stretch Y (p5..p95) + gamma บน Y
  static List<int> enhancePaperKeepColor(
    Uint8List bytes, {
    double targetWhite = 245,
    double gamma = 1.0,
  }) {
    final src = img.decodeImage(bytes);
    if (src == null) return bytes;

    // 1) gray-world white balance
    final balanced = _grayWorld(src);

    // 2) ไป YCbCr แล้วปรับเฉพาะ Y
    final w = balanced.width, h = balanced.height;
    final out = img.Image(w, h); // <-- ใช้ positional args สำหรับ image ^3.x

    final hist = List<int>.filled(256, 0);

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final c = balanced.getPixel(x, y);
        final r = img.getRed(c), g = img.getGreen(c), b = img.getBlue(c);
        final ycbcr = _rgb2ycbcr(r, g, b);
        hist[ycbcr.$1] += 1;
      }
    }
    int p5 = _percentile(hist, 0.05);
    int p95 = _percentile(hist, 0.95);
    if (p95 <= p5) p5 = math.max(0, p95 - 1);

    // 3) LUT สำหรับ stretch + gamma บน Y
    final lut = List<int>.generate(256, (i) {
      double v = (i - p5) / (p95 - p5);
      v = v.clamp(0.0, 1.0);
      if (gamma != 1.0) v = math.pow(v, 1.0 / gamma).toDouble();
      final out = (v * targetWhite).clamp(0.0, 255.0);
      return out.round();
    });

    // 4) เขียนกลับด้วย Y ใหม่
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final c = balanced.getPixel(x, y);
        final r = img.getRed(c), g = img.getGreen(c), b = img.getBlue(c);
        final a = img.getAlpha(c);
        final (Y, Cb, Cr) = _rgb2ycbcr(r, g, b);
        final newY = lut[Y];
        final (nr, ng, nb) = _ycbcr2rgb(newY, Cb, Cr);
        out.setPixelRgba(x, y, nr, ng, nb, a);
      }
    }

    return img.encodeJpg(out, quality: 95);
  }

  // ---------- helpers ----------

  static img.Image _grayWorld(img.Image src) {
    final w = src.width, h = src.height;
    double sumR = 0, sumG = 0, sumB = 0;
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final c = src.getPixel(x, y);
        sumR += img.getRed(c);
        sumG += img.getGreen(c);
        sumB += img.getBlue(c);
      }
    }
    final n = (w * h).toDouble();
    final meanR = sumR / n, meanG = sumG / n, meanB = sumB / n;
    final mean = (meanR + meanG + meanB) / 3.0;
    final gainR = (mean / (meanR + 1e-6));
    final gainG = (mean / (meanG + 1e-6));
    final gainB = (mean / (meanB + 1e-6));

    final out = img.Image.from(src);
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final c = src.getPixel(x, y);
        final r = (img.getRed(c) * gainR).clamp(0, 255).round();
        final g = (img.getGreen(c) * gainG).clamp(0, 255).round();
        final b = (img.getBlue(c) * gainB).clamp(0, 255).round();
        final a = img.getAlpha(c);
        out.setPixelRgba(x, y, r, g, b, a);
      }
    }
    return out;
  }

  // Rec.601
  static (int,int,int) _rgb2ycbcr(int r, int g, int b) {
    final Y  = ( 0.299*r + 0.587*g + 0.114*b).round().clamp(0,255);
    final Cb = (-0.168736*r - 0.331264*g + 0.5*b + 128).round().clamp(0,255);
    final Cr = ( 0.5*r - 0.418688*g - 0.081312*b + 128).round().clamp(0,255);
    return (Y, Cb, Cr);
  }

  static (int,int,int) _ycbcr2rgb(int Y, int Cb, int Cr) {
    final r = (Y + 1.402*(Cr-128)).round().clamp(0,255);
    final g = (Y - 0.344136*(Cb-128) - 0.714136*(Cr-128)).round().clamp(0,255);
    final b = (Y + 1.772*(Cb-128)).round().clamp(0,255);
    return (r, g, b);
  }

  static int _percentile(List<int> hist, double p) {
    final total = hist.fold<int>(0, (a,b)=>a+b);
    final k = (total * p).clamp(0, total > 0 ? total - 1 : 0).toInt();
    int acc = 0;
    for (int i = 0; i < 256; i++) {
      acc += hist[i];
      if (acc > k) return i;
    }
    return 255;
  }
}
