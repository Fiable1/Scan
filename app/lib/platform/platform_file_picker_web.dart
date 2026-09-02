import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;

Future<(List<int>, String)?> platformPickImageFile() async {
  final input = web.HTMLInputElement()
    ..type = 'file'
    ..accept = 'image/*';
  input.click();

  await input.onChange.first;
  final files = input.files;
  if (files == null || files.length == 0) return null;

  final file = files.item(0)!;
  final reader = web.FileReader();
  reader.readAsArrayBuffer(file);
  await reader.onLoadEnd.first;

  final arrayBuffer = reader.result as JSArrayBuffer;
  final byteBuffer = arrayBuffer.toDart;
  final uint8List = byteBuffer.asUint8List();
  return (uint8List.toList(), file.name);
}

Future<void> platformDownloadFile(List<int> bytes, String name) async {
  final data = Uint8List.fromList(bytes).buffer.toJS;
  final blob = web.Blob(
    [data].toJS,
    web.BlobPropertyBag(type: 'application/octet-stream'),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = name
    ..style.display = 'none';
  web.document.body!.append(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
}
