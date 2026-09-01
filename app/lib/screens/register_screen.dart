import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final password = TextEditingController();
  List<Map<String, dynamic>> schools = [];
  int? school;
  bool loading = true;
  bool submitting = false;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      schools = await ApiService.schools();
    } catch (_) {}
    if (mounted) setState(() => loading = false);
  }

  Future<void> register() async {
    if (school == null) return;
    setState(() => submitting = true);
    try {
      final r = await ApiService.register({
        'full_name': name.text,
        'email': email.text,
        'phone': phone.text,
        'password': password.text,
        'school_id': school,
      });
      await ApiService.saveToken(r['token']);
      if (mounted) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()),
            (_) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(title: const Text('Register Librarian')),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text('For registered Rwandan school librarians only.'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: name,
                    decoration: const InputDecoration(
                        labelText: 'Full name', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: email,
                    decoration: const InputDecoration(
                        labelText: 'Email', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phone,
                    decoration: const InputDecoration(
                        labelText: 'Phone', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: school,
                    items: schools
                        .map((s) => DropdownMenuItem(
                            value: s['id'] as int,
                            child: Text('${s['name']} — ${s['district']}')))
                        .toList(),
                    onChanged: (v) => setState(() => school = v),
                    decoration: const InputDecoration(
                        labelText: 'Rwandan School', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: password,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: 'Password', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 20),
                  CheckboxListTile(
                    value: true,
                    onChanged: null,
                    title:
                        const Text('I confirm that I am the librarian of the selected school.'),
                  ),
                  FilledButton(
                    onPressed: submitting ? null : register,
                    child: Text(submitting ? 'REGISTERING...' : 'REGISTER'),
                  ),
                ],
              ),
      );
}