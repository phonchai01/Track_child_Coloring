import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'dart:math' as math;

/// COTL (Color Outside The Line): สัดส่วน "ระบายออกนอกเส้น"
/// = pixel สีที่อยู่นอกเส้น / pixel สีทั้งหมด (ทั้งในและนอก)
/// - mask: ขาว=ในเส้น, ดำ=นอกเส้น
class CotlOutsideService {
  double computeCotl({
    required Uint8List imageBytes,
    required Uint8List maskBytes,
    int paperY = 200,        // ถ้า Y สูงมาก+S ต่ำ → ถือว่าเป็นกระดาษ ไม่ใช่ "สี"
    double paperS = 0.18,
  }) {
    final im = img.decodeImage(imageBytes);
    final maskIm = img.decodeImage(maskBytes);
    if (im == null || maskIm == null) return 0.0;

    final m = img.copyResize(maskIm, width: im.width, height: im.height, interpolation: img.Interpolation.nearest);

    int coloredAll = 0;
    int coloredOutside = 0;

    for (int y = 0; y < im.height; y++) {
      for (int x = 0; x < im.width; x++) {
        final c = im.getPixel(x, y);
        final r = img.getRed(c), g = img.getGreen(c), b = img.getBlue(c);

        // วัดกระดาษ vs สี
        final yLum = (0.2126 * r + 0.7152 * g + 0.0722 * b); // 0..255
        final maxc = math.max(r, math.max(g, b)).toDouble();
        final minc = math.min(r, math.min(g, b)).toDouble();
        final sat = (maxc == 0) ? 0.0 : ((maxc - minc) / maxc);

        final isPaper = (yLum >= paperY) && (sat <= paperS);
        final isColored = !isPaper; // ไม่ใช่กระดาษ → ถือว่าเป็นสี

        if (!isColored) continue;
        coloredAll++;

        final mk = m.getPixel(x, y);
        final isInside = img.getRed(mk) > 127; // mask ขาว=ในเส้น
        if (!isInside) coloredOutside++;
      }
    }

    if (coloredAll == 0) return 0.0;
    final cotl = coloredOutside / coloredAll;
    return cotl.clamp(0.0, 1.0);
  }
}
