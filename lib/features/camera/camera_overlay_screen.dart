import 'package:flutter/material.dart';
import '../../routes.dart';
import '../../widgets/template_overlay.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/app_button.dart';

class CameraOverlayScreen extends StatelessWidget {
  const CameraOverlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final templateKey = ModalRoute.of(context)!.settings.arguments as String? ?? 'template';

    return Scaffold(
      appBar: AppBar(title: const Text('โหมดถ่ายภาพ')),
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          // ตรงนี้ภายหลังจะเป็นพรีวิวกล้อง
          const Center(child: Icon(Icons.photo_camera, size: 120, color: Colors.black26)),
          TemplateOverlay(templateName: templateKey),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'ถ่าย (จำลอง)',
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.review, arguments: templateKey),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
