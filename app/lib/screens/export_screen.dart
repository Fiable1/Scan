import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../services/api_service.dart';
import '../services/app_settings.dart';
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

  String _t(String en, {String? rw, String? fr}) {
    final loc = context.read<AppSettings>().locale;
    if (loc == 'rw' && rw != null) return rw;
    if (loc == 'fr' && fr != null) return fr;
    return en;
  }

  Future<void> _download() async {
    setState(() => downloading = true);
    try {
      final r = await ApiService.excel();
      if (r.statusCode != 200) throw Exception(_t('Excel download failed', rw: 'Imana Excel yanze', fr: 'Le téléchargement Excel a échoué'));
      await downloadFile(r.bodyBytes, 'MS_MSAU_Books.xlsx');
      if (mounted) {
        setState(() => downloaded = true);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_t('Excel file downloaded.', rw: 'Dosiye ya Excel yamanutse.', fr: 'Fichier Excel téléchargé.'))));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('${_t('Download failed: ', rw: 'Imana itanze: ', fr: 'Téléchargement échoué: ')}${e.toString()}')));
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

  Future<void> _showSettings() async {
    final settings = context.read<AppSettings>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    await showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? kDarkCard : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (c) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_t('Settings', rw: 'Igenamiterere', fr: 'Paramètres'),
                style: TextStyle(
                    color: isDark ? kDarkText : kNavy,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            // Language selection
            Text(
              _t('Language', rw: 'Ururimi', fr: 'Langue'),
              style: TextStyle(
                  color: isDark ? kDarkTextMuted : kTextGray, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['en', 'rw', 'fr'].map((code) {
                final names = {
                  'en': 'English',
                  'rw': 'Kinyarwanda',
                  'fr': 'Français',
                };
                final selected = settings.locale == code;
                return ChoiceChip(
                  label: Text(names[code]!),
                  selected: selected,
                  onSelected: (_) => settings.setLocale(code),
                  selectedColor: kAccent,
                  labelStyle: TextStyle(
                      color: selected ? Colors.white : (isDark ? kDarkText : kNavy)),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            // Theme selection
            Text(
              _t('Theme', rw: 'Uburyo', fr: 'Thème'),
              style: TextStyle(
                  color: isDark ? kDarkTextMuted : kTextGray, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: Text(_t('Light', rw: 'Urumuri', fr: 'Clair')),
                  selected: settings.themeMode == ThemeMode.light,
                  onSelected: (_) => settings.setThemeMode(ThemeMode.light),
                  selectedColor: kAccent,
                  labelStyle: TextStyle(
                      color: settings.themeMode == ThemeMode.light
                          ? Colors.white
                          : (isDark ? kDarkText : kNavy)),
                ),
                ChoiceChip(
                  label: Text(_t('Dark', rw: 'Umukara', fr: 'Sombre')),
                  selected: settings.themeMode == ThemeMode.dark,
                  onSelected: (_) => settings.setThemeMode(ThemeMode.dark),
                  selectedColor: kAccent,
                  labelStyle: TextStyle(
                      color: settings.themeMode == ThemeMode.dark
                          ? Colors.white
                          : (isDark ? kDarkText : kNavy)),
                ),
                ChoiceChip(
                  label: Text(_t('System', rw: 'Sisitemu', fr: 'Système')),
                  selected: settings.themeMode == ThemeMode.system,
                  onSelected: (_) => settings.setThemeMode(ThemeMode.system),
                  selectedColor: kAccent,
                  labelStyle: TextStyle(
                      color: settings.themeMode == ThemeMode.system
                          ? Colors.white
                          : (isDark ? kDarkText : kNavy)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(c),
                child: Text(_t('Done', rw: 'Rangiza', fr: 'Terminé'),
                    style: const TextStyle(
                        color: kAccent, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext c) {
    final isDark = Theme.of(c).brightness == Brightness.dark;
    final cardColor = isDark ? kDarkCard : Colors.white;
    final border = isDark ? kDarkBorder : const Color(0xFFF3F4F6);
    final titleColor = isDark ? kDarkText : kNavy;
    return Scaffold(
      backgroundColor: isDark ? kDarkScaffold : kBg,
      body: Column(
        children: [
          AppHeaderBar(
            leading: AppBackButton(onPress: () => Navigator.pop(c)),
            title: _t('Export Excel', rw: 'Ohereza Excel', fr: 'Exporter Excel'),
            trailing: Icon(Icons.info_outline, color: Colors.white, size: 20),
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
                      color: isDark ? kDarkCard : kNavy,
                      borderRadius: BorderRadius.circular(16),
                      border: isDark ? Border.all(color: kDarkBorder) : null,
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
                          children: [
                            Text(_t('Ready to export', rw: 'Witeguye kohereza', fr: 'Prêt à exporter'),
                                style: const TextStyle(
                                    color: Color(0xFF93C5FD),
                                    fontSize: 12)),
                            const SizedBox(height: 2),
                            Text(_t('All Scanned Books', rw: 'Ibitabo byose byasomwe', fr: 'Tous les livres scannés'),
                                style: const TextStyle(
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
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: border),
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
                                  Text(_t('Excel File Ready!', rw: 'Dosiye ya Excel iteguye!', fr: 'Fichier Excel prêt!'),
                                      style: TextStyle(
                                          color: titleColor,
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
                                        child: Text(_t('Ready', rw: 'Itanditse', fr: 'Prêt'),
                                            style: const TextStyle(
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
                        _metaRow(c, _t('File Name', rw: 'Izina ry\'idosiye', fr: 'Nom du fichier'), 'MS_MSAU_Books.xlsx'),
                        const SizedBox(height: 20),
                        PrimaryButton(
                          label: downloaded
                              ? _t('DOWNLOADED!', rw: 'BYAMANUTSE!', fr: 'TÉLÉCHARGÉ!')
                              : (downloading ? _t('DOWNLOADING...', rw: 'KUMA...', fr: 'TÉLÉCHARGEMENT...') : _t('DOWNLOAD EXCEL FILE', rw: 'KUZA DOSIYE EXCEL', fr: 'TÉLÉCHARGER FICHIER EXCEL')),
                          color: downloaded ? kGreen : kExcel,
                          onPressed: downloading ? null : _download,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Settings card - includes theme/language switch AND logout
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_t('Settings', rw: 'Igenamiterere', fr: 'Paramètres'),
                            style: TextStyle(
                                color: titleColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                        const SizedBox(height: 8),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading:
                              const Icon(Icons.settings, color: kAccent, size: 22),
                          title: Text(_t('Theme & Language', rw: 'Uburyo n\'Ururimi', fr: 'Thème et Langue'),
                              style: TextStyle(
                                  color: titleColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                          subtitle: Text(
                              _t('Switch dark/light mode or language', rw: 'Hindura uburyo bw\'umukara/urumuri cyangwa ururimi', fr: 'Changer le mode ou la langue'),
                              style: const TextStyle(
                                  color: kTextGray, fontSize: 11)),
                          trailing: const Icon(Icons.chevron_right,
                              color: kTextGray, size: 20),
                          onTap: _showSettings,
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading:
                              const Icon(Icons.link, color: kAccent, size: 22),
                          title: Text(_t('Backend connection', rw: 'Ihuza n\'inyuma', fr: 'Connexion backend'),
                              style: TextStyle(
                                  color: titleColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                          subtitle: const Text(
                              'localhost:5000',
                              style:
                                  TextStyle(color: kTextGray, fontSize: 11)),
                          trailing: const Icon(Icons.chevron_right,
                              color: kTextGray, size: 20),
                          onTap: () async {
                            final ok = await ApiService.testConnection();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(ok
                                      ? _t('Backend connection successful', rw: 'Ihuza n\'inyuma ryakunze', fr: 'Connexion backend réussie')
                                      : _t('Could not connect to backend', rw: 'Ntihashoboye guhuza n\'inyuma', fr: 'Impossible de se connecter au backend'))));
                            }
                          },
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.logout,
                              color: Color(0xFFEF4444), size: 22),
                          title: Text(_t('Logout', rw: 'Sohoka', fr: 'Déconnexion'),
                              style: const TextStyle(
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

  Widget _metaRow(BuildContext c, String label, String value) {
    final isDark = Theme.of(c).brightness == Brightness.dark;
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(color: kTextGray, fontSize: 12)),
            Flexible(
              child: Text(value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: isDark ? kDarkText : kNavy,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
  }
}
