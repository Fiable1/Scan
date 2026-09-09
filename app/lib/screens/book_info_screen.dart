import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../services/api_service.dart';
import '../services/app_settings.dart';
import '../platform/platform_helpers.dart';
import 'save_success_screen.dart';

class BookInfoScreen extends StatefulWidget {
  const BookInfoScreen(
      {super.key, required this.code, this.info = const {}});
  final String code;
  final Map<String, dynamic> info;
  @override
  State<BookInfoScreen> createState() => _BookInfoScreenState();
}

class _BookInfoScreenState extends State<BookInfoScreen> {
  late final Map<String, TextEditingController> ctrls;
  final quantity = TextEditingController(text: '1');
  Uint8List? coverBytes;
  String? coverName;
  bool saving = false;

  String _t(String en, {String? rw, String? fr}) {
    final loc = context.read<AppSettings>().locale;
    if (loc == 'rw' && rw != null) return rw;
    if (loc == 'fr' && fr != null) return fr;
    return en;
  }

  @override
  void initState() {
    super.initState();
    ctrls = {
      for (final k
          in ['title', 'author', 'grade', 'category', 'publisher', 'language'])
        k: TextEditingController(text: widget.info[k]?.toString() ?? '')
    };
  }

  @override
  void dispose() {
    for (final v in ctrls.values) {
      v.dispose();
    }
    quantity.dispose();
    super.dispose();
  }

  String get isbn =>
      widget.info['isbn']?.toString().isNotEmpty == true
          ? widget.info['isbn'].toString()
          : widget.code;

  String get title => ctrls['title']!.text.isNotEmpty
      ? ctrls['title']!.text
      : 'Untitled Book';
  String get category => ctrls['category']!.text;

  Future<void> pickCover() async {
    final result = await pickImageFile();
    if (result != null) {
      setState(() {
        coverBytes = Uint8List.fromList(result.$1);
        coverName = result.$2;
      });
    }
  }

  Future<void> save() async {
    // Cover is optional in the save request.
    setState(() => saving = true);
    try {
      final fields = {
        'title': ctrls['title']!.text,
        'author': ctrls['author']!.text,
        'grade': ctrls['grade']!.text,
        'category': ctrls['category']!.text,
        'publisher': ctrls['publisher']!.text,
        'language': ctrls['language']!.text,
        'isbn': isbn,
      };
      if (coverBytes != null) {
        await ApiService.saveScan(
            code: widget.code,
            coverBytes: coverBytes!.toList(),
            coverName: coverName ?? 'cover.jpg',
            fields: fields);
      } else {
        await ApiService.saveScanNoCover(code: widget.code, fields: fields);
      }
      if (mounted) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => SaveSuccessScreen(info: fields)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Color get _cover => coverColor('$category ${title}');

  @override
  Widget build(BuildContext c) {
    final isDark = Theme.of(c).brightness == Brightness.dark;
    final cardColor = isDark ? kDarkCard : Colors.white;
    final border = isDark ? kDarkBorder : const Color(0xFFF3F4F6);
    final titleColor = isDark ? kDarkText : kNavy;
    return Scaffold(
      backgroundColor: isDark ? kDarkScaffold : kBg,
      body: Column(
        children: [
          AppHeaderBar(
            leading: AppBackButton(onPress: () => Navigator.pop(c)),
            title: _t('Book Information', rw: 'Amakuru y\'igitabo', fr: 'Informations sur le livre'),
            subtitle: _t('Auto Filled from Barcode', rw: 'Byuzuyemo ku buryo bwikora', fr: 'Rempli automatiquement depuis le code-barres'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.circle, size: 6, color: Color(0xFF4ADE80)),
                  const SizedBox(width: 4),
                  Text(_t('Auto', rw: 'Auto', fr: 'Auto'),
                      style: const TextStyle(
                          color: Color(0xFF86EFAC),
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
          if (coverBytes != null)
            Container(
              height: 180,
              width: double.infinity,
              color: Colors.black,
              child: Image.memory(coverBytes!, fit: BoxFit.cover),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header row: cover mock + info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CoverMock(color: _cover, title: title),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: titleColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    height: 1.3)),
                            const SizedBox(height: 6),
                            Text('ISBN: $isbn',
                                style: const TextStyle(
                                    color: kTextGray, fontSize: 12)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                if (category.isNotEmpty)
                                  _Tag(category,
                                      bg: const Color(0xFFDBEAFE),
                                      fg: kAccent),
                                if (ctrls['grade']!.text.isNotEmpty)
                                  _Tag(ctrls['grade']!.text,
                                      bg: isDark
                                          ? const Color(0xFF374151)
                                          : const Color(0xFFF3F4F6),
                                      fg: isDark
                                          ? kDarkTextMuted
                                          : const Color(0xFF6B7280)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // cover picker
                  OutlinedButton.icon(
                    onPressed: pickCover,
                    icon: const Icon(Icons.add_photo_alternate_outlined,
                        color: kAccent, size: 20),
                    label: Text(
                        coverBytes == null
                            ? _t('Add cover photo', rw: 'Ongeraho ifoto y\'igifuniko', fr: 'Ajouter une photo de couverture')
                            : _t('Change cover photo', rw: 'Hindura ifoto y\'igifuniko', fr: 'Changer la photo de couverture'),
                        style: const TextStyle(color: kAccent)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: kAccent),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Editable fields card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _fieldRows(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Quantity + Condition grid
                  Row(
                    children: [
                      Expanded(
                          child: _labelBlock(
                              _t('Quantity', rw: 'Umubare', fr: 'Quantité'), FormFieldBox(controller: quantity, hint: _t('1', rw: '1', fr: '1')))),
                      const SizedBox(width: 12),
                      Expanded(child: _labelBlock(_t('Condition', rw: 'Uko bimeze', fr: 'Condition'), _conditionBox())),
                    ],
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: saving ? _t('SAVING...', rw: 'KUBIKA...', fr: 'ENREGISTREMENT...') : _t('SAVE BOOK', rw: 'BUKA IGITABO', fr: 'ENREGISTRER LIVRE'),
                    onPressed: saving ? null : save,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _fieldRows() => _fieldKeys
      .asMap()
      .entries
      .map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FieldLabel(_fieldLabels[e.key]),
                const SizedBox(height: 6),
                FormFieldBox(controller: ctrls[_fieldKeys[e.key]]!),
              ],
            ),
          ))
      .toList();

  Widget _labelBlock(String label, Widget child) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [FieldLabel(label), const SizedBox(height: 6), child],
      );

  Widget _conditionBox() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: isDark ? kDarkFieldBg : kFieldBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? kDarkBorder : kBorderGray),
      ),
      child: Text(_t('Good', rw: 'Nibyiza', fr: 'Bon'),
          style: TextStyle(
              color: isDark ? kDarkText : const Color(0xFF374151), fontSize: 14)),
    );
  }
}

const List<String> _fieldKeys = [
  'title', 'author', 'grade', 'category', 'publisher', 'language'
];
const List<String> _fieldLabels = [
  'Book Title', 'Author', 'Grade', 'Category', 'Publisher', 'Language'
];

class _Tag extends StatelessWidget {
  final String text;
  final Color bg, fg;
  const _Tag(this.text, {required this.bg, required this.fg});
  @override
  Widget build(BuildContext c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text(text,
            style: TextStyle(
                color: fg, fontSize: 11, fontWeight: FontWeight.w500)),
      );
}

class _CoverMock extends StatelessWidget {
  final Color color;
  final String title;
  const _CoverMock({required this.color, required this.title});
  @override
  Widget build(BuildContext c) => Container(
        width: 80,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(9),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6)],
        ),
        child: AspectRatio(
          aspectRatio: 2 / 3,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.split(' ').take(2).join(' ').toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Color(0xFF93C5FD),
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5),
                ),
                const Spacer(),
                Center(
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration:
                        const BoxDecoration(color: Color(0xFFFDE68A), shape: BoxShape.circle),
                    child: const Center(
                      child: Text('6',
                          style: TextStyle(
                              color: Color(0xFF1a3a6b),
                              fontSize: 16,
                              fontWeight: FontWeight.w900)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}