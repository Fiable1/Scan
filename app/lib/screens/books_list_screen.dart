import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../services/api_service.dart';
import '../models/book_scan.dart';

class BooksListScreen extends StatefulWidget {
  const BooksListScreen({super.key});
  @override
  State<BooksListScreen> createState() => _BooksListScreenState();
}

class _BooksListScreenState extends State<BooksListScreen> {
  List<BookScan> scans = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      scans = await ApiService.scans();
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> download() async {
    final r = await ApiService.excel();
    if (r.statusCode != 200) throw Exception('Excel download failed');
    final dir = await getApplicationDocumentsDirectory();
    final f = File('${dir.path}/rwanda_school_book_scans.xlsx');
    await f.writeAsBytes(r.bodyBytes);
    await OpenFilex.open(f.path);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Excel saved to ${f.path}')));
    }
  }

  @override
  Widget build(BuildContext c) => SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('All Scanned Books'),
            actions: [IconButton(onPressed: download, icon: const Icon(Icons.download))],
          ),
          body: loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: load,
                  child: ListView.builder(
                    itemCount: scans.length,
                    itemBuilder: (c, i) {
                      final s = scans[i];
                      return ListTile(
                        leading: s.coverUrl != null
                            ? Image.network(
                                s.coverUrl!,
                                width: 52,
                                height: 52,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.menu_book),
                              )
                            : const Icon(Icons.menu_book),
                        title: Text(s.title.isEmpty ? s.code : s.title),
                        subtitle: Text('${s.author} • ${s.grade}\n${s.category} • ${s.isbn}'),
                        isThreeLine: true,
                        trailing: Icon(
                          s.matched ? Icons.verified : Icons.help_outline,
                          color: s.matched ? Colors.green : Colors.orange,
                        ),
                      );
                    },
                  ),
                ),
        ),
      );
}