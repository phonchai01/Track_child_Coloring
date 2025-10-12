import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart' show rootBundle;

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

    final args = (ModalRoute.of(context)?.settings.arguments ?? {}) as Map?;
    final bytes = args?['imageBytes'] as Uint8List?;
    templateKey = (args?['templateKey'] as String?) ?? 'template';

    if (bytes != null) {
      _setImage(bytes);
    }
  }

  // ---------- helpers ----------

  Future<void> _pickHere({bool fromCamera = false}) async {
    final picker = ImagePicker();
    final picked = await (fromCamera
        ? picker.pickImage(source: ImageSource.camera, imageQuality: 95)
        : picker.pickImage(source: ImageSource.gallery, imageQuality: 95));
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    _setImage(bytes);
  }

  void _setImage(Uint8List bytes) {
    setState(() {
      original = bytes;
      enhanced = null;
      _processing = true;
    });

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

  Future<Uint8List> _loadMaskForTemplate(String key) async {
    // ขาว = ในเส้น, ดำ = นอกเส้น
    String path;
    switch (key) {
      case 'fish':
        path = 'assets/masks/fish_template.png';
        break;
      case 'pencil':
        path = 'assets/masks/pencil_template.png';
        break;
      case 'icecream':
        path = 'assets/masks/icecream_template.png';
        break;
      default:
        path = 'assets/masks/fish_template.png';
    }
    final data = await rootBundle.load(path);
    return data.buffer.asUint8List();
  }

  // wrapper สำหรับปุ่มยืนยัน (ต้องคืนค่า void ใน onPressed)
  Future<void> _onConfirm() async {
    final bytesToUse = enhanced ?? original;
    if (bytesToUse == null) return;

    final maskBytes = await _loadMaskForTemplate(templateKey);
    if (!mounted) return;

    Navigator.pushNamed(
      context,
      AppRoutes.processing,
      arguments: {
        'imageBytes': bytesToUse,
        'maskBytes': maskBytes,
        'templateKey': templateKey,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final canConfirm = (enhanced ?? original) != null && !_processing;

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
                if (!canConfirm) return;   // กันกดตอนยังไม่พร้อม
                _onConfirm();
              },
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'เลือกรูป',
                    primary: false,
                    onPressed: () => _pickHere(fromCamera: false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    text: 'ถ่ายรูป',
                    primary: false,
                    onPressed: () => _pickHere(fromCamera: true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
