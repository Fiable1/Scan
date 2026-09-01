import 'package:flutter/material.dart';
import '../main.dart';
import '../services/api_service.dart';
import 'scan_screen.dart';
import 'books_list_screen.dart';
import 'analytics_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int tab = 0;
  @override
  Widget build(BuildContext c) {
    final pages = [
      const Dashboard(),
      const BooksListScreen(),
      const ScanScreen(),
      const AnalyticsScreen(),
      const SettingsScreen(),
    ];
    return Scaffold(
      body: pages[tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (v) => setState(() => tab = v),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.library_books_outlined), label: 'Books'),
          NavigationDestination(
              icon: Icon(Icons.document_scanner_outlined),
              selectedIcon: Icon(Icons.document_scanner),
              label: 'Scan'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), label: 'Analytics'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Map<String, dynamic>? data;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      data = await ApiService.analytics();
      if (mounted) setState(() {});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext c) => SafeArea(
        child: RefreshIndicator(
          onRefresh: load,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Dashboard',
                style: Theme.of(c)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold, color: primaryBlue),
              ),
              const SizedBox(height: 8),
              const Text('Track every physical book scanned by your school.'),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _Stat('Total books', (data?['total_books']?.toString() ?? '—'), Icons.menu_book),
                  _Stat('Today', (data?['today']?.toString() ?? '—'), Icons.today),
                  _Stat('Matched', (data?['matched']?.toString() ?? '—'), Icons.verified),
                  _Stat('Need review', (data?['unmatched']?.toString() ?? '—'), Icons.warning_amber),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => Navigator.of(c)
                    .push(MaterialPageRoute(builder: (_) => const ScanScreen())),
                icon: const Icon(Icons.qr_code_scanner),
                label: const Padding(
                    padding: EdgeInsets.all(14), child: Text('SCAN A BOOK')),
              ),
            ],
          ),
        ),
      );
}

class _Stat extends StatelessWidget {
  final String a, b;
  final IconData i;
  const _Stat(this.a, this.b, this.i);
  @override
  Widget build(BuildContext c) => SizedBox(
        width: 170,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(i, color: primaryBlue),
                const SizedBox(height: 10),
                Text(
                  b,
                  style: Theme.of(c)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(a),
              ],
            ),
          ),
        ),
      );
}