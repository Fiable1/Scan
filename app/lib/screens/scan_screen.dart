import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../platform/platform_helpers.dart';
import '../services/api_service.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});
  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  String? code;

  Future<void> lookupAndProceed(String scannedCode) async {
    setState(() => code = scannedCode);
    try {
      final result = await ApiService.lookup(scannedCode);
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(
          builder: (_) => ReviewSaveScreen(code: scannedCode, info: result)));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Lookup failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(title: const Text('Scan Barcode / ISBN')),
        body: code == null
            ? _BarcodeInputPage(onDetected: lookupAndProceed)
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
                      onPressed: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => ReviewSaveScreen(code: code!, info: const {}))),
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('CONTINUE'),
                    ),
                  ],
                ),
              ),
      );
}

class _BarcodeInputPage extends StatefulWidget {
  final Function(String) onDetected;
  const _BarcodeInputPage({required this.onDetected});
  @override
  State<_BarcodeInputPage> createState() => _BarcodeInputPageState();
}

class _BarcodeInputPageState extends State<_BarcodeInputPage> {
  final manualController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.qr_code_scanner, size: 80, color: Color(0xFF0D47A1)),
          const SizedBox(height: 20),
          Text(
            kIsWeb ? 'Enter barcode / ISBN manually' : 'Scan or enter barcode / ISBN',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: manualController,
            decoration: const InputDecoration(
                labelText: 'Barcode / ISBN', border: OutlineInputBorder()),
            onSubmitted: (v) {
              if (v.trim().isNotEmpty) widget.onDetected(v.trim());
            },
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              if (manualController.text.trim().isNotEmpty) {
                widget.onDetected(manualController.text.trim());
              }
            },
            child: const Padding(
                padding: EdgeInsets.all(14), child: Text('LOOKUP BOOK')),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    manualController.dispose();
    super.dispose();
  }
}

class ReviewSaveScreen extends StatefulWidget {
  final String code;
  final Map<String, dynamic> info;
  const ReviewSaveScreen({super.key, required this.code, required this.info});
  @override
  State<ReviewSaveScreen> createState() => _ReviewSaveScreenState();
}

class _ReviewSaveScreenState extends State<ReviewSaveScreen> {
  late final Map<String, TextEditingController> c;
  bool saving = false;
  Uint8List? coverBytes;
  String? coverName;

  @override
  void initState() {
    super.initState();
    c = {
      for (final k in ['title', 'author', 'grade', 'category', 'isbn', 'publisher', 'language'])
        k: TextEditingController(text: widget.info[k]?.toString() ?? '')
    };
  }

  Future<void> pickCover() async {
    final result = await pickImageFile();
    if (result != null) {
      setState(() {
        coverBytes = Uint8List.fromList(result.$1);
        coverName = result.$2;
      });
    }
  }

  Future<void> save() async {
    if (coverBytes == null) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Please select a cover image')));
      }
      return;
    }
    setState(() => saving = true);
    try {
      await ApiService.saveScan(
          code: widget.code,
          coverBytes: coverBytes!.toList(),
          coverName: coverName ?? 'cover.jpg',
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
            if (coverBytes != null)
              Image.memory(coverBytes!, height: 220, fit: BoxFit.cover)
            else
              Container(
                height: 220,
                color: Colors.grey[200],
                child: const Center(
                    child: Text('No cover image selected',
                        style: TextStyle(color: Colors.grey))),
              ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: pickCover,
              child: const Text('SELECT COVER IMAGE'),
            ),
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
