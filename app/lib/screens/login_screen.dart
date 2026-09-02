import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/api_service.dart';
import 'register_screen.dart';
import 'home_shell.dart';

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Dark header block
          Container(
            color: kNavy,
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
                    children: const [
                      Text('RWANDA SCHOOL BOOK SCANNER',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                      Text('Digital Library Management',
                          style:
                              TextStyle(color: Color(0xFF93C5FD), fontSize: 12)),
                    ],
                  ),
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
                    const Text(
                      'Welcome Back!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: kNavy,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Sign in to your librarian account',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(color: kTextGray, fontSize: 14),
                    ),
                    const SizedBox(height: 28),
                    const FieldLabel('Email or Phone'),
                    const SizedBox(height: 6),
                    FormFieldBox(
                      controller: email,
                      hint: 'Enter email or phone',
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Required'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    const FieldLabel('Password'),
                    const SizedBox(height: 6),
                    FormFieldBox(
                      controller: password,
                      hint: 'Enter password',
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
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text('Forgot password?',
                            style: TextStyle(
                                color: kAccent,
                                fontWeight: FontWeight.w500,
                                fontSize: 12)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    PrimaryButton(
                      label: loading ? 'SIGNING IN...' : 'LOGIN',
                      onPressed: loading ? null : go,
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Don\'t have an account?',
                            style:
                                TextStyle(color: kTextGray, fontSize: 14)),
                        TextButton(
                          onPressed: () =>
                              Navigator.push(c,
                                  MaterialPageRoute(
                                      builder: (_) => const RegisterScreen())),
                          child: const Text('Register as a Librarian',
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
          ),
        ],
      ),
    );
  }
}
