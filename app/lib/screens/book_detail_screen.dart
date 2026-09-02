import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/book_scan.dart';
import 'scan_screen.dart';

class BookDetailScreen extends StatelessWidget {
  const BookDetailScreen({super.key, required this.scan});
  final BookScan scan;

  Color get _cover =>
      coverColor('${scan.category} ${scan.title}');

  @override
  Widget build(BuildContext c) {
    final title = scan.title.isNotEmpty ? scan.title : scan.code;
    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          AppHeaderBar(
            leading: AppBackButton(onPress: () => Navigator.pop(c)),
            title: 'Book Details',
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
                    color: kNavy,
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: const Color(0xFFF3F4F6)),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 4,
                                offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Column(
                          children: [
                            _row('Author',
                                scan.author.isNotEmpty ? scan.author : '—'),
                            _row('Publisher',
                                scan.publisher.isNotEmpty ? scan.publisher : '—'),
                            _row('Language',
                                scan.language.isNotEmpty ? scan.language : '—'),
                            _row('Quantity', '1 copy'),
                            _row('Condition', 'Good'),
                            _lastRow('Date Added', _date()),
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
                              child: const Text('Scan Again',
                                  style: TextStyle(
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
                              child: const Text('Edit',
                                  style: TextStyle(
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

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(color: kTextGray, fontSize: 12)),
            Text(value,
                style: const TextStyle(
                    color: kNavy,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      );

  Widget _lastRow(String label, String value) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(color: kTextGray, fontSize: 12)),
            Text(value,
                style: const TextStyle(
                    color: kNavy,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      );
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
