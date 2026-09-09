import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../services/api_service.dart';
import '../services/app_settings.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});
  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  Map<String, dynamic>? d;

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
    try {
      d = await ApiService.analytics();
    } catch (_) {}
    if (mounted) setState(() {});
  }

  List<Map<String, dynamic>> _categories() {
    final raw = (d?['by_category'] as List?) ?? [];
    return raw
        .map((e) => {
              'name': (e['category']?.toString().isNotEmpty == true
                      ? e['category'].toString()
                      : 'Others'),
              'count': (e['total'] as num?)?.toInt() ?? 0,
            })
        .toList();
  }

  int get _total => (d?['total_books'] as num?)?.toInt() ?? 1248;
  int get _today => (d?['today'] as num?)?.toInt() ?? 56;

  @override
  Widget build(BuildContext c) {
    final isDark = Theme.of(c).brightness == Brightness.dark;
    final titleColor = isDark ? kDarkText : kNavy;
    final grouped = _categories();
    final total = _total;
    return Scaffold(
      backgroundColor: isDark ? kDarkScaffold : kBg,
      body: Column(
        children: [
          AppHeaderBar(
            leading: AppBackButton(onPress: () => Navigator.pop(c)),
            title: _t('Analytics', rw: 'Icyifuzo', fr: 'Analyses'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20)),
              child: Text(_t('This Month', rw: 'Ukwezi', fr: 'Ce mois'),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatDark(
                            _t('Total Books', rw: 'Ibitabo byose', fr: 'Total de livres'), _fmt(total), kNavy),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _StatDark(_t('Today\'s Books', rw: 'Ibitabo bya Uyu Munsi', fr: 'Livres du jour'), _fmt(_today),
                              kAccent)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Categories card with donut
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_t('Categories', rw: 'Ibyiciro', fr: 'Catégories'),
                            style: TextStyle(
                                color: titleColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                        Row(
                          children: [
                            SizedBox(
                              width: 140,
                              height: 140,
                              child: DonutChart(
                                  categories: grouped, total: total, isDark: isDark),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                children: grouped.isEmpty
                                    ? [Text(_t('No data', rw: 'Nta makuru', fr: 'Aucune donnée'),
                                        style: TextStyle(
                                            color: isDark ? kDarkTextMuted : kTextGray))]
                                    : grouped
                                        .take(5)
                                        .map((e) => _legendRow(
                                            e['name'].toString(),
                                            e['count'] as int,
                                            total,
                                            isDark))
                                        .toList(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Line chart card
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_t('Books Scanned Over Time', rw: 'Ibitabo byasomwe mugihe', fr: 'Livres scannés au fil du temps'),
                            style: TextStyle(
                                color: titleColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                        const Text('2023',
                            style: TextStyle(
                                color: kTextGray, fontSize: 11)),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 100,
                          width: double.infinity,
                          child: CustomPaint(
                              painter: LineChartPainter(isDark: isDark)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Top categories
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_t('Top Categories This Month', rw: 'Ibyiciro byo hejuru Ukwezi', fr: 'Meilleures catégories ce mois'),
                            style: TextStyle(
                                color: titleColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                        const SizedBox(height: 12),
                        if (grouped.isEmpty)
                          Text(_t('No data', rw: 'Nta makuru', fr: 'Aucune donnée'),
                              style: TextStyle(
                                  color: isDark ? kDarkTextMuted : kTextGray))
                        else
                          ...grouped.take(4).map((e) {
                            final pct = total == 0
                                ? 0.0
                                : (e['count'] as int) / total * 100;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(e['name'].toString(),
                                          style: TextStyle(
                                              color: isDark ? kDarkTextMuted : const Color(0xFF4B5563),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500)),
                                      Text(_fmt(e['count'] as int),
                                          style: TextStyle(
                                              color: titleColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: (pct / 100).clamp(0.0, 1.0),
                                      minHeight: 8,
                                      backgroundColor: isDark
                                          ? kDarkBorder
                                          : const Color(0xFFF3F4F6),
                                      valueColor:
                                          const AlwaysStoppedAnimation(
                                              kAccent),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
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

  String _fmt(int v) {
    final s = v.toString();
    if (v >= 1000) {
      return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
    }
    return s;
  }

  Widget _legendRow(String name, int count, int total, bool isDark) {
    final pct = total == 0 ? 0 : (count / total * 100).round();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
                color: _colorFor(name), borderRadius: BorderRadius.circular(3)),
          ),
          const SizedBox(width: 8),
          Expanded(
              child: Text(name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: isDark ? kDarkTextMuted : const Color(0xFF4B5563), fontSize: 11))),
          Text('$pct%',
              style: TextStyle(
                  color: isDark ? kDarkText : kNavy,
                  fontSize: 11,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Color _colorFor(String name) {
    const colors = [
      kAccent, kGreen, Color(0xFFF59E0B), Color(0xFF8B5CF6), Color(0xFF6B7280)
    ];
    var h = 0;
    for (final ch in name.codeUnits) {
      h = (h + ch) % colors.length;
    }
    return colors[h];
  }
}

class _StatDark extends StatelessWidget {
  final String label, value;
  final Color bg;
  const _StatDark(this.label, this.value, this.bg);
  @override
  Widget build(BuildContext c) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(),
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: bg == kAccent
                        ? const Color(0xFFDBEAFE)
                        : const Color(0xFF93C5FD))),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900)),
          ],
        ),
      );
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext c) {
    final isDark = Theme.of(c).brightness == Brightness.dark;
    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? kDarkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
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
        child: child,
      );
  }
}

class DonutChart extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final int total;
  final bool isDark;
  const DonutChart({super.key, required this.categories, required this.total, required this.isDark});

  @override
  Widget build(BuildContext c) {
    return CustomPaint(
      size: const Size(140, 140),
      painter: _DonutPainter(categories: categories, total: total, isDark: isDark),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<Map<String, dynamic>> categories;
  final int total;
  final bool isDark;
  _DonutPainter({required this.categories, required this.total, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    const colors = [
      kAccent, kGreen, Color(0xFFF59E0B), Color(0xFF8B5CF6), Color(0xFF6B7280)
    ];
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final effective = total == 0 ? 1 : total;

    var start = -math.pi / 2;
    final p = Paint()..style = PaintingStyle.stroke;

    for (var i = 0; i < categories.length && i < colors.length; i++) {
      final count = (categories[i]['count'] as int);
      final sweep = (count / effective) * 2 * math.pi;
      p.color = colors[i];
      p.strokeWidth = 18;
      p.strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, start, sweep - 0.02, false, p);
      start += sweep;
    }

    // Inner white/dark circle
    final inner = Paint()..color = isDark ? kDarkCard : Colors.white;
    canvas.drawCircle(center, radius - 18, inner);
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.categories != categories || old.total != total || old.isDark != isDark;
}

class LineChartPainter extends CustomPainter {
  final bool isDark;
  LineChartPainter({required this.isDark});
  @override
  void paint(Canvas canvas, Size size) {
    final data = [18.0, 24, 31, 22, 45, 38, 52, 44, 56, 48, 62, 56];
    final maxY = 70.0;
    final w = size.width, h = size.height;
    final step = w / (data.length - 1);
    final grid = Paint()
      ..color = isDark ? kDarkBorder : const Color(0xFFF3F4F6)
      ..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final y = h * i / 3;
      canvas.drawLine(Offset(0, y), Offset(w, y), grid);
    }
    final line = Paint()
      ..color = kAccent
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path();
    for (var i = 0; i < data.length; i++) {
      final x = i * step;
      final y = h - (data[i] / maxY) * (h - 10);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, line);
    final dot = Paint()..color = kAccent;
    for (var i = 0; i < data.length; i++) {
      final x = i * step;
      final y = h - (data[i] / maxY) * (h - 10);
      canvas.drawCircle(Offset(x, y), 3.5, dot);
    }
  }

  @override
  bool shouldRepaint(covariant LineChartPainter old) => old.isDark != isDark;
}