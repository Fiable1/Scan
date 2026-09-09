import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../services/api_service.dart';
import '../services/app_settings.dart';
import 'login_screen.dart';
import 'home_shell.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const List<String> _rwandaDistricts = [
    'Gasabo', 'Kicukiro', 'Nyarugenge', 'Rwamagana', 'Muhanga',
    'Huye', 'Nyamagabe', 'Gisagara', 'Nyagatare', 'Gatsibo',
    'Kayonza', 'Kirehe', 'Ngoma', 'Bugesera', 'Nyanza',
    'Nyaruguru', 'Ruhango', 'Kamonyi', 'Musanze', 'Burera',
    'Gakenke', 'Gicumbi', 'Rulindo', 'Karongi', 'Ngororero',
    'Nyabihu', 'Rubavu', 'Rusizi', 'Nyamasheke',
  ];

  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final school = TextEditingController();
  final password = TextEditingController();
  List<String> districts = [];
  String? district;
  bool confirm = false;
  bool submitting = false;

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
      final dl = await ApiService.districts();
      if (mounted && dl.isNotEmpty) {
        setState(() => districts = dl);
        return;
      }
    } catch (_) {}
    // Offline / phone-without-network: keep the dropdown usable.
    districts = [..._rwandaDistricts];
    if (mounted) setState(() {});
  }

  Future<void> register() async {
    if (!confirm) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_t('Please confirm you are the school librarian.', rw: 'Nyamuneka emeza ko uri umuyobozi w\'ububiko bw\'ishuri.', fr: 'Veuillez confirmer que vous êtes le bibliothécaire de l\'école.'))));
      return;
    }
    setState(() => submitting = true);
    try {
      final r = await ApiService.register({
        'full_name': name.text,
        'email': email.text,
        'phone': phone.text,
        'password': password.text,
        'district': district,
        'school_name': school.text,
      });
      await ApiService.saveToken(r['token']);
      await persistLibrarian(r);
      if (mounted) {
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (_) => const HomeShell()), (_) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext c) {
    final isDark = Theme.of(c).brightness == Brightness.dark;
    final bgColor = isDark ? kDarkScaffold : Colors.white;
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          Container(
            color: isDark ? kDarkCard : kNavy,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                AppBackButton(onPress: () => Navigator.pop(c)),
                const SizedBox(width: 4),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                      color: kAccent, borderRadius: BorderRadius.circular(7)),
                  child: const Center(
                      child: Icon(Icons.person, color: Colors.white, size: 16)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_t('Librarian Registration', rw: 'Iyandikisha ry\'umuyobozi w\'ububiko', fr: 'Inscription du bibliothécaire'),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                      Text(_t('For Rwandan Schools Only', rw: 'Ibikorwa by\'amashuri y\'u Rwanda Gusa', fr: 'Uniquement pour les écoles rwandaises'),
                          style:
                              const TextStyle(color: Color(0xFF93C5FD), fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FieldLabel(_t('Full Name', rw: 'Amazina yuzuye', fr: 'Nom complet')),
                  const SizedBox(height: 6),
                  FormFieldBox(
                      controller: name, hint: _t('Enter full name', rw: 'Andika amazina yuzuye', fr: 'Entrez le nom complet'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? _t('Required', rw: 'Birakenewe', fr: 'Requis') : null),
                  const SizedBox(height: 16),
                  FieldLabel(_t('Email', rw: 'Imeyili', fr: 'E-mail')),
                  const SizedBox(height: 6),
                  FormFieldBox(
                      controller: email,
                      hint: _t('Enter email', rw: 'Andika imeyili', fr: 'Entrez l\'e-mail'),
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  FieldLabel(_t('Phone Number', rw: 'Nomero ya telefone', fr: 'Numéro de téléphone')),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 15),
                        decoration: BoxDecoration(
                          color: isDark ? kDarkFieldBg : kFieldBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: isDark ? kDarkBorder : kBorderGray),
                        ),
                        child: const Row(
                          children: [
                            Text('🇷🇼', style: TextStyle(fontSize: 16)),
                            SizedBox(width: 6),
                            Text('+250',
                                style: TextStyle(
                                    color: Color(0xFF4B5563),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FormFieldBox(
                            controller: phone,
                            hint: '78 120 4567',
                            keyboardType: TextInputType.phone),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FieldLabel(_t('District', rw: 'Ukarere', fr: 'District')),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark ? kDarkFieldBg : kFieldBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: isDark ? kDarkBorder : kBorderGray),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: district,
                        isExpanded: true,
                        hint: Text(_t('Select district', rw: 'Hitamo akarere', fr: 'Sélectionnez le district'),
                            style: TextStyle(color: kTextGray, fontSize: 14)),
                        items: districts
                            .map((d) => DropdownMenuItem(
                                value: d,
                                child: Text(d,
                                    style: TextStyle(
                                        color: isDark ? kDarkText : const Color(0xFF374151),
                                        fontSize: 14))))
                            .toList(),
                        onChanged: (v) => setState(() => district = v),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FieldLabel(_t('School Name', rw: 'Izina ry\'ishuri', fr: 'Nom de l\'école')),
                  const SizedBox(height: 6),
                  FormFieldBox(
                      controller: school, hint: _t('Enter your school', rw: 'Andika ishuri ryawe', fr: 'Entrez votre école')),
                  const SizedBox(height: 16),
                  FieldLabel(_t('Password', rw: 'Ijambobanga', fr: 'Mot de passe')),
                  const SizedBox(height: 6),
                  FormFieldBox(
                      controller: password,
                      hint: _t('Enter password', rw: 'Andika ijambobanga', fr: 'Entrez le mot de passe'),
                      obscure: true),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => setState(() => confirm = !confirm),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: confirm ? kAccent : Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                                color: confirm ? kAccent : kBorderGray,
                                width: 1.5),
                          ),
                          child: confirm
                              ? const Icon(Icons.check,
                                  size: 14, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _t('I confirm that I am the librarian of the above school', rw: 'Ndemezako ndi umuyobozi w\'ububiko bw\'ishuri ryavuzwe', fr: 'Je confirme que je suis le bibliothécaire de l\'école ci-dessus'),
                            style: TextStyle(
                                color: isDark ? kDarkTextMuted : const Color(0xFF6B7280),
                                fontSize: 12,
                                height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: submitting ? _t('REGISTERING...', rw: 'KUYANDIKISHA...', fr: 'INSCRIPTION...') : _t('REGISTER', rw: 'IYANDIKISHE', fr: 'S\'INSCRIRE'),
                    onPressed: submitting ? null : register,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_t('Already have an account?', rw: 'Ufite konti?', fr: 'Déjà un compte?'),
                          style: TextStyle(
                              color: isDark ? kDarkTextMuted : kTextGray, fontSize: 14)),
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(c, const LoginScreen()),
                        child: Text(_t('Login', rw: 'Injira', fr: 'Connexion'),
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
        ],
      ),
    );
  }
}
