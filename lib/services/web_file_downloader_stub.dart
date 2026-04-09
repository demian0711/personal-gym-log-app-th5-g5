import 'dart:typed_data';

Future<void> downloadBytes(
  Uint8List bytes,
  String fileName,
  String mimeType,
) async {
  throw UnsupportedError('Web download is only supported on web platform.');
}
