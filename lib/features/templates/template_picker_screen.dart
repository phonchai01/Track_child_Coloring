import 'package:flutter/material.dart';
import '../../routes.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/app_button.dart';

class TemplatePickerScreen extends StatelessWidget {
  const TemplatePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('ปลา', 'fish'),
      ('ดินสอ', 'pencil'),
      ('ไอศกรีม', 'ice_cream'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('เลือกเทมเพลต')),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: items.map((e) {
                  return Card(
                    elevation: 2,
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.camera, arguments: e.$2);
                      },
                      child: Center(child: Text(e.$1, style: const TextStyle(fontSize: 18))),
                    ),
                  );
                }).toList(),
              ),
            ),
            AppButton(
              text: 'ไปหน้าประวัติ',
              primary: false,
              onPressed: () => Navigator.pushNamed(context, AppRoutes.history),
            ),
          ],
        ),
      ),
    );
  }
}
