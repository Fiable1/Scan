import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../services/app_settings.dart';
import 'scan_screen.dart';
import 'home_shell.dart';

class SaveSuccessScreen extends StatelessWidget {
  const SaveSuccessScreen({super.key, required this.info});
  final Map<String, String> info;

  String _t(BuildContext c, String en, {String? rw, String? fr}) {
    final loc = c.read<AppSettings>().locale;
    if (loc == 'rw' && rw != null) return rw;
    if (loc == 'fr' && fr != null) return fr;
    return en;
  }

  @override
  Widget build(BuildContext c) {
    final isDark = Theme.of(c).brightness == Brightness.dark;
    final titleColor = isDark ? kDarkText : kNavy;
    final border = isDark ? kDarkBorder : kBorderGray;
    final title = info['title']?.isNotEmpty == true
        ? info['title']!
        : _t(c, 'Your book', rw: 'Igitabo cyawe', fr: 'Votre livre');
    final isbn = info['isbn'] ?? '';
    return Scaffold(
      backgroundColor: isDark ? kDarkScaffold : kBg,
      body: Column(
        children: [
          AppHeaderBar(
            leading: const SizedBox(width: 32),
            title: _t(c, 'Save Successful', rw: 'Byabikijwe neza', fr: 'Enregistrement réussi'),
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
                  Text(_t(c, 'Book Saved!', rw: 'Igitabo cyabikitwe!', fr: 'Livre enregistré!'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: titleColor,
                          fontSize: 24,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  Text(
                    '$title\n${_t(c, 'has been added to your library.', rw: 'cyongewe mu bugumbugumbu bwawe.', fr: 'a été ajouté à votre bibliothèque.')}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: isDark ? kDarkTextMuted : kTextGray, fontSize: 14, height: 1.4),
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
                        label: _t(c, 'SCAN ANOTHER BOOK', rw: 'SOMA IKINDI GITABO', fr: 'SCANNER UN AUTRE LIVRE'),
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
                            side: BorderSide(color: border),
                          ),
                          child: Text(_t(c, 'Go to Dashboard', rw: 'Jya ku kibaho', fr: 'Aller au tableau de bord'),
                              style: TextStyle(
                                  color: titleColor,
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