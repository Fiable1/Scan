import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/api_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});
  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  Map<String, dynamic>? d;

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
    final cats = _categories();
    final total = _total;
    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          AppHeaderBar(
            leading: AppBackButton(onPress: () => Navigator.pop(c)),
            title: 'Analytics',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20)),
              child: const Text('This Month',
                  style: TextStyle(
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
                            'Total Books', _fmt(total), kNavy),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _StatDark('Today\'s Books', _fmt(_today),
                              kAccent)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Categories card with donut
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Categories',
                            style: TextStyle(
                                color: kNavy,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            SizedBox(
                              width: 140,
                              height: 140,
                              child: DonutChart(
                                  categories: cats, total: total),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                children: cats.isEmpty
                                    ? [const Text('No data',
                                        style: TextStyle(
                                            color: kTextGray))]
                                    : cats
                                        .take(5)
                                        .map((e) => _legendRow(
                                            e['name'].toString(),
                                            e['count'] as int,
                                            total))
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
                        const Text('Books Scanned Over Time',
                            style: TextStyle(
                                color: kNavy,
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
                              painter: LineChartPainter()),
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
                        const Text('Top Categories This Month',
                            style: TextStyle(
                                color: kNavy,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                        const SizedBox(height: 12),
                        if (cats.isEmpty)
                          const Text('No data',
                              style: TextStyle(color: kTextGray))
                        else
                          ...cats.take(4).map((e) {
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
                                          style: const TextStyle(
                                              color: Color(0xFF4B5563),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500)),
                                      Text(_fmt(e['count'] as int),
                                          style: const TextStyle(
                                              color: kNavy,
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
                                      backgroundColor:
                                          const Color(0xFFF3F4F6),
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

  Widget _legendRow(String name, int count, int total) {
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
                  style: const TextStyle(
                      color: Color(0xFF4B5563), fontSize: 11))),
          Text('$pct%',
              style: const TextStyle(
                  color: kNavy,
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
  Widget build(BuildContext c) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF3F4F6)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2)),
          ],
        ),
        child: child,
      );
}

class DonutChart extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final int total;
  const DonutChart({super.key, required this.categories, required this.total});

  @override
  Widget build(BuildContext c) {
    return CustomPaint(
      size: const Size(140, 140),
      painter: _DonutPainter(categories: categories, total: total),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<Map<String, dynamic>> categories;
  final int total;
  _DonutPainter({required this.categories, required this.total});

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

    // Inner white circle
    final inner = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius - 18, inner);
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.categories != categories || old.total != total;
}

class LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final data = [18.0, 24, 31, 22, 45, 38, 52, 44, 56, 48, 62, 56];
    final maxY = 70.0;
    final w = size.width, h = size.height;
    final step = w / (data.length - 1);
    final grid = Paint()
      ..color = const Color(0xFFF3F4F6)
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
  bool shouldRepaint(covariant CustomPainter old) => false;
}
