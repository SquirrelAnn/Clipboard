import 'dart:typed_data';

String contentHashForText(String text) => 't:${text.hashCode}';

String contentHashForImage(Uint8List bytes) => 'i:${Object.hashAll(bytes)}';
