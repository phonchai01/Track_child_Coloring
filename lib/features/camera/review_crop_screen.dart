import 'package:flutter/material.dart';
import '../../routes.dart';
import '../../widgets/app_button.dart';

class ReviewCropScreen extends StatelessWidget {
  const ReviewCropScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final templateKey = ModalRoute.of(context)!.settings.arguments as String? ?? 'template';

    return Scaffold(
      appBar: AppBar(title: const Text('ตรวจภาพ & ปรับครอป')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: Colors.black12,
                child: const Center(child: Text('Preview (mock)')),
              ),
            ),
            const SizedBox(height: 12),
            AppButton(
              text: 'ยืนยัน',
              onPressed: () => Navigator.pushNamed(context, AppRoutes.processing, arguments: templateKey),
            ),
            const SizedBox(height: 8),
            AppButton(
              text: 'ถ่ายใหม่',
              primary: false,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
