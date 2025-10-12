import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'dart:math' as math;

/// คำนวณสัดส่วน "ยังว่างในเส้น" (Blank) = pixel กระดาษภายในเส้น / pixel ทั้งหมดภายในเส้น
/// - mask: ขาว=ในเส้น, ดำ=นอกเส้น
/// - กระดาษกำหนดจาก: สว่างสูง (Y > paperY) และอิ่มตัวต่ำ (S < paperS)
class CoverageBlankService {
  double computeBlankInside({
    required Uint8List imageBytes,
    required Uint8List maskBytes,
    int paperY = 200,      // ความสว่างที่ถือว่า "ขาว"
    double paperS = 0.18,  // ความอิ่มตัวสีสูงสุดที่ยังถือว่าเป็นกระดาษ
  }) {
    final im = img.decodeImage(imageBytes);
    final maskIm = img.decodeImage(maskBytes);
    if (im == null || maskIm == null) return 0.0;

    // ปรับขนาด mask ให้เท่ารูป (nearest เพื่อรักษาขอบ)
    final m = img.copyResize(maskIm, width: im.width, height: im.height, interpolation: img.Interpolation.nearest);

    int insideTotal = 0;
    int insidePaper = 0;

    for (int y = 0; y < im.height; y++) {
      for (int x = 0; x < im.width; x++) {
        final mk = m.getPixel(x, y);
        final isInside = img.getRed(mk) > 127; // mask ขาว = ในเส้น
        if (!isInside) continue;

        insideTotal++;

        final c = im.getPixel(x, y);
        final r = img.getRed(c), g = img.getGreen(c), b = img.getBlue(c);
        final yLum = (0.2126 * r + 0.7152 * g + 0.0722 * b); // 0..255

        // saturation แบบง่าย (0..1)
        final maxc = math.max(r, math.max(g, b)).toDouble();
        final minc = math.min(r, math.min(g, b)).toDouble();
        final sat = (maxc == 0) ? 0.0 : ((maxc - minc) / maxc);

        final isPaper = (yLum >= paperY) && (sat <= paperS);
        if (isPaper) insidePaper++;
      }
    }

    if (insideTotal == 0) return 0.0;
    final blank = insidePaper / insideTotal;
    return blank.clamp(0.0, 1.0);
  }
}
