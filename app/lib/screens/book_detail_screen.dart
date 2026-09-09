import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../models/book_scan.dart';
import '../services/app_settings.dart';
import 'scan_screen.dart';

class BookDetailScreen extends StatelessWidget {
  const BookDetailScreen({super.key, required this.scan});
  final BookScan scan;

  Color get _cover =>
      coverColor('${scan.category} ${scan.title}');

  String _t(BuildContext c, String en, {String? rw, String? fr}) {
    final loc = c.read<AppSettings>().locale;
    if (loc == 'rw' && rw != null) return rw;
    if (loc == 'fr' && fr != null) return fr;
    return en;
  }

  @override
  Widget build(BuildContext c) {
    final isDark = Theme.of(c).brightness == Brightness.dark;
    final title = scan.title.isNotEmpty ? scan.title : scan.code;
    final cardColor = isDark ? kDarkCard : Colors.white;
    final border = isDark ? kDarkBorder : const Color(0xFFF3F4F6);
    return Scaffold(
      backgroundColor: isDark ? kDarkScaffold : kBg,
      body: Column(
        children: [
          AppHeaderBar(
            leading: AppBackButton(onPress: () => Navigator.pop(c)),
            title: _t(c, 'Book Details', rw: 'Ibirebana n\'igitabo', fr: 'Détails du livre'),
            trailing: Container(
              width: 32,
              height: 32,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                    3,
                    (i) => Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle))),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hero
                  Container(
                    color: isDark ? kDarkCard : kNavy,
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CoverMock(color: _cover, title: title),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      height: 1.3)),
                              const SizedBox(height: 4),
                              Text(
                                  'ISBN: ${scan.isbn.isNotEmpty ? scan.isbn : scan.code}',
                                  style: const TextStyle(
                                      color: Color(0xFF93C5FD), fontSize: 12)),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  if (scan.category.isNotEmpty)
                                    _HeroTag(scan.category),
                                  if (scan.grade.isNotEmpty)
                                    _HeroTag(scan.grade),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Detail card
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Transform.translate(
                      offset: const Offset(0, -18),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: border),
                          boxShadow: isDark
                              ? null
                              : [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2)),
                                ],
                        ),
                        child: Column(
                          children: [
                            _row(c,
                                _t(c, 'Author', rw: 'Umwanditsi', fr: 'Auteur'),
                                scan.author.isNotEmpty ? scan.author : '—'),
                            _row(c,
                                _t(c, 'Publisher', rw: 'Umutangazasanduku', fr: 'Éditeur'),
                                scan.publisher.isNotEmpty ? scan.publisher : '—'),
                            _row(c,
                                _t(c, 'Language', rw: 'Ururimi', fr: 'Langue'),
                                scan.language.isNotEmpty ? scan.language : '—'),
                            _row(c,
                                _t(c, 'Quantity', rw: 'Umubare', fr: 'Quantité'),
                                '1 ${_t(c, 'copy', rw: 'igito', fr: 'copie')}'),
                            _row(c,
                                _t(c, 'Condition', rw: 'Uko bimeze', fr: 'Condition'),
                                _t(c, 'Good', rw: 'Nibyiza', fr: 'Bon')),
                            _lastRow(c, _t(c, 'Date Added', rw: 'Igihe byongeweho', fr: 'Date ajoutée'), _date()),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 46,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pushReplacement(
                                  c,
                                  MaterialPageRoute(
                                      builder: (_) => const ScanScreen())),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kNavy,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(_t(c, 'Scan Again', rw: 'Soma nanone', fr: 'Scanner à nouveau'),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 46,
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                foregroundColor: kNavy,
                                side: const BorderSide(color: kBorderGray),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(_t(c, 'Edit', rw: 'Hindura', fr: 'Modifier'),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _date() {
    final d = scan.scannedAt;
    if (d == null) return '—';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  Widget _row(BuildContext c, String label, String value) {
    final isDark = Theme.of(c).brightness == Brightness.dark;
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(color: kTextGray, fontSize: 12)),
            Text(value,
                style: TextStyle(
                    color: isDark ? kDarkText : kNavy,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      );
  }

  Widget _lastRow(BuildContext c, String label, String value) {
    final isDark = Theme.of(c).brightness == Brightness.dark;
    return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(color: kTextGray, fontSize: 12)),
            Text(value,
                style: TextStyle(
                    color: isDark ? kDarkText : kNavy,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      );
  }
}

class _HeroTag extends StatelessWidget {
  final String text;
  const _HeroTag(this.text);
  @override
  Widget build(BuildContext c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20)),
        child: Text(text,
            style: const TextStyle(
                color: Color(0xFFBFDBFE),
                fontSize: 10,
                fontWeight: FontWeight.w500)),
      );
}

class _CoverMock extends StatelessWidget {
  final Color color;
  final String title;
  const _CoverMock({required this.color, required this.title});
  @override
  Widget build(BuildContext c) => Container(
        width: 96,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)
          ],
        ),
        child: AspectRatio(
          aspectRatio: 2 / 3,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.split(' ').take(2).join(' ').toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Color(0xFF93C5FD),
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5),
                ),
                const Spacer(),
                Center(
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                        color: Color(0xFFFDE68A), shape: BoxShape.circle),
                    child: const Center(
                      child: Text('6',
                          style: TextStyle(
                              color: Color(0xFF1a3a6b),
                              fontSize: 18,
                              fontWeight: FontWeight.w900)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}