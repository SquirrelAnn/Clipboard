import 'package:clipboard/models/category.dart';
import 'package:clipboard/models/recent_item.dart';
import 'package:clipboard/repositories/categories_repository.dart';
import 'package:clipboard/repositories/recent_history_repository.dart';
import 'package:clipboard/services/clipboard_service.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:uuid/uuid.dart';

class RecentController extends ChangeNotifier {
  RecentController(
    this._repository,
    this._clipboardService, {
    CategoriesRepository? categoriesRepository,
  }) : _categoriesRepository = categoriesRepository;

  final RecentHistoryRepository _repository;
  final ClipboardService _clipboardService;
  final CategoriesRepository? _categoriesRepository;

  List<RecentItem> _items = [];
  bool _isLoading = false;
  String? _error;

  List<RecentItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get error => _error;
  RecentHistoryRepository get repository => _repository;
  ClipboardService get clipboardService => _clipboardService;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.load();
      _refreshFromRepository();
    } on StorageException catch (e) {
      _error = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void refreshFromRepository() {
    _refreshFromRepository();
    notifyListeners();
  }

  Future<void> copyItem(RecentItem item) {
    return _clipboardService.copyRecentItem(item);
  }

  Future<void> removeItem(String id) async {
    await _repository.remove(id);
    _refreshFromRepository();
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await _repository.clear();
    _refreshFromRepository();
    notifyListeners();
  }

  Future<Snippet?> saveAsSnippet({
    required RecentItem item,
    required String categoryId,
    required String title,
  }) async {
    final categoriesRepository = _categoriesRepository;
    if (categoriesRepository == null) {
      return null;
    }

    const uuid = Uuid();
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      return null;
    }

    late final Snippet snippet;
    switch (item.type) {
      case RecentItemType.text:
        snippet = Snippet.text(
          id: uuid.v1(),
          snippetTitle: trimmedTitle,
          snippetText: item.text ?? '',
        );
      case RecentItemType.image:
        final bytes = await _repository.imageStorageService.loadImage(item.imagePath!);
        if (bytes == null) {
          throw StateError('Image file not found for recent item ${item.id}');
        }
        final snippetId = uuid.v1();
        final imagePath = await categoriesRepository.imageStorageService.saveImage(bytes, snippetId);
        snippet = Snippet.image(
          id: snippetId,
          snippetTitle: trimmedTitle,
          imagePath: imagePath,
        );
    }

    await categoriesRepository.addSnippet(categoryId, snippet);
    return snippet;
  }

  void _refreshFromRepository() {
    _items = _repository.items;
  }
}
