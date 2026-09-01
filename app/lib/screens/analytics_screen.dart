import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});
  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  Map<String, dynamic>? d;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      d = await ApiService.analytics();
    } catch (_) {}
    if (mounted) setState(() {});
  }

  Widget section(String title, List<dynamic> rows) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ...rows.map((e) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text((e['grade'] ?? e['category'] ?? 'Not specified').toString()),
                trailing: Text('${e['total']} books'))),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext c) => SafeArea(
        child: RefreshIndicator(
          onRefresh: load,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Analytics',
                style: Theme.of(c)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (d == null)
                const Center(child: CircularProgressIndicator())
              else ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text('${d!['total_books']}',
                            style: Theme.of(c).textTheme.displaySmall),
                        const Text('Individual physical books scanned'),
                      ],
                    ),
                  ),
                ),
                section('Books by Grade', List<dynamic>.from(d!['by_grade'] ?? [])),
                section('Books by Category', List<dynamic>.from(d!['by_category'] ?? [])),
              ],
            ],
          ),
        ),
      );
}