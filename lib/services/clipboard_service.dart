import 'dart:async';
import 'dart:typed_data';

import 'package:clipboard/models/category.dart';
import 'package:clipboard/models/recent_item.dart';
import 'package:clipboard/services/image_storage_service.dart';
import 'package:flutter/services.dart';
import 'package:super_clipboard/super_clipboard.dart';

class ClipboardContent {
  const ClipboardContent._({this.text, this.imageBytes});

  factory ClipboardContent.text(String text) => ClipboardContent._(text: text);

  factory ClipboardContent.image(Uint8List bytes) => ClipboardContent._(imageBytes: bytes);

  final String? text;
  final Uint8List? imageBytes;

  bool get isEmpty {
    final value = text?.trim();
    if (value != null && value.isNotEmpty) {
      return false;
    }
    return imageBytes == null || imageBytes!.isEmpty;
  }
}

class ClipboardService {
  ClipboardService({ImageStorageService? imageStorageService})
      : _imageStorageService = imageStorageService ?? ImageStorageService();

  final ImageStorageService _imageStorageService;
  bool ignoreNextClipboardChange = false;

  Future<void> copySnippet(Snippet snippet) async {
    ignoreNextClipboardChange = true;
    switch (snippet.type) {
      case SnippetType.text:
        await Clipboard.setData(ClipboardData(text: snippet.snippetText ?? ''));
      case SnippetType.image:
        final bytes = await _imageStorageService.loadImage(snippet.imagePath!);
        if (bytes == null) {
          throw StateError('Image file not found for snippet ${snippet.id}');
        }
        await _copyImageToClipboard(bytes);
    }
  }

  Future<void> copyRecentItem(RecentItem item) async {
    ignoreNextClipboardChange = true;
    switch (item.type) {
      case RecentItemType.text:
        await Clipboard.setData(ClipboardData(text: item.text ?? ''));
      case RecentItemType.image:
        final bytes = await _imageStorageService.loadImage(item.imagePath!);
        if (bytes == null) {
          throw StateError('Image file not found for recent item ${item.id}');
        }
        await _copyImageToClipboard(bytes);
    }
  }

  Future<bool> hasImageInClipboard() async {
    final clipboard = SystemClipboard.instance;
    if (clipboard == null) {
      return false;
    }
    final reader = await clipboard.read();
    return reader.canProvide(Formats.png);
  }

  Future<Uint8List?> readImageFromClipboard() async {
    final clipboard = SystemClipboard.instance;
    if (clipboard == null) {
      return null;
    }
    final reader = await clipboard.read();
    if (!reader.canProvide(Formats.png)) {
      return null;
    }
    return _readClipboardFile(reader, Formats.png);
  }

  Future<String?> readTextFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    final text = data?.text?.trim();
    if (text == null || text.isEmpty) {
      return null;
    }
    return text;
  }

  Future<ClipboardContent?> readCurrentClipboard() async {
    if (await hasImageInClipboard()) {
      final bytes = await readImageFromClipboard();
      if (bytes != null && bytes.isNotEmpty) {
        return ClipboardContent.image(bytes);
      }
    }

    final text = await readTextFromClipboard();
    if (text != null) {
      return ClipboardContent.text(text);
    }

    return null;
  }

  Future<Uint8List?> _readClipboardFile(DataReader reader, FileFormat format) async {
    final completer = Completer<Uint8List?>();
    final progress = reader.getFile(
      format,
      (file) async {
        try {
          completer.complete(await file.readAll());
        } catch (e) {
          completer.completeError(e);
        }
      },
      onError: completer.completeError,
    );
    if (progress == null) {
      return null;
    }
    return completer.future;
  }

  Future<void> _copyImageToClipboard(Uint8List pngBytes) async {
    final clipboard = SystemClipboard.instance;
    if (clipboard == null) {
      throw UnsupportedError('Image clipboard is not available on this platform.');
    }
    final item = DataWriterItem();
    item.add(Formats.png(pngBytes));
    await clipboard.write([item]);
  }
}
