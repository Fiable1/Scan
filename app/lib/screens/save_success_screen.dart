import 'package:flutter/material.dart';
import '../theme.dart';
import 'scan_screen.dart';
import 'home_shell.dart';

class SaveSuccessScreen extends StatelessWidget {
  const SaveSuccessScreen({super.key, required this.info});
  final Map<String, String> info;

  @override
  Widget build(BuildContext c) {
    final title = info['title']?.isNotEmpty == true
        ? info['title']!
        : 'Your book';
    final isbn = info['isbn'] ?? '';
    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          AppHeaderBar(
            leading: const SizedBox(width: 32),
            title: 'Save Successful',
            center: true,
            trailing: const SizedBox(width: 32),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                        color: Color(0xFFDCFCE7), shape: BoxShape.circle),
                    child: const Center(
                      child: Icon(Icons.check_circle,
                          color: kGreen, size: 46),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Book Saved!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: kNavy,
                          fontSize: 24,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  Text(
                    '$title\nhas been added to your library.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: kTextGray, fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 6),
                  Text('ISBN: $isbn',
                      style: const TextStyle(
                          color: kAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 40),
                  Column(
                    children: [
                      PrimaryButton(
                        label: 'SCAN ANOTHER BOOK',
                        onPressed: () => Navigator.pushAndRemoveUntil(c,
                            MaterialPageRoute(
                                builder: (_) => const ScanScreen()),
                            (r) => false),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pushAndRemoveUntil(c,
                              MaterialPageRoute(
                                  builder: (_) => const HomeShell()),
                              (r) => false),
                          style: OutlinedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: kBorderGray),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Go to Dashboard',
                              style: TextStyle(
                                  color: kNavy,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
