import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ImageStorageService {
  ImageStorageService({String? basePath}) : _basePath = basePath;

  final String? _basePath;

  Future<String> get _imagesDirectory async {
    final base = _basePath ?? (await getApplicationDocumentsDirectory()).path;
    final dir = Directory(p.join(base, 'images'));
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  Future<String> saveImage(Uint8List bytes, String snippetId) async {
    final dir = await _imagesDirectory;
    final relativePath = p.join('images', '$snippetId.png');
    final file = File(p.join(dir, '$snippetId.png'));
    await file.writeAsBytes(bytes);
    return relativePath;
  }

  Future<Uint8List?> loadImage(String relativePath) async {
    final file = await _resolveFile(relativePath);
    if (!file.existsSync()) {
      return null;
    }
    return file.readAsBytes();
  }

  Future<void> deleteImage(String relativePath) async {
    final file = await _resolveFile(relativePath);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  Future<File> resolveFile(String relativePath) => _resolveFile(relativePath);

  Future<File> _resolveFile(String relativePath) async {
    final base = _basePath ?? (await getApplicationDocumentsDirectory()).path;
    return File(p.join(base, relativePath));
  }
}
