import 'dart:html' as html;
import 'dart:typed_data';

class FileHandleApi {
  static Future<void> saveDocument({
    required String name,
    required Uint8List bytes,
  }) async {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', name)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}
