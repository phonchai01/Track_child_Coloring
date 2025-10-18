import 'package:flutter/material.dart';
import '../../data/models/child_profile.dart';
import '../../data/repositories/child_repo.dart';
import 'dart:convert'; // ต้องใช้เวลาเขียนทับไฟล์

class ProfilePickerScreen extends StatefulWidget {
  const ProfilePickerScreen({super.key});
  @override
  State<ProfilePickerScreen> createState() => _ProfilePickerScreenState();
}

class _ProfilePickerScreenState extends State<ProfilePickerScreen> {
  late Future<List<ChildProfile>> _future;
  final _nameCtrl = TextEditingController();
  int _age = 4;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = ChildRepo.instance.list();
    setState(() {});
  }

  Future<void> _addProfile() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('กรอกชื่อก่อน')));
      return;
    }
    await ChildRepo.instance.add(ChildProfile(name: name, age: _age));
    _nameCtrl.clear();
    if (!mounted) return;
    Navigator.pop(context);
    _reload();
  }

  void _openAddDialog() {
    int ageTemp = 4; // ค่าเริ่มใน dialog (แยกจาก state หลัก)

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (_, setStateDialog) => AlertDialog(
          title: const Text('สร้างโปรไฟล์ใหม่'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'ชื่อเด็ก'),
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('อายุ: '),
                  const SizedBox(width: 8),
                  DropdownButton<int>(
                    value: ageTemp,
                    items: const [
                      DropdownMenuItem(value: 4, child: Text('4 ขวบ')),
                      DropdownMenuItem(value: 5, child: Text('5 ขวบ')),
                    ],
                    onChanged: (v) => setStateDialog(() {
                      ageTemp = v ?? 4; // ✅ เปลี่ยนแล้วเห็นทันทีใน dialog
                    }),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            FilledButton(
              onPressed: () async {
                final name = _nameCtrl.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('กรอกชื่อก่อน')),
                  );
                  return;
                }
                await ChildRepo.instance.add(ChildProfile(name: name, age: ageTemp));
                _nameCtrl.clear();
                if (!mounted) return;
                Navigator.pop(context); // ปิด dialog
                _reload();              // รีเฟรชรายการ
              },
              child: const Text('บันทึก'),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เลือกโปรไฟล์เด็ก'),
        actions: [
          IconButton(
              onPressed: _openAddDialog,
              icon: const Icon(Icons.person_add_alt)),
        ],
      ),
      body: FutureBuilder<List<ChildProfile>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snap.error}'));
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return Center(
              child: TextButton.icon(
                onPressed: _openAddDialog,
                icon: const Icon(Icons.person_add_alt),
                label: const Text('ยังไม่มีโปรไฟล์ — แตะเพื่อสร้าง'),
              ),
            );
          }

          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final p = items[i];
              return Dismissible(
                key: ValueKey(p.name),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (_) async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('ยืนยันการลบ'),
                      content: Text('ลบโปรไฟล์ “${p.name}” ใช่หรือไม่?'),
                      actions: [
                        TextButton(
                            onPressed: () =>
                                Navigator.pop(context, false),
                            child: const Text('ยกเลิก')),
                        FilledButton(
                            onPressed: () =>
                                Navigator.pop(context, true),
                            child: const Text('ลบ')),
                      ],
                    ),
                  );
                  return ok ?? false;
                },
                onDismissed: (_) async {
                  await ChildRepo.instance.deleteByName(p.name);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('ลบโปรไฟล์ ${p.name} แล้ว')),
                    );
                    _reload();
                  }
                },
                child: ListTile(
                  leading:
                      const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(p.name),
                  subtitle: Text('อายุ: ${p.age} ขวบ'),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/template',
                      arguments: {
                        'profileName': p.name,
                        'age': p.age,
                      },
                    );
                  },

                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('ยืนยันการลบ'),
                          content: Text('ลบโปรไฟล์ “${p.name}” ใช่หรือไม่?'),
                          actions: [
                            TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: const Text('ยกเลิก')),
                            FilledButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                child: const Text('ลบ')),
                          ],
                        ),
                      );
                      if (ok == true) {
                        await ChildRepo.instance.deleteByName(p.name);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('ลบโปรไฟล์ ${p.name} แล้ว')),
                          );
                          _reload();
                        }
                      }
                    },
                    tooltip: 'ลบโปรไฟล์นี้',
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
