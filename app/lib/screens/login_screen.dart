import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../services/api_service.dart';
import '../services/app_settings.dart';
import 'register_screen.dart';
import 'home_shell.dart';
import 'backend_url_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;
  bool obscure = true;

  String _t(String en, {String? rw, String? fr}) {
    final loc = context.read<AppSettings>().locale;
    if (loc == 'rw' && rw != null) return rw;
    if (loc == 'fr' && fr != null) return fr;
    return en;
  }

  Future<void> go() async {
    setState(() => loading = true);
    try {
      final r = await ApiService.login(email.text.trim(), password.text);
      await ApiService.saveToken(r['token']);
      await persistLibrarian(r);
      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeShell()));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(_clean(e))));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  String _clean(Object e) => e.toString().replaceFirst('Exception: ', '');

  @override
  Widget build(BuildContext c) {
    final isDark = Theme.of(c).brightness == Brightness.dark;
    final bgColor = isDark ? kDarkScaffold : Colors.white;
    final titleColor = isDark ? kDarkText : kNavy;
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Dark header block
          Container(
            color: isDark ? kDarkCard : kNavy,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Center(child: BookLogoIcon(size: 20)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_t('RWANDA SCHOOL BOOK SCANNER', rw: 'IMASHINI ISOMA IBITABO BY\'IZIKURU', fr: 'SCANNER DE LIVRES SCOLAIRES DU RWANDA'),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                      Text(_t('Digital Library Management', rw: 'Gucunga ububiko bwa digitale', fr: 'Gestion de bibliothèque numérique'),
                          style:
                              const TextStyle(color: Color(0xFF93C5FD), fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => showBackendUrlDialog(context),
                  icon: const Icon(Icons.dns_outlined,
                      color: Colors.white, size: 20),
                  tooltip: _t('Backend URL', rw: 'URL y\'inyuma', fr: 'URL du backend'),
                ),
              ],
            ),
          ),
          // Scrollable body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDBEAFE),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.person, color: kAccent, size: 32),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _t('Welcome Back!', rw: 'Murakaza neza!', fr: 'Bon retour!'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: titleColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _t('Sign in to your librarian account', rw: 'Injira muri konti yawe ya umuyobozi w\'ububiko', fr: 'Connectez-vous à votre compte de bibliothécaire'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: isDark ? kDarkTextMuted : kTextGray, fontSize: 14),
                    ),
                    const SizedBox(height: 28),
                    FieldLabel(_t('Email or Phone', rw: 'Imeyili cyangwa Telefone', fr: 'E-mail ou téléphone')),
                    const SizedBox(height: 6),
                    FormFieldBox(
                      controller: email,
                      hint: _t('Enter email or phone', rw: 'Andika imeyili cyangwa telefone', fr: 'Entrez l\'e-mail ou le téléphone'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? _t('Required', rw: 'Birakenewe', fr: 'Requis')
                          : null,
                    ),
                    const SizedBox(height: 16),
                    FieldLabel(_t('Password', rw: 'Ijambobanga', fr: 'Mot de passe')),
                    const SizedBox(height: 6),
                    FormFieldBox(
                      controller: password,
                      hint: _t('Enter password', rw: 'Andika ijambobanga', fr: 'Entrez le mot de passe'),
                      obscure: obscure,
                      suffix: IconButton(
                        onPressed: () => setState(() => obscure = !obscure),
                        icon: Icon(
                          obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: kTextGray,
                          size: 20,
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? _t('Required', rw: 'Birakenewe', fr: 'Requis') : null,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(_t('Forgot password?', rw: 'Wibagiwe ijambobanga?', fr: 'Mot de passe oublié?'),
                            style: const TextStyle(
                                color: kAccent,
                                fontWeight: FontWeight.w500,
                                fontSize: 12)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    PrimaryButton(
                      label: loading ? _t('SIGNING IN...', rw: 'KUWINJIRA...', fr: 'CONNEXION EN COURS...') : _t('LOGIN', rw: 'INJIRA', fr: 'CONNEXION'),
                      onPressed: loading ? null : go,
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_t('Don\'t have an account?', rw: 'Nta konti ufite?', fr: 'Pas de compte?'),
                            style: TextStyle(
                                color: isDark ? kDarkTextMuted : kTextGray, fontSize: 14)),
                        TextButton(
                          onPressed: () =>
                              Navigator.push(c,
                                  MaterialPageRoute(
                                      builder: (_) => const RegisterScreen())),
                          child: Text(_t('Register as a Librarian', rw: 'Iyandikishe nk\'umuyobozi w\'ububiko', fr: 'Inscrivez-vous comme bibliothécaire'),
                              style: const TextStyle(
                                  color: kAccent,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
