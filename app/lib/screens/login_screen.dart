import 'package:flutter/material.dart';
import '../main.dart';
import '../services/api_service.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;

  Future<void> go() async {
    setState(() => loading = true);
    try {
      final r = await ApiService.login(email.text.trim(), password.text);
      await ApiService.saveToken(r['token']);
      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.menu_book_rounded, size: 72, color: primaryBlue),
                    const SizedBox(height: 16),
                    Text(
                      'Rwanda School\nBook Scanner',
                      textAlign: TextAlign.center,
                      style: Theme.of(c)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold, color: primaryBlue),
                    ),
                    const SizedBox(height: 8),
                    const Text('Sign in to your librarian account', textAlign: TextAlign.center),
                    const SizedBox(height: 28),
                    TextField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          labelText: 'Email', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: password,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: 'Password', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 22),
                    FilledButton(
                      onPressed: loading ? null : go,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Text(loading ? 'SIGNING IN...' : 'LOGIN'),
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.push(c, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                      child: const Text('New librarian? Register for your Rwandan school'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}