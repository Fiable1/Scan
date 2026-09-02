import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'home_shell.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final school = TextEditingController();
  final password = TextEditingController();
  List<String> districts = [];
  String? district;
  bool confirm = false;
  bool submitting = false;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      districts = await ApiService.districts();
      if (mounted) setState(() {});
    } catch (_) {}
  }

  Future<void> register() async {
    if (!confirm) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please confirm you are the school librarian.')));
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            color: kNavy,
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
                    children: const [
                      Text('Librarian Registration',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                      Text('For Rwandan Schools Only',
                          style:
                              TextStyle(color: Color(0xFF93C5FD), fontSize: 12)),
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
                  const FieldLabel('Full Name'),
                  const SizedBox(height: 6),
                  FormFieldBox(
                      controller: name, hint: 'Enter full name',
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null),
                  const SizedBox(height: 16),
                  const FieldLabel('Email'),
                  const SizedBox(height: 6),
                  FormFieldBox(
                      controller: email,
                      hint: 'Enter email',
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  const FieldLabel('Phone Number'),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 15),
                        decoration: BoxDecoration(
                          color: kFieldBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: kBorderGray),
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
                  const FieldLabel('District'),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: kFieldBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kBorderGray),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: district,
                        isExpanded: true,
                        hint: const Text('Select district',
                            style: TextStyle(color: kTextGray, fontSize: 14)),
                        items: districts
                            .map((d) => DropdownMenuItem(
                                value: d,
                                child: Text(d,
                                    style: const TextStyle(
                                        color: Color(0xFF374151),
                                        fontSize: 14))))
                            .toList(),
                        onChanged: (v) => setState(() => district = v),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const FieldLabel('School Name'),
                  const SizedBox(height: 6),
                  FormFieldBox(
                      controller: school, hint: 'Enter your school'),
                  const SizedBox(height: 16),
                  const FieldLabel('Password'),
                  const SizedBox(height: 6),
                  FormFieldBox(
                      controller: password,
                      hint: 'Enter password',
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
                        const Expanded(
                          child: Text(
                            'I confirm that I am the librarian of the above school',
                            style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 12,
                                height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: submitting ? 'REGISTERING...' : 'REGISTER',
                    onPressed: submitting ? null : register,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account?',
                          style: TextStyle(color: kTextGray, fontSize: 14)),
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(c, const LoginScreen()),
                        child: const Text('Login',
                            style: TextStyle(
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
