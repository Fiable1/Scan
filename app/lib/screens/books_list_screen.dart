import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../services/api_service.dart';
import '../services/app_settings.dart';
import '../models/book_scan.dart';
import 'scan_screen.dart';
import 'book_detail_screen.dart';

class BooksListScreen extends StatefulWidget {
  const BooksListScreen({super.key});
  @override
  State<BooksListScreen> createState() => _BooksListScreenState();
}

class _BooksListScreenState extends State<BooksListScreen> {
  List<BookScan> scans = [];
  bool loading = true;
  final _q = TextEditingController();
  String query = '';

  String _t(String en, {String? rw, String? fr}) {
    final loc = context.read<AppSettings>().locale;
    if (loc == 'rw' && rw != null) return rw;
    if (loc == 'fr' && fr != null) return fr;
    return en;
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => loading = true);
    try {
      scans = await ApiService.scans(q: query);
    } catch (_) {
      scans = [];
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext c) {
    final isDark = Theme.of(c).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? kDarkScaffold : kBg,
      body: Column(
        children: [
          Container(
            color: isDark ? kDarkCard : kNavy,
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(_t('Books Library', rw: 'Ububiko bw\'ibitabo', fr: 'Bibliothèque de livres'),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(c, MaterialPageRoute(
                          builder: (_) => const ScanScreen())),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: kAccent,
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(_t('+ Scan', rw: '+ Soma', fr: '+ Scanner'),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _q,
                  onChanged: (v) {
                    query = v;
                    load();
                  },
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: _t('Search books...', rw: 'Shakisha ibitabo...', fr: 'Rechercher des livres...'),
                    hintStyle: const TextStyle(color: Color(0xFF93C5FD)),
                    suffixIcon: const Padding(
                        padding: EdgeInsets.all(12),
                        child:
                            Icon(Icons.search, color: Color(0xFF93C5FD))),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: load,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Text(
                            '${scans.length} ${_t('books found', rw: 'ibitabo bibonetse', fr: 'livres trouvés')}',
                            style: const TextStyle(
                                color: kTextGray,
                                fontSize: 12,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 10),
                        if (scans.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 60),
                            child: Center(
                                child: Text(_t('No books yet. Scan your first book!', rw: 'Nta bitabo bihari. Soma igitabo cyawe cya mbere!', fr: 'Pas encore de livres. Scannez votre premier livre!'),
                                    style: TextStyle(
                                        color: isDark ? kDarkTextMuted : kTextGray))),
                          ),
                        ...scans.map((s) => _BookTile(scan: s)),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _BookTile extends StatelessWidget {
  final BookScan scan;
  const _BookTile({required this.scan});
  @override
  Widget build(BuildContext c) {
    final isDark = Theme.of(c).brightness == Brightness.dark;
    final title = scan.title.isNotEmpty ? scan.title : scan.code;
    final color = coverColor('${scan.category} $title');
    return GestureDetector(
      onTap: () => Navigator.push(c, MaterialPageRoute(
          builder: (_) => BookDetailScreen(scan: scan))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? kDarkCard : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? kDarkBorder : const Color(0xFFF3F4F6)),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2)),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 48,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(9)),
              child: Center(
                  child: CustomPaint(
                      size: const Size(16, 16),
                      painter: _BookFill(color: Colors.white))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: isDark ? kDarkText : kNavy,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          height: 1.3)),
                  const SizedBox(height: 4),
                  Text('ISBN: ${scan.isbn.isNotEmpty ? scan.isbn : scan.code}',
                      style: const TextStyle(color: kTextGray, fontSize: 11)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (scan.category.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                              color: const Color(0xFFDBEAFE),
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(scan.category,
                              style: const TextStyle(
                                  color: kAccent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500)),
                        ),
                      if (scan.category.isNotEmpty &&
                          scan.grade.isNotEmpty)
                        const SizedBox(width: 5),
                      if (scan.grade.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF374151)
                                  : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(scan.grade,
                              style: TextStyle(
                                  color: isDark
                                      ? kDarkTextMuted
                                      : const Color(0xFF6B7280),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: kTextGray, size: 18),
          ],
        ),
      ),
    );
  }
}

class _BookFill extends CustomPainter {
  final Color color;
  _BookFill({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final p = Paint()..color = color;
    final lp = Path()
      ..moveTo(w * 0.1, h * 0.15)
      ..lineTo(w * 0.45, h * 0.15)
      ..cubicTo(w * 0.5, h * 0.15, w * 0.48, h * 0.2, w * 0.48, h * 0.3)
      ..lineTo(w * 0.48, h * 0.85)
      ..lineTo(w * 0.1, h * 0.85)
      ..close();
    canvas.drawPath(lp, p);
    final p2 = Paint()..color = color.withOpacity(0.6);
    final rp = Path()
      ..moveTo(w * 0.9, h * 0.15)
      ..lineTo(w * 0.55, h * 0.15)
      ..cubicTo(w * 0.5, h * 0.15, w * 0.52, h * 0.2, w * 0.52, h * 0.3)
      ..lineTo(w * 0.52, h * 0.85)
      ..lineTo(w * 0.9, h * 0.85)
      ..close();
    canvas.drawPath(rp, p2);
  }

  @override
  bool shouldRepaint(covariant _BookFill old) => old.color != color;
}
