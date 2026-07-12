import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:clipboard/models/recent_item.dart';
import 'package:clipboard/repositories/categories_repository.dart';
import 'package:clipboard/services/image_storage_service.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class RecentHistoryRepository {
  RecentHistoryRepository({
    String? basePath,
    ImageStorageService? imageStorageService,
    this.maxItems = 20,
  })  : _basePath = basePath,
        _imageStorageService = imageStorageService ?? ImageStorageService(basePath: basePath);

  static const _historyFileName = 'recent_history.json';

  final String? _basePath;
  final ImageStorageService _imageStorageService;
  final int maxItems;
  List<RecentItem> _items = [];

  ImageStorageService get imageStorageService => _imageStorageService;

  List<RecentItem> get items {
    return List.unmodifiable(_items);
  }

  Future<List<RecentItem>> load() async {
    final file = await _localFile;

    if (!file.existsSync()) {
      _items = [];
      return items;
    }

    _items = await _readJson(file);
    return items;
  }

  Future<RecentItem> pushText(String text, {required String contentHash}) async {
    const uuid = Uuid();
    final item = RecentItem(
      id: uuid.v1(),
      type: RecentItemType.text,
      contentHash: contentHash,
      capturedAt: DateTime.now(),
      text: text,
    );
    await _push(item);
    return item;
  }

  Future<RecentItem> pushImage(Uint8List bytes, {required String contentHash}) async {
    const uuid = Uuid();
    final id = uuid.v1();
    final imagePath = await _imageStorageService.saveRecentImage(bytes, id);
    final item = RecentItem(
      id: id,
      type: RecentItemType.image,
      contentHash: contentHash,
      capturedAt: DateTime.now(),
      imagePath: imagePath,
    );
    await _push(item);
    return item;
  }

  Future<void> remove(String id) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) {
      return;
    }

    await _deleteItemImage(_items[index]);
    _items.removeAt(index);
    await _persist();
  }

  Future<void> clear() async {
    for (final item in _items) {
      await _deleteItemImage(item);
    }
    _items = [];
    await _persist();
  }

  Future<void> _push(RecentItem item) async {
    final duplicateIndex = _items.indexWhere((existing) => existing.contentHash == item.contentHash);
    if (duplicateIndex != -1) {
      await _deleteItemImage(_items[duplicateIndex]);
      _items.removeAt(duplicateIndex);
    }

    _items.insert(0, item);

    while (_items.length > maxItems) {
      final evicted = _items.removeLast();
      await _deleteItemImage(evicted);
    }

    await _persist();
  }

  Future<void> _deleteItemImage(RecentItem item) async {
    if (item.type == RecentItemType.image && item.imagePath != null) {
      await _imageStorageService.deleteImage(item.imagePath!);
    }
  }

  Future<void> _persist() async {
    final file = await _localFile;
    final jsonTags = jsonEncode(_items.map((item) => item.toJson()).toList());
    await file.writeAsString(jsonTags);
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File(p.join(path, _historyFileName));
  }

  Future<String> get _localPath async {
    return _basePath ?? (await getApplicationDocumentsDirectory()).path;
  }

  Future<List<RecentItem>> _readJson(File file) async {
    try {
      final jsonString = await file.readAsString();
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList.map((json) => RecentItem.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw StorageException('Error reading or parsing recent history JSON: $e');
    }
  }
}
