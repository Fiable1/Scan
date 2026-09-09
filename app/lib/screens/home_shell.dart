import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';
import '../services/api_service.dart';
import '../services/app_settings.dart';
import 'books_list_screen.dart';
import 'scan_screen.dart';
import 'analytics_screen.dart';
import 'export_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  String view = 'dashboard';
  String? fullName;
  String? schoolName;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final p = await SharedPreferences.getInstance();
    final fn = p.getString('librarian_name');
    final sn = p.getString('librarian_school');
    final district = p.getString('librarian_district');
    if (mounted) {
      setState(() {
        fullName = fn;
        schoolName = sn;
        group = district ?? '';
      });
    }
  }

  String group = '';

  @override
  Widget build(BuildContext c) {
    final body = switch (view) {
      'dashboard' => Dashboard(
          key: ValueKey('dashboard'),
          fullName: fullName,
          school: schoolName,
          group: group,
        ),
      'books' => const BooksListScreen(key: ValueKey('books')),
      'scan' => const ScanScreen(key: ValueKey('scan')),
      'analytics' => const AnalyticsScreen(key: ValueKey('analytics')),
      'export' => const ExportScreen(key: ValueKey('export')),
      _ => const SizedBox(),
    };
    final isDark = Theme.of(c).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? kDarkScaffold : kBg,
      body: Stack(
        children: [
          body,
          BottomNavBar(
            active: view,
            onNavigate: (v) => setState(() => view = v),
          ),
        ],
      ),
    );
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard(
      {super.key, this.fullName, this.school, this.group});
  final String? fullName;
  final String? school;
  final String? group;
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Map<String, dynamic>? data;
  List<dynamic> recent = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      data = await ApiService.analytics();
      if (data != null) {
        final lst = (data!['recent_scans'] as List?) ?? [];
        recent = lst;
      }
    } catch (_) {}
    if (mounted) setState(() {});
  }

  String _name() {
    final n = widget.fullName?.trim() ?? '';
    return n.isEmpty ? 'Librarian' : n;
  }

  String _initials() {
    final n = _name();
    final parts = n.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return 'LB';
    final s = parts[0][0] + (parts.length > 1 ? parts.last[0] : '');
    return s.toUpperCase();
  }

  String _t(String en, {String? rw, String? fr}) {
    final loc = context.read<AppSettings>().locale;
    if (loc == 'rw' && rw != null) return rw;
    if (loc == 'fr' && fr != null) return fr;
    return en;
  }

  @override
  Widget build(BuildContext c) {
    final isDark = Theme.of(c).brightness == Brightness.dark;
    final total = data?['total_books']?.toString() ?? '1,248';
    final today = data?['today']?.toString() ?? '56';
    final school = widget.school ?? 'MUNEZERO Flaibe';
    final titleColor = isDark ? kDarkText : kNavy;
    return Column(
      children: [
        // Header
        Stack(
          children: [
            Container(
              color: isDark ? kDarkCard : kNavy,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(
                children: [
                  Row(
                    children: [
                      const _Hamburger(),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(_t('Dashboard', rw: 'Ikibaho gikuru', fr: 'Tableau de bord'),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18)),
                      ),
                      Stack(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle),
                            child: const Center(
                                child: Icon(Icons.notifications_none,
                                    color: Colors.white, size: 20)),
                          ),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444),
                                shape: BoxShape.circle,
                                border: Border.all(color: kNavy, width: 1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_t('Good morning,', rw: 'Mwaramutse,', fr: 'Bonjour,'),
                                style: const TextStyle(
                                    color: Color(0xFF93C5FD), fontSize: 12)),
                            Text(school,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15)),
                            Text(
                              '${_t('Librarian', rw: 'Umuyobozi w\'ububiko', fr: 'Bibliothécaire')}${(widget.group?.isNotEmpty ?? false) ? ': ${widget.group?.toUpperCase() ?? ''}' : ''}',
                              style: const TextStyle(
                                  color: Color(0xFF93C5FD), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                            color: kAccent, shape: BoxShape.circle),
                        child: Center(
                          child: Text(_initials(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        // Body
        Expanded(
          child: RefreshIndicator(
            onRefresh: load,
            child: ListView(
              padding: const EdgeInsets.only(
                  left: 16, right: 16, top: 4, bottom: 96),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _StatCard.navy(
                          _t('Total Books Scanned', rw: 'Ibitabo byose byasomwe', fr: 'Total de livres scannés'), total, '+12%', _t('this month', rw: 'ukwezi gushize', fr: 'ce mois')),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard.blue(
                          _t('Today\'s Books', rw: 'Ibitabo bya Uyu Munsi', fr: 'Livres du jour'), today, '+8', _t('from yesterday', rw: 'uwa ejo', fr: 'depuis hier')),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard.white(
                          _t('Total Apps', rw: 'Porogaramu zose', fr: 'Total d\'applications'), '1,248'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard.white(_t('Data in System', rw: 'Amakuru mu sisitemu', fr: 'Données dans le système'), '1,248'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_t('Recent Scans', rw: 'Ibyasomwe biheruka', fr: 'Analyses récentes'),
                        style: TextStyle(
                            color: titleColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    TextButton(
                      onPressed: () => setState(() {
                        _go(c, const BooksListScreen());
                      }),
                      child: Text(_t('View all', rw: 'Reba byose', fr: 'Voir tout'),
                          style: const TextStyle(
                              color: kAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                ..._recentList(c),
                const SizedBox(height: 16),
                Text(_t('Quick Actions', rw: 'Ibikorwa byihuse', fr: 'Actions rapides'),
                    style: TextStyle(
                        color: titleColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _QuickAction(
                            '📷', _t('Scan Book', rw: 'Soma igitabo', fr: 'Scanner un livre'),
                            () => _go(c, const ScanScreen()))),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _QuickAction('📚', _t('View Books', rw: 'Reba ibitabo', fr: 'Voir les livres'),
                            () => _go(c, const BooksListScreen()))),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _QuickAction('📄', _t('Export', rw: 'Ohereza hanze', fr: 'Exporter'),
                            () => _go(c, const ExportScreen()))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _recentList(BuildContext c) {
    final isDark = Theme.of(c).brightness == Brightness.dark;
    if (recent.isEmpty) {
      final fallback = [
        {'title': 'New Oxford Primary Mathematics 6', 'isbn': '9780199386429', 'grade': 'Primary 6 • Mathematics', 'color': '#1a3a6b'},
        {'title': 'Longman English Workbook 6', 'isbn': '9780582312104', 'grade': 'Primary 6 • English', 'color': '#1e5c3a'},
        {'title': 'Integrated Science Learner Book 6', 'isbn': '9780435892258', 'grade': 'Primary 6 • Science', 'color': '#7b1f1f'},
      ];
      return fallback
          .map((b) => _RecentTile(
              title: b['title']!,
              isbn: 'ISBN: ${b['isbn']}',
              grade: b['grade']!,
              color: Color(int.parse('FF${b['color']!.substring(1)}',
                  radix: 16)),
              isDark: isDark))
          .toList();
    }
    return recent
        .take(3)
        .map((b) => _RecentTile(
              title: b['title']?.toString().isNotEmpty == true
                  ? b['title'].toString()
                  : b['code'].toString(),
              isbn: 'ISBN: ${b['isbn'] ?? b['code']}',
              grade:
                  '${b['grade'] ?? ''} • ${b['category'] ?? ''}'.trim(),
              color: coverColor(b['title']?.toString() ?? ''),
              isDark: isDark,
            ))
        .toList();
  }

  void _go(BuildContext c, Widget page) {
    Navigator.push(c, MaterialPageRoute(builder: (_) => page));
  }
}

/// Stores librarian profile info from login/register responses.
Future<void> persistLibrarian(Map<String, dynamic> data) async {
  final p = await SharedPreferences.getInstance();
  if (data['librarian'] != null)
    p.setString('librarian_name', data['librarian'].toString());
  if (data['school'] != null)
    p.setString('librarian_school', data['school'].toString());
  if (data['district'] != null)
    p.setString('librarian_district', data['district'].toString());
}

class _Hamburger extends StatelessWidget {
  const _Hamburger();
  @override
  Widget build(BuildContext c) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _line(),
          const SizedBox(height: 5),
          _line(),
          const SizedBox(height: 5),
          _line(),
        ],
      );
  Widget _line() => Container(width: 22, height: 3,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(2)));
}

class _StatCard extends StatelessWidget {
  final String label, value, sub1, sub2;
  final bool dark, blueCard, whiteCard;
  const _StatCard.navy(this.label, this.value, this.sub1, this.sub2)
      : dark = true,
        blueCard = false,
        whiteCard = false;
  const _StatCard.blue(this.label, this.value, this.sub1, this.sub2)
      : dark = false,
        blueCard = true,
        whiteCard = false;
  const _StatCard.white(this.label, this.value)
      : dark = false,
        blueCard = false,
        whiteCard = true,
        sub1 = '',
        sub2 = '';

  @override
  Widget build(BuildContext c) {
    final isDark = Theme.of(c).brightness == Brightness.dark;
    final isDarkCard = dark || blueCard;
    final bg = blueCard ? kAccent : (dark ? kNavy : (isDark ? kDarkCard : Colors.white));
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: whiteCard && !isDark
            ? [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2)),
              ]
            : null,
        border: (whiteCard && isDark)
            ? Border.all(color: kDarkBorder)
            : whiteCard
                ? Border.all(color: const Color(0xFFF3F4F6))
                : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.6,
                  color: isDarkCard
                      ? (blueCard
                          ? const Color(0xFFDBEAFE)
                          : const Color(0xFF93C5FD))
                      : kTextGray)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: isDarkCard ? Colors.white : (isDark ? kDarkText : kNavy))),
          if (!whiteCard)
            Row(
              children: [
                Text(sub1,
                    style: const TextStyle(
                        color: Color(0xFF4ADE80), fontSize: 12)),
                const SizedBox(width: 4),
                Text(sub2,
                    style: TextStyle(
                        color: isDarkCard
                            ? (blueCard
                                ? const Color(0xFFBFDBFE)
                                : const Color(0xFF93C5FD))
                            : const Color(0xFF93C5FD),
                        fontSize: 12)),
              ],
            ),
        ],
      ),
    );
  }
}

class _RecentTile extends StatelessWidget {
  final String title, isbn, grade;
  final Color color;
  final bool isDark;
  const _RecentTile(
      {required this.title,
      required this.isbn,
      required this.grade,
      required this.color,
      required this.isDark});
  @override
  Widget build(BuildContext c) => Container(
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
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(9)),
              child: Center(
                  child: CustomPaint(
                      size: const Size(20, 20),
                      painter: _SmallBook(color: kAccent))),
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
                  const SizedBox(height: 3),
                  Text(isbn,
                      style: const TextStyle(
                          color: kTextGray, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(grade,
                      style: const TextStyle(
                          color: kAccent, fontSize: 11, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: kTextGray, size: 18),
          ],
        ),
      );
}

class _QuickAction extends StatelessWidget {
  final String emoji, label;
  final VoidCallback onTap;
  const _QuickAction(this.emoji, this.label, this.onTap);
  @override
  Widget build(BuildContext c) {
    final isDark = Theme.of(c).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
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
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? kDarkTextMuted : const Color(0xFF6B7280))),
          ],
        ),
      ),
    );
  }
}

class _SmallBook extends CustomPainter {
  final Color color;
  _SmallBook({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final p = Paint()..color = color;
    final lp = Path()
      ..moveTo(w * 0.1, h * 0.15)
      ..lineTo(w * 0.45, h * 0.15)
      ..cubicTo(w * 0.5, h * 0.15, w * 0.48, h * 0.2, w * 0.48, h * 0.3)
      ..lineTo(w * 0.48, h * 0.9)
      ..lineTo(w * 0.1, h * 0.9)
      ..close();
    canvas.drawPath(lp, p);
    final p2 = Paint()..color = color.withOpacity(0.5);
    final rp = Path()
      ..moveTo(w * 0.9, h * 0.15)
      ..lineTo(w * 0.55, h * 0.15)
      ..cubicTo(w * 0.5, h * 0.15, w * 0.52, h * 0.2, w * 0.52, h * 0.3)
      ..lineTo(w * 0.52, h * 0.9)
      ..lineTo(w * 0.9, h * 0.9)
      ..close();
    canvas.drawPath(rp, p2);
  }

  @override
  bool shouldRepaint(covariant _SmallBook old) => old.color != color;
}
