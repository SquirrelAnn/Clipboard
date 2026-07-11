import 'dart:io';
import 'dart:typed_data';

import 'package:clipboard/services/image_storage_service.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tempDir;
  late ImageStorageService service;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('clipboard_images_test');
    service = ImageStorageService(basePath: tempDir.path);
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('saveImage writes PNG and returns relative path', () async {
    final bytes = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47]);

    final relativePath = await service.saveImage(bytes, 'snippet-1');

    expect(p.basename(relativePath), 'snippet-1.png');
    expect(relativePath, contains('images'));
    final file = await service.resolveFile(relativePath);
    expect(file.existsSync(), isTrue);
    expect(await file.readAsBytes(), bytes);
  });

  test('loadImage returns null for missing file', () async {
    final result = await service.loadImage('images/missing.png');
    expect(result, isNull);
  });

  test('deleteImage removes stored file', () async {
    final bytes = Uint8List.fromList([1, 2, 3]);
    final relativePath = await service.saveImage(bytes, 'snippet-2');

    await service.deleteImage(relativePath);

    final file = await service.resolveFile(relativePath);
    expect(file.existsSync(), isFalse);
  });
}
