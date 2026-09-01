import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});
  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  String? code;
  bool done = false;

  Future<void> captureCover() async {
    final x = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 80);
    if (x == null) return;
    final result = await ApiService.lookup(code!);
    if (!mounted) return;
    Navigator.push(context, MaterialPageRoute(
        builder: (_) => ReviewSaveScreen(code: code!, cover: File(x.path), info: result)));
  }

  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(title: const Text('Scan Barcode / ISBN')),
        body: code == null
            ? MobileScanner(
                onDetect: (v) {
                  if (done) return;
                  final raw = v.barcodes.isNotEmpty ? v.barcodes.first.rawValue : null;
                  if (raw != null) {
                    done = true;
                    setState(() => code = raw);
                    captureCover();
                  }
                },
              )
            : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.qr_code_2, size: 90),
                    const SizedBox(height: 20),
                    Text('Code scanned: $code', style: Theme.of(c).textTheme.titleLarge),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: captureCover,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('CAPTURE BOOK COVER'),
                    ),
                  ],
                ),
              ),
      );
}

class ReviewSaveScreen extends StatefulWidget {
  final String code;
  final File cover;
  final Map<String, dynamic> info;
  const ReviewSaveScreen(
      {super.key, required this.code, required this.cover, required this.info});
  @override
  State<ReviewSaveScreen> createState() => _ReviewSaveScreenState();
}

class _ReviewSaveScreenState extends State<ReviewSaveScreen> {
  late final Map<String, TextEditingController> c;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    c = {
      for (final k in ['title', 'author', 'grade', 'category', 'isbn', 'publisher', 'language'])
        k: TextEditingController(text: widget.info[k]?.toString() ?? '')
    };
  }

  Future<void> save() async {
    setState(() => saving = true);
    try {
      await ApiService.saveScan(
          code: widget.code,
          cover: widget.cover,
          fields: {for (final e in c.entries) e.key: e.value.text});
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Book recorded and Excel file updated.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext x) => Scaffold(
        appBar: AppBar(title: const Text('Book Information')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Image.file(widget.cover, height: 220, fit: BoxFit.cover),
            const SizedBox(height: 12),
            Text('Code: ${widget.code}'),
            if (widget.info['matched'] == true)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Chip(label: Text('Information found from code')),
              ),
            for (final k in c.keys)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: TextField(
                  controller: c[k],
                  decoration: InputDecoration(
                    labelText: k[0].toUpperCase() + k.substring(1),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: saving ? null : save,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(saving ? 'SAVING...' : 'SAVE BOOK TO SYSTEM & EXCEL'),
              ),
            ),
          ],
        ),
      );
}