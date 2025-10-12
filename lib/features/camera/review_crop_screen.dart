import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../routes.dart';
import '../../widgets/app_button.dart';
import '../../services/image/preprocess_photo.dart';

class ReviewCropScreen extends StatefulWidget {
  const ReviewCropScreen({super.key});

  @override
  State<ReviewCropScreen> createState() => _ReviewCropScreenState();
}

class _ReviewCropScreenState extends State<ReviewCropScreen> {
  Uint8List? original;
  Uint8List? enhanced;
  String templateKey = 'template';
  bool _didInit = false;
  bool _processing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInit) return;
    _didInit = true;

    // อ่าน arguments หลังจาก context พร้อมแล้ว
    final args = (ModalRoute.of(context)?.settings.arguments ?? {}) as Map?;
    final bytes = args?['imageBytes'] as Uint8List?;
    templateKey = (args?['templateKey'] as String?) ?? 'template';

    original = bytes;

    if (bytes != null) {
      _processing = true;
      // ทำ preprocess แบบ async แล้ว setState ทีหลัง
      Future.microtask(() {
        final out = PreprocessPhoto.enhancePaperKeepColor(
          bytes,
          targetWhite: 245,
          gamma: 1.0,
        );
        if (!mounted) return;
        setState(() {
          enhanced = Uint8List.fromList(out);
          _processing = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ตรวจภาพ & ปรับครอป')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.black12,
                      child: original == null
                          ? const Center(child: Text('ไม่มีภาพ'))
                          : Image.memory(original!, fit: BoxFit.contain),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      color: Colors.black12,
                      child: _processing
                          ? const Center(child: CircularProgressIndicator())
                          : (enhanced == null
                              ? const Center(child: Text('ไม่พบภาพที่ปรับแล้ว'))
                              : Image.memory(enhanced!, fit: BoxFit.contain)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AppButton(
              text: 'ยืนยัน (ใช้ภาพที่ปรับแล้ว)',
              onPressed: () {
                final bytesToUse = enhanced ?? original;
                if (bytesToUse == null) return;
                Navigator.pushNamed(
                  context,
                  AppRoutes.processing,
                  arguments: {
                    'imageBytes': bytesToUse,
                    'templateKey': templateKey,
                    // 'maskBytes': ...
                  },
                );
              },
            ),
            const SizedBox(height: 8),
            AppButton(
              text: 'ถ่าย/เลือกใหม่',
              primary: false,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
