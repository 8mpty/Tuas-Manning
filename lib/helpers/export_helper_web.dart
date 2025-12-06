import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;

Future<String?> exportFile(Uint8List bytes, String fileName) async {
  final jsArray = [bytes.toJS].toJS;
  final blobOptions = web.BlobPropertyBag(type: 'application/json');
  final blob = web.Blob(jsArray, blobOptions);
  final url = web.URL.createObjectURL(blob);
  
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = url;
  anchor.download = fileName;
  anchor.click();
  
  web.URL.revokeObjectURL(url);
  
  return null;
}