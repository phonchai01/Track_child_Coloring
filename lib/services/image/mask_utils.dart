import 'dart:typed_data';
import 'package:image/image.dart' as img;

class MaskUtils {
  /// โหลด mask จาก bytes
  static img.Image decodeMask(Uint8List bytes) => img.decodeImage(bytes)!;

  /// รีไซซ์ mask ให้เท่ารูป
  static img.Image resizeTo(img.Image mask, int width, int height) =>
      img.copyResize(mask, width: width, height: height, interpolation: img.Interpolation.nearest);

  /// ทำให้ mask เป็นไบนารี (0/255) จาก threshold
  static img.Image binarize(img.Image mask, {int threshold = 128}) {
    final out = img.Image.from(mask);
    for (final p in out) {
      final l = img.getLuminanceRgb(p.r, p.g, p.b);
      final v = l >= threshold ? 255 : 0;
      p.r = p.g = p.b = v;
      p.a = 255;
    }
    return out;
  }

  /// apply mask: คงค่าเฉพาะบริเวณขาวของ mask (255)
  static img.Image applyMask(img.Image src, img.Image mask) {
    final out = img.Image.from(src);
    for (int y = 0; y < src.height; y++) {
      for (int x = 0; x < src.width; x++) {
        final m = mask.getPixel(x, y);
        if (m.r < 128) { // นอกมาสก์ → ทำให้เป็นขาว/โปร่ง
          out.setPixelRgba(x, y, 255, 255, 255, 255);
        }
      }
    }
    return out;
  }
}
