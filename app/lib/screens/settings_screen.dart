import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final url = TextEditingController();
  bool online = false;

  @override
  void initState() {
    super.initState();
    ApiService.baseUrl().then((v) => setState(() => url.text = v));
  }

  Future<void> test() async {
    await ApiService.setBaseUrl(url.text);
    final ok = await ApiService.testConnection();
    setState(() => online = ok);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ok ? 'Backend connection successful' : 'Could not connect to backend')));
    }
  }

  @override
  Widget build(BuildContext c) => SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Settings', style: Theme.of(c).textTheme.headlineMedium),
            const SizedBox(height: 20),
            TextField(
              controller: url,
              decoration: const InputDecoration(
                  labelText: 'Backend URL',
                  hintText: 'http://10.0.2.2:8000',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: test,
              icon: Icon(online ? Icons.check_circle : Icons.wifi),
              label: const Text('TEST CONNECTION'),
            ),
            const Divider(height: 40),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              onTap: () async {
                await ApiService.logout();
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                      context, MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (_) => false);
                }
              },
            ),
          ],
        ),
      );
}