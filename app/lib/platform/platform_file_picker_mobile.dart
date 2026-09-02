import 'dart:io';
import 'package:image_picker/image_picker.dart';

Future<(List<int>, String)?> platformPickImageFile() async {
  final x = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 80);
  if (x == null) return null;
  final file = File(x.path);
  final bytes = await file.readAsBytes();
  return (bytes, x.name);
}

Future<void> platformDownloadFile(List<int> bytes, String name) async {
  final dir = Directory.systemTemp;
  final f = File('${dir.path}/$name');
  await f.writeAsBytes(bytes);
}
