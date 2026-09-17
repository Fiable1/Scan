import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../services/api_service.dart';
import '../services/app_settings.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail = ''});
  final String initialEmail;
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final TextEditingController email;
  final code = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();
  bool loading = false;
  bool sent = false;
  bool obscure = true;

  @override
  void initState() {
    super.initState();
    email = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    email.dispose();
    code.dispose();
    password.dispose();
    confirm.dispose();
    super.dispose();
  }

  String _t(String en, {String? rw, String? fr}) {
    final loc = context.read<AppSettings>().locale;
    if (loc == 'rw' && rw != null) return rw;
    if (loc == 'fr' && fr != null) return fr;
    return en;
  }

  String _clean(Object e) => e.toString().replaceFirst('Exception: ', '');

  Future<void> sendCode() async {
    if (email.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_t('Enter your registered email', rw: 'Andika imeyili wanditsweho', fr: 'Entrez l\'e-mail enregistré'))));
      return;
    }
    setState(() => loading = true);
    try {
      final r = await ApiService.forgotPassword(email.text.trim());
      if (!mounted) return;
      setState(() => sent = true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_clean(r['detail'] ??
              _t('If this email is registered, a recovery code was sent.',
                  rw: 'Niba iyi imeyili yanditswe, kode yo kugarura yoherejwe.',
                  fr: 'Si cet e-mail est inscrit, un code de récupération a été envoyé.')))));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(_clean(e))));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> reset() async {
    if (password.text != confirm.text) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_t('Passwords do not match', rw: 'Amagambo banga ntahura', fr: 'Les mots de passe ne correspondent pas'))));
      return;
    }
    setState(() => loading = true);
    try {
      final r = await ApiService.resetPassword(
        email: email.text.trim(),
        code: code.text.trim(),
        password: password.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_clean(r['detail'] ??
              _t('Password updated. You can now sign in.',
                  rw: 'Ijambobanga ryahinduwe. Ushobora kwinjira.',
                  fr: 'Mot de passe mis à jour. Vous pouvez vous connecter.')))));
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(_clean(e))));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext c) {
    final isDark = Theme.of(c).brightness == Brightness.dark;
    final bgColor = isDark ? kDarkScaffold : Colors.white;
    final titleColor = isDark ? kDarkText : kNavy;
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: isDark ? kDarkCard : kNavy,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  AppBackButton(onPress: () => Navigator.pop(c)),
                  const SizedBox(width: 4),
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
                        Text(
                            _t('FORGOT PASSWORD',
                                rw: 'WIBAGIWE IJAMBOBANGA',
                                fr: 'MOT DE PASSE OUBLIÉ'),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                        Text(
                            _t('Recovery code is sent to your email',
                                rw: 'Kode yo kugarura yoherejwe kuri imeyili',
                                fr: 'Le code est envoyé à votre e-mail'),
                            style: const TextStyle(
                                color: Color(0xFF93C5FD), fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _t('Reset your password',
                          rw: 'Hindura ijambobanga',
                          fr: 'Réinitialisez votre mot de passe'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: titleColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sent
                          ? _t(
                              'Enter the code sent to your registered email, then choose a new password.',
                              rw: 'Andika kode yoherejwe kuri imeyili yawe, hanyuma hitamo ijambobanga rishya.',
                              fr: 'Entrez le code envoyé à votre e-mail, puis choisissez un nouveau mot de passe.')
                          : _t(
                              'Enter the email you registered with. We will send a recovery code.',
                              rw: 'Andika imeyili wanditsheho. Tuzohereza kode yo kugarura.',
                              fr: 'Entrez l\'e-mail avec lequel vous vous êtes inscrit. Nous enverrons un code de récupération.'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: isDark ? kDarkTextMuted : kTextGray,
                          fontSize: 14),
                    ),
                    const SizedBox(height: 28),
                    FieldLabel(_t('Email', rw: 'Imeyili', fr: 'E-mail')),
                    const SizedBox(height: 6),
                    FormFieldBox(
                      controller: email,
                      hint: _t('Enter email', rw: 'Andika imeyili', fr: 'Entrez l\'e-mail'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    if (!sent)
                      PrimaryButton(
                        label: loading
                            ? _t('SENDING...', rw: 'KOHEREZA...', fr: 'ENVOI...')
                            : _t('SEND RECOVERY CODE',
                                rw: 'OHEREZA KODE',
                                fr: 'ENVOYER LE CODE'),
                        onPressed: loading ? null : sendCode,
                      ),
                    if (sent) ...[
                      FieldLabel(_t('Recovery code', rw: 'Kode yo kugarura', fr: 'Code de récupération')),
                      const SizedBox(height: 6),
                      FormFieldBox(
                        controller: code,
                        hint: _t('6-digit code', rw: 'Kode y\'imibare 6', fr: 'Code à 6 chiffres'),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      FieldLabel(_t('New password', rw: 'Ijambobanga rishya', fr: 'Nouveau mot de passe')),
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
                      ),
                      const SizedBox(height: 16),
                      FieldLabel(_t('Confirm password', rw: 'Emeza ijambobanga', fr: 'Confirmer le mot de passe')),
                      const SizedBox(height: 6),
                      FormFieldBox(
                        controller: confirm,
                        hint: _t('Enter password', rw: 'Andika ijambobanga', fr: 'Entrez le mot de passe'),
                        obscure: obscure,
                      ),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        label: loading
                            ? _t('SAVING...', rw: 'KUBIKA...', fr: 'ENREGISTREMENT...')
                            : _t('RESET PASSWORD',
                                rw: 'HINDURA IJAMBOBANGA',
                                fr: 'RÉINITIALISER'),
                        onPressed: loading ? null : reset,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: loading ? null : sendCode,
                          child: Text(
                              _t('Resend code',
                                  rw: 'Ongera wohereze kode',
                                  fr: 'Renvoyer le code'),
                              style: const TextStyle(
                                  color: kAccent,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
