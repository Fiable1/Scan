import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/api_service.dart';
import '../platform/platform_helpers.dart';
import 'login_screen.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});
  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  bool downloaded = false;
  bool downloading = false;

  Future<void> _download() async {
    setState(() => downloading = true);
    try {
      final r = await ApiService.excel();
      if (r.statusCode != 200) throw Exception('Excel download failed');
      await downloadFile(r.bodyBytes, 'MS_MSAU_Books.xlsx');
      if (mounted) {
        setState(() => downloaded = true);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Excel file downloaded.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Download failed: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => downloading = false);
    }
  }

  Future<void> _logout() async {
    await ApiService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false);
    }
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          AppHeaderBar(
            leading: AppBackButton(onPress: () => Navigator.pop(c)),
            title: 'Export Excel',
            trailing: const Icon(Icons.info_outline, color: Colors.white, size: 20),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Summary card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kNavy,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12)),
                          child: const Center(
                              child: Icon(Icons.description_outlined,
                                  color: Colors.white, size: 24)),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Ready to export',
                                style: TextStyle(
                                    color: Color(0xFF93C5FD),
                                    fontSize: 12)),
                            SizedBox(height: 2),
                            Text('All Scanned Books',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Excel file card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF3F4F6)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: kExcel,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                      color: kExcel.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3)),
                                ],
                              ),
                              child: const Center(
                                child: Text('X',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.w900)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Excel File Ready!',
                                      style: TextStyle(
                                          color: kNavy,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14)),
                                  const SizedBox(height: 4),
                                  const Text('MS_MSAU_Books.xlsx',
                                      style: TextStyle(
                                          color: kTextGray, fontSize: 12)),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                            color: const Color(0xFFDCFCE7),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: const Text('Ready',
                                            style: TextStyle(
                                                color: Color(0xFF15803D),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text('30 May 2024',
                                          style: TextStyle(
                                              color: kTextGray, fontSize: 11)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _metaRow('File Name', 'MS_MSAU_Books.xlsx'),
                        const SizedBox(height: 20),
                        PrimaryButton(
                          label: downloaded
                              ? 'DOWNLOADED!'
                              : (downloading ? 'DOWNLOADING...' : 'DOWNLOAD EXCEL FILE'),
                          color: downloaded ? kGreen : kExcel,
                          onPressed: downloading ? null : _download,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Logout / settings
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF3F4F6)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Account',
                            style: TextStyle(
                                color: kNavy,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                        const SizedBox(height: 8),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading:
                              const Icon(Icons.link, color: kAccent, size: 22),
                          title: const Text('Backend connection',
                              style: TextStyle(
                                  color: kNavy,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                          subtitle: const Text(
                              'backend-ashen-kappa-32.vercel.app',
                              style:
                                  TextStyle(color: kTextGray, fontSize: 11)),
                          trailing: const Icon(Icons.chevron_right,
                              color: kTextGray, size: 20),
                          onTap: () async {
                            final ok = await ApiService.testConnection();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(ok
                                      ? 'Backend connection successful'
                                      : 'Could not connect to backend')));
                            }
                          },
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.logout,
                              color: Color(0xFFEF4444), size: 22),
                          title: const Text('Logout',
                              style: TextStyle(
                                  color: Color(0xFFEF4444),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                          onTap: _logout,
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

  Widget _metaRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(color: kTextGray, fontSize: 12)),
            Flexible(
              child: Text(value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: kNavy,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
}
