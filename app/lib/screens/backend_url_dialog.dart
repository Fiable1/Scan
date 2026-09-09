import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../services/app_settings.dart';
import '../theme.dart';

/// Dialog to view/change the backend base URL. Reachable before login so a
/// phone pointed at the wrong host can still be reconfigured.
Future<void> showBackendUrlDialog(BuildContext context) async {
  final controller = TextEditingController(text: await ApiService.baseUrl());
  final settings = context.read<AppSettings>();
  final isDark = Theme.of(context).brightness == Brightness.dark;

  String t(String en, {String? rw, String? fr}) {
    final loc = settings.locale;
    if (loc == 'rw' && rw != null) return rw;
    if (loc == 'fr' && fr != null) return fr;
    return en;
  }

  final saved = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      backgroundColor: isDark ? kDarkCard : Colors.white,
      title: Text(t('Backend URL', rw: 'URL y\'inyuma', fr: 'URL du backend')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t('Confirm backend URL:', rw: 'Emeza URL y\'inyuma:', fr: 'Confirmez l\'URL du backend:'),
              style: TextStyle(
                  color: isDark ? kDarkTextMuted : kTextGray, fontSize: 12)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: TextInputType.url,
            autocorrect: false,
            style: TextStyle(color: isDark ? kDarkText : kNavy),
            decoration: InputDecoration(
              hintText: 'https://your-project.vercel.app',
              filled: true,
              fillColor: isDark ? kDarkFieldBg : kFieldBg,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(color: isDark ? kDarkBorder : kBorderGray)),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(c, false),
          child: Text(
              t('Cancel', rw: 'Guhagarika', fr: 'Annuler'),
              style: const TextStyle(color: kTextGray)),
        ),
        TextButton(
          onPressed: () async {
            var v = controller.text.trim();
            if (v.isEmpty) {
              v = ApiService.deployedBaseUrl;
            }
            await ApiService.setBaseUrl(v);
            if (c.mounted) Navigator.pop(c, true);
          },
          child:
              Text(t('Save', rw: 'Bika', fr: 'Enregistrer'), style: const TextStyle(color: kAccent)),
        ),
      ],
    ),
  );

  if (saved == true && context.mounted) {
    final ok = await ApiService.testConnection();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ok
              ? t('Backend connection successful', rw: 'Ihuza n\'inyuma ryakunze', fr: 'Connexion backend réussie')
              : t('Could not connect to backend', rw: 'Ntihashoboye guhuza n\'inyuma', fr: 'Impossible de se connecter au backend'))));
    }
  }
}