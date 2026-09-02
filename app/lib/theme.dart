import 'package:flutter/material.dart';

const Color kNavy = Color(0xFF0B2154);
const Color kAccent = Color(0xFF2563EB);
const Color kDarkBg = Color(0xFF0A0F1E);
const Color kCoverBlue = Color(0xFF1a3a6b);
const Color kGreen = Color(0xFF22C55E);
const Color kExcel = Color(0xFF217346);
const Color kTextGray = Color(0xFF9CA3AF);
const Color kTextGrayDark = Color(0xFF6B7280);
const Color kFieldBg = Color(0xFFF9FAFB);
const Color kBorderGray = Color(0xFFD1D5DB);
const Color kInactiveGray = Color(0xFF9CA3AF);
const Color kBg = Color(0xFFF9FAFB);

/// The status bar shown on top of most screens (9:41 + signal + battery).
class StatusBar extends StatelessWidget {
  const StatusBar({super.key, this.dark = false});
  final bool dark;
  @override
  Widget build(BuildContext c) {
    return Container(
      height: 40,
      color: dark ? Colors.black.withOpacity(0.5) : kNavy,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text('9:41',
              style: TextStyle(
                  color: const Color(0xFFFFFFFF),
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          const Spacer(),
          _signal(),
          const SizedBox(width: 6),
          _battery(),
        ],
      ),
    );
  }

  Widget _signal() => Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _bar(4),
          const SizedBox(width: 1.5),
          _bar(6),
          const SizedBox(width: 1.5),
          _bar(9),
        ],
      );

  Widget _bar(double h) => Container(
        width: 3,
        height: h,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(1)),
      );

  Widget _battery() => Container(
        width: 25,
        height: 12,
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withOpacity(0.7), width: 1.2),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
              width: 17, height: 8, decoration: BoxDecoration(color: Colors.white)),
        ),
      );
}

/// App header bar with navy background.
class AppHeaderBar extends StatelessWidget {
  const AppHeaderBar({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.center = false,
  });
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool center;
  @override
  Widget build(BuildContext c) {
    return Container(
      color: kNavy,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          leading ?? const SizedBox(width: 32),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
              children: [
                Text(title,
                    textAlign: center ? TextAlign.center : TextAlign.start,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                if (subtitle != null)
                  Text(subtitle!,
                      textAlign: center ? TextAlign.center : TextAlign.start,
                      style: const TextStyle(color: Color(0xFF93C5FD), fontSize: 12)),
              ],
            ),
          ),
          if (trailing != null) trailing!
        ],
      ),
    );
  }
}

/// White chevron-left back arrow button (per design).
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, required this.onPress});
  final VoidCallback onPress;
  @override
  Widget build(BuildContext c) => IconButton(
        onPressed: onPress,
        icon: SizedBox(
          width: 20,
          height: 20,
          child: CustomPaint(painter: _ChevronPainter()),
        ),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      );
}

class _ChevronPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width * 0.33, size.height * 0.5)
      ..lineTo(size.width, size.height);
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// The open-book logo icon used in headers and the splash screen.
class BookLogoIcon extends StatelessWidget {
  const BookLogoIcon({super.key, this.size = 20});
  final double size;
  @override
  Widget build(BuildContext c) => CustomPaint(
        size: Size.square(size),
        painter: _BookLogoPainter(),
      );
}

class _BookLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final left = Paint()..color = const Color(0xFF93C5FD);
    final right = Paint()..color = Colors.white;
    final lp = Path()
      ..moveTo(w * 0.16, 0)
      ..lineTo(w * 0.46, 0)
      ..cubicTo(w * 0.54, 0, w * 0.5, -0.02, w * 0.5, h * 0.12)
      ..lineTo(w * 0.5, h)
      ..lineTo(w * 0.16, h)
      ..close();
    canvas.drawPath(lp, left);
    final rp = Path()
      ..moveTo(w * 0.84, 0)
      ..lineTo(w * 0.54, 0)
      ..cubicTo(w * 0.46, 0, w * 0.5, -0.02, w * 0.5, h * 0.12)
      ..lineTo(w * 0.5, h)
      ..lineTo(w * 0.84, h)
      ..close();
    canvas.drawPath(rp, right);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Form input field styled exactly like the design.
class FormFieldBox extends StatelessWidget {
  const FormFieldBox({
    super.key,
    required this.controller,
    this.hint,
    this.keyboardType,
    this.obscure,
    this.suffix,
    this.validator,
  });
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final bool? obscure;
  final Widget? suffix;
  final FormFieldValidator<String>? validator;
  @override
  Widget build(BuildContext c) => TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscure ?? false,
        validator: validator,
        style: const TextStyle(color: Color(0xFF374151), fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: kTextGray),
          filled: true,
          fillColor: kFieldBg,
          suffixIcon: suffix,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kBorderGray),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kAccent),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
        ),
      );
}

/// Small uppercase field label (e.g. "Email or Phone").
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext c) => Text(
        text.toUpperCase(),
        style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6),
      );
}

/// Big rounded primary button (navy).
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color = kNavy,
  });
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  @override
  Widget build(BuildContext c) => SizedBox(
        width: double.infinity,
        child: Material(
          color: onPressed == null ? Colors.grey : color,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ),
          ),
        ),
      );
}

/// Bottom navigation bar matching the design (raised center scan button).
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.active,
    required this.onNavigate,
  });
  final String active; // one of dashboard/books/scan/analytics/export
  final void Function(String) onNavigate;

  @override
  Widget build(BuildContext c) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        height: 68,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _item('dashboard', 'Dashboard', _dashboardIcon(active == 'dashboard'), () => onNavigate('dashboard')),
            _item('books', 'Books', _booksIcon(active == 'books'), () => onNavigate('books')),
            _scanCenter(),
            _item('analytics', 'Reports', _reportIcon(active == 'analytics'), () => onNavigate('analytics')),
            _item('export', 'More', _moreIcon(active == 'export'), () => onNavigate('export')),
          ],
        ),
      ),
    );
  }

  Widget _item(String id, String label, Widget icon, VoidCallback onTap) {
    final activeNow = active == id;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(height: 3),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: activeNow ? kAccent : kInactiveGray)),
        ],
      ),
    );
  }

  Widget _scanCenter() => GestureDetector(
        onTap: () => onNavigate('scan'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active == 'scan' ? kAccent : kNavy,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3)),
                ],
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: CustomPaint(
                      painter: _BarcodePainter(
                          color: Colors.white, thickness: 2, gap: 2)),
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text('Scan',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: active == 'scan' ? kAccent : kInactiveGray)),
          ],
        ),
      );

  Widget _dashboardIcon(bool on) {
    final col = on ? kAccent : kInactiveGray;
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _DashPainter(col)),
    );
  }

  Widget _booksIcon(bool on) {
    final col = on ? kAccent : kInactiveGray;
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _BooksPainter(col)),
    );
  }

  Widget _reportIcon(bool on) {
    final col = on ? kAccent : kInactiveGray;
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _ReportPainter(col)),
    );
  }

  Widget _moreIcon(bool on) {
    final col = on ? kAccent : kInactiveGray;
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _MorePainter(col)),
    );
  }
}

class _DashPainter extends CustomPainter {
  final Color c;
  _DashPainter(this.c);
  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width / 4, h = s.height / 4;
    final p = Paint()..color = c;
    for (final pos in [(0, 0), (2, 0), (0, 2), (2, 2)]) {
      Rect r = Rect.fromLTWH(pos.$1 * w + 1, pos.$2 * h + 1, w * 0.68, h * 0.68);
      canvas.drawRRect(RRect.fromRectAndRadius(r, Radius.circular(w * 0.2)), p);
    }
  }

  @override
  bool shouldRepaint(covariant _DashPainter o) => o.c != c;
}

class _BooksPainter extends CustomPainter {
  final Color c;
  _BooksPainter(this.c);
  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    final p = Paint()..color = c;
    final lp = Path()
      ..moveTo(w * 0.12, 0)
      ..lineTo(w * 0.44, 0)
      ..cubicTo(w * 0.5, 0, w * 0.47, 0.05, w * 0.47, h * 0.18)
      ..lineTo(w * 0.47, h)
      ..lineTo(w * 0.12, h)
      ..close();
    canvas.drawPath(lp, p);
    final rp = Paint()..color = c.withOpacity(0.6);
    final rr = Path()
      ..moveTo(w * 0.88, 0)
      ..lineTo(w * 0.56, 0)
      ..cubicTo(w * 0.5, 0, w * 0.53, 0.05, w * 0.53, h * 0.18)
      ..lineTo(w * 0.53, h)
      ..lineTo(w * 0.88, h)
      ..close();
    canvas.drawPath(rr, rp);
  }

  @override
  bool shouldRepaint(covariant _BooksPainter o) => o.c != c;
}

class _ReportPainter extends CustomPainter {
  final Color c;
  _ReportPainter(this.c);
  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    final p = Paint()..color = c;
    final heights = [0.7, 0.4, 0.55, 0.25];
    final bw = w * 0.2;
    for (var i = 0; i < heights.length; i++) {
      final rect = Rect.fromLTWH(i * (bw + w * 0.05) + w * 0.02, h * (1 - heights[i]),
          bw, h * heights[i]);
      canvas.drawRect(rect, p);
    }
  }

  @override
  bool shouldRepaint(covariant _ReportPainter o) => o.c != c;
}

class _MorePainter extends CustomPainter {
  final Color c;
  _MorePainter(this.c);
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..color = c;
    for (final x in [s.width * 0.2, s.width * 0.5, s.width * 0.8]) {
      canvas.drawCircle(Offset(x, s.height / 2), s.width * 0.07, p);
    }
  }

  @override
  bool shouldRepaint(covariant _MorePainter o) => o.c != c;
}

/// Barcode icon made of vertical bars.
class _BarcodePainter extends CustomPainter {
  final Color color;
  final double thickness;
  final double gap;
  _BarcodePainter({required this.color, this.thickness = 2, this.gap = 2});
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color;
    final widths = [thickness, thickness, thickness, thickness, thickness];
    double x = 0;
    for (final w in widths) {
      canvas.drawRect(Rect.fromLTWH(x, 0, w, size.height), p);
      x += w + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _BarcodePainter old) => false;
}

const List<String> kBookCoverColors = [
  '#1a3a6b',
  '#1e5c3a',
  '#7b1f1f',
  '#4a1a6b',
];

Color coverColor(String t) {
  final map = {
    'mathematics': '#1a3a6b',
    'english': '#1e5c3a',
    'science': '#7b1f1f',
    'social studies': '#4a1a6b',
    'kinyarwanda': '#1a3a6b',
  };
  final cat = t.toLowerCase();
  for (final e in map.entries) {
    if (cat.contains(e.key)) return Color(int.parse('FF${e.value}', radix: 16));
  }
  return kCoverBlue;
}
