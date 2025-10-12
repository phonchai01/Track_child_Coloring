import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../routes.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/app_button.dart';
import '../../widgets/template_overlay.dart';

class CameraOverlayScreen extends StatelessWidget {
  const CameraOverlayScreen({super.key});

  Future<void> _pickImage(BuildContext context, {bool fromCamera = false}) async {
    final picker = ImagePicker();
    final picked = await (fromCamera
        ? picker.pickImage(source: ImageSource.camera, imageQuality: 95)
        : picker.pickImage(source: ImageSource.gallery, imageQuality: 95));
    if (picked == null) return;

    final bytes = await picked.readAsBytes(); // Uint8List
    final templateArg = ModalRoute.of(context)!.settings.arguments as String? ?? 'template';

    // ส่งไปหน้ารีวิวเพื่อทำ pre-process (ทำกระดาษให้ขาวขึ้นแต่คงสี)
    Navigator.pushNamed(context, AppRoutes.review, arguments: {
      'imageBytes': bytes,
      'templateKey': templateArg,
    });
  }

  @override
  Widget build(BuildContext context) {
    final templateKey = ModalRoute.of(context)!.settings.arguments as String? ?? 'template';

    return Scaffold(
      appBar: AppBar(title: const Text('โหมดถ่ายภาพ')),
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          // พื้นหลังชั่วคราว (ภายหลังจะเป็นพรีวิวกล้อง)
          const Center(child: Icon(Icons.photo_camera, size: 120, color: Colors.black26)),
          TemplateOverlay(templateName: templateKey),

          // ปุ่มแอ็กชัน
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'เลือกรูป',
                    primary: false,
                    onPressed: () => _pickImage(context, fromCamera: false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    text: 'ถ่ายรูป',
                    onPressed: () => _pickImage(context, fromCamera: true),
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
