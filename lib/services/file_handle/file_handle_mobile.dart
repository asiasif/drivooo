import 'dart:io';
import 'dart:typed_data';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class FileHandleApi {
  static Future<void> saveDocument({
    required String name,
    required Uint8List bytes,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes);
    await OpenFile.open(file.path);
  }
}
