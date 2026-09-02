import 'platform_file_picker.dart'
    if (dart.library.io) 'platform_file_picker_mobile.dart'
    if (dart.library.js_interop) 'platform_file_picker_web.dart';

Future<(List<int>, String)?> pickImageFile() => platformPickImageFile();
Future<void> downloadFile(List<int> bytes, String name) => platformDownloadFile(bytes, name);
