import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// สตับเบื้องต้น: ยังไม่ detect มุมกระดาษจริง
/// ตอนนี้ทำแค่ crop ตรงกลาง/resize เพื่อให้ flow ไปก่อนได้
class WarpCrop {
  static img.Image centerCropResize(img.Image src, {int target = 512}) {
    final side = src.width < src.height ? src.width : src.height;
    final x0 = (src.width - side) ~/ 2;
    final y0 = (src.height - side) ~/ 2;
    final cropped = img.copyCrop(src, x: x0, y: y0, width: side, height: side);
    return img.copyResize(cropped, width: target, height: target, interpolation: img.Interpolation.linear);
  }

  /// ที่หลัง: เพิ่ม corner detection + perspective transform
  static img.Image perspectiveStub(img.Image src) => src;
}
