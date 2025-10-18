import 'package:flutter/material.dart';

import 'features/templates/template_picker_screen.dart';
import 'features/camera/camera_overlay_screen.dart';
import 'features/camera/review_crop_screen.dart';
import 'features/processing/processing_screen.dart';
import 'features/result/result_summary_screen.dart';
import 'features/history/history_list_screen.dart';
import 'features/trends/trends_screen.dart';

// ✅ หน้าเลือกโปรไฟล์ (เพิ่ม import ตรงนี้ไว้แล้ว)
import 'features/profile/profile_picker_screen.dart';

class AppRoutes {
  static const templates = '/templates';
  static const camera = '/camera';
  static const review = '/review';
  static const processing = '/processing';
  static const result = '/result';
  static const history = '/history';
  static const trends = '/trends';
  static const settings = '/settings';
  static const profilePicker = '/profile';
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // ✅ เริ่มต้นที่หน้าโปรไฟล์ (เพิ่มแค่เคสนี้)
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfilePickerScreen());

      case AppRoutes.templates:
        return MaterialPageRoute(builder: (_) => const TemplatePickerScreen());
      case AppRoutes.camera:
        return MaterialPageRoute(builder: (_) => const CameraOverlayScreen());
      case AppRoutes.review:
        return MaterialPageRoute(builder: (_) => const ReviewCropScreen());
      case AppRoutes.processing:
        return MaterialPageRoute(builder: (_) => const ProcessingScreen());
      case AppRoutes.result:
        return MaterialPageRoute(builder: (_) => const ResultSummaryScreen());
      case AppRoutes.history:
        return MaterialPageRoute(builder: (_) => const HistoryListScreen());
      case AppRoutes.trends:
        return MaterialPageRoute(builder: (_) => const TrendsScreen());

      default:
        // ถ้าไม่ตรง route ใด ๆ ให้กลับไปหน้าที่ใช้อยู่เดิมของคุณ
        return MaterialPageRoute(builder: (_) => const TemplatePickerScreen());
    }
  }
}
