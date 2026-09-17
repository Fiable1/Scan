import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../services/api_service.dart';
import '../services/app_settings.dart';
import 'book_info_screen.dart';
import 'home_shell.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});
  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final MobileScannerController _scanner = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    formats: const [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.code128,
      BarcodeFormat.code39,
      BarcodeFormat.qrCode,
    ],
  );
  bool _handling = false;

  String _t(String en, {String? rw, String? fr}) {
    final loc = context.read<AppSettings>().locale;
    if (loc == 'rw' && rw != null) return rw;
    if (loc == 'fr' && fr != null) return fr;
    return en;
  }

  @override
  void initState() {
    super.initState();
    _prepareCamera();
  }

  Future<void> _prepareCamera() async {
    if (kIsWeb) return;
    try {
      await Permission.camera.request();
    } catch (_) {}
  }

  @override
  void dispose() {
    _scanner.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handling) return;
    String? value;
    for (final b in capture.barcodes) {
      final v = b.rawValue ?? b.displayValue;
      if (v != null && v.trim().isNotEmpty) {
        value = v.trim();
        break;
      }
    }
    if (value == null) return;
    _handling = true;
    await _lookup(value);
  }

  Future<void> _manualEntry() async {
    final controller = TextEditingController();
    final code = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: kNavy,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (c) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(c).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_t('Enter Barcode / ISBN', rw: 'Andika Barcode / ISBN', fr: 'Entrez code-barres / ISBN'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                style: const TextStyle(color: Color(0xFF25140f)),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'e.g. 9780199386429',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: _t('LOOKUP BOOK', rw: 'SHAKISHA IGITABO', fr: 'RECHERCHER LIVRE'),
                onPressed: () =>
                    Navigator.pop(c, controller.text.trim()),
              ),
            ],
          ),
        ),
      ),
    );
    if (code == null || code.isEmpty) return;
    _handling = true;
    await _lookup(code);
  }

  Future<void> _fromGallery() async {
    try {
      final x = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (x == null) return;
      final found = await _scanner.analyzeImage(x.path);
      if (found != true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(_t('No barcode found. Enter ISBN manually.',
                rw: 'Nta barcode yabonetse. Andika ISBN.',
                fr: 'Aucun code-barres trouvé. Saisissez l\'ISBN.'))));
      }
    } catch (_) {
      if (mounted) await _manualEntry();
    }
  }

  Future<void> _howToScan() async {
    await showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: kNavy,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(_t('How to scan?', rw: 'Nigute wasoma?', fr: 'Comment scanner?'),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          _t(
              'Point the camera at the book barcode and keep it inside the frame. You can also pick a photo from the gallery or enter the ISBN manually.',
              rw: 'Erekeza kamera kuri barcode y\'igitabo uyishyire mu kazu. Ushobora no gukoresha ifoto cyangwa kwandika ISBN.',
              fr: 'Pointez la caméra vers le code-barres et gardez-le dans le cadre. Vous pouvez aussi choisir une photo ou saisir l\'ISBN.'),
          style: const TextStyle(color: Color(0xFF93C5FD), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: Text(_t('OK', rw: 'Sawa', fr: 'OK'),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _lookup(String code) async {
    try {
      await _scanner.stop();
    } catch (_) {}
    try {
      final info = await ApiService.lookup(code);
      if (!mounted) return;
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => BookInfoScreen(code: code, info: info)));
    } catch (e) {
      if (mounted) {
        await Navigator.push(context,
            MaterialPageRoute(builder: (_) => BookInfoScreen(code: code)));
      }
    } finally {
      _handling = false;
      if (mounted) {
        try {
          await _scanner.start();
        } catch (_) {}
      }
    }
  }

  @override
  Widget build(BuildContext c) {
    final isDark = Theme.of(c).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: kDarkBg,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Container(
                color: kNavy,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    AppBackButton(onPress: () {
                      Navigator.pushReplacement(c,
                          MaterialPageRoute(builder: (_) => const HomeShell()));
                    }),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_t('Scan Barcode', rw: 'Soma barcode', fr: 'Scanner le code-barres'),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ),
                    GestureDetector(
                      onTap: _manualEntry,
                      child: const Icon(Icons.search, color: Colors.white, size: 22),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0A0F1E), Color(0xFF0D1523), Color(0xFF0A0F1E)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: MobileScanner(
                          controller: _scanner,
                          onDetect: _onDetect,
                          errorBuilder: (context, error, child) => const SizedBox.expand(),
                        ),
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                radius: 1.3,
                                colors: [
                                  Colors.transparent,
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.55),
                                ],
                                stops: const [0.35, 0.6, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_t('Align barcode within the frame', rw: 'Shyira barcode mu kazu', fr: 'Alignez le code-barres dans le cadre'),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: 256,
                              height: 160,
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    child: _Corner(horizontal: true),
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: RotatedBox(
                                        quarterTurns: 1, child: _Corner(horizontal: true)),
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: RotatedBox(
                                        quarterTurns: 2, child: _Corner(horizontal: true)),
                                  ),
                                  Positioned(
                                    left: 0,
                                    bottom: 0,
                                    child: RotatedBox(
                                        quarterTurns: 3, child: _Corner(horizontal: true)),
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                      height: 2,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF87171),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.red
                                                .withOpacity(0.5),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              _t('Position the barcode clearly within the frame', rw: 'Shyira barcode neza mu kazu', fr: 'Positionnez clairement le code-barres dans le cadre'),
                              style: TextStyle(
                                  color: isDark ? kDarkTextMuted : kTextGray, fontSize: 12),
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: _manualEntry,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(_t('Enter ISBN manually', rw: 'Andika ISBN mu buryo bw\'amaboko', fr: 'Saisir l\'ISBN manuellement'),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                color: kNavy,
                padding: const EdgeInsets.fromLTRB(32, 20, 32, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ActionButton(Icons.photo_outlined, _t('Gallery', rw: 'Igifuniko', fr: 'Galerie'), onTap: _fromGallery),
                    GestureDetector(
                      onTap: () async {
                        try {
                          await _scanner.start();
                        } catch (_) {}
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: kAccent,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: const Color(0xFF93C5FD), width: 3),
                              boxShadow: [
                                BoxShadow(
                                    color: kAccent.withOpacity(0.4),
                                    blurRadius: 20,
                                    spreadRadius: 2),
                              ],
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: CustomPaint(
                                    painter: _ScanBarcodeIcon()),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(_t('Capture', rw: 'Fata', fr: 'Capturer'),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    _ActionButton(Icons.help_outline, _t('How to scan?', rw: 'Nigute wasoma?', fr: 'Comment scanner?'), onTap: _howToScan),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanBarcodeIcon extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white;
    final widths = [size.width * 0.1, size.width * 0.1, size.width * 0.1, size.width * 0.1, size.width * 0.1];
    var x = 0.0;
    final gap = size.width * 0.06;
    for (final w in widths) {
      canvas.drawRect(Rect.fromLTWH(x, 0, w, size.height), p);
      x += w + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _Corner extends StatelessWidget {
  final bool horizontal;
  const _Corner({required this.horizontal});
  @override
  Widget build(BuildContext c) => SizedBox(
        width: 32,
        height: 32,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                  width: 32, height: 4,
                  decoration: BoxDecoration(
                      color: const Color(0xFF60A5FA),
                      borderRadius: BorderRadius.circular(8))),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                  width: 4, height: 32,
                  decoration: BoxDecoration(
                      color: const Color(0xFF60A5FA),
                      borderRadius: BorderRadius.circular(8))),
            ),
          ],
        ),
      );
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton(this.icon, this.label, {required this.onTap});
  @override
  Widget build(BuildContext c) => GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(
                    color: Colors.white, fontSize: 12)),
          ],
        ),
      );
}
