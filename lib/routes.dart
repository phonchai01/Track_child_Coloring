import 'package:flutter/material.dart';

import 'features/templates/template_picker_screen.dart';
import 'features/camera/camera_overlay_screen.dart';
import 'features/camera/review_crop_screen.dart';
import 'features/processing/processing_screen.dart';
import 'features/result/result_summary_screen.dart';
import 'features/history/history_list_screen.dart';
import 'features/trends/trends_screen.dart';

class AppRoutes {
  static const templates = '/templates';
  static const camera = '/camera';
  static const review = '/review';
  static const processing = '/processing';
  static const result = '/result';
  static const history = '/history';
  static const trends = '/trends';
  static const settings = '/settings';
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
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
        return MaterialPageRoute(builder: (_) => const TemplatePickerScreen());
    }
  }
}
