import 'package:clipboard/models/category.dart';
import 'package:clipboard/repositories/categories_repository.dart';
import 'package:clipboard/services/backup_service.dart';
import 'package:clipboard/services/clipboard_service.dart';
import 'package:clipboard/utils/snippet_search.dart';
import 'package:flutter/foundation.dart' hide Category;

class CategoriesController extends ChangeNotifier {
  CategoriesController(
    this._repository,
    this._clipboardService, {
    BackupService? backupService,
  }) : _backupService = backupService ?? BackupService(_repository);

  final CategoriesRepository _repository;
  final ClipboardService _clipboardService;
  final BackupService _backupService;
  List<Category> _categories = [];
  String? _selectedCategoryId;
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;

  List<Category> get categories => List.unmodifiable(_categories);
  String? get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;
  bool get isSearching => SnippetSearch.isActive(_searchQuery);
  bool get isLoading => _isLoading;
  String? get error => _error;

  CategoriesRepository get repository => _repository;
  ClipboardService get clipboardService => _clipboardService;

  List<Category> get filteredCategories {
    if (!isSearching) {
      return categories;
    }
    return categories.where((category) => SnippetSearch.categoryMatches(category, _searchQuery)).toList();
  }

  List<SnippetSearchResult> get visibleSnippets {
    if (!isSearching) {
      return SnippetSearch.resultsForCategories(
        categories,
        '',
        categoryId: _selectedCategoryId,
      );
    }

    return SnippetSearch.resultsForCategories(categories, _searchQuery);
  }

  Category? get selectedCategory {
    if (_selectedCategoryId == null) {
      return null;
    }
    return _repository.categoryById(_selectedCategoryId!);
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.load();
      _refreshFromRepository();
      _ensureValidSelection();
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

  void setSearchQuery(String query) {
    if (_searchQuery == query) {
      return;
    }
    _searchQuery = query;
    if (isSearching) {
      _ensureSearchSelection();
    }
    notifyListeners();
  }

  void clearSearch() {
    setSearchQuery('');
  }

  void selectCategory(String categoryId) {
    if (_selectedCategoryId == categoryId) {
      return;
    }
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  Future<void> addCategory(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return;
    }

    final category = await _repository.addCategory(trimmed);
    _refreshFromRepository();
    _selectedCategoryId = category.id;
    notifyListeners();
  }

  Future<void> deleteCategory(String categoryId) async {
    await _repository.deleteCategory(categoryId);
    _refreshFromRepository();
    _ensureValidSelection();
    if (isSearching) {
      _ensureSearchSelection();
    }
    notifyListeners();
  }

  Future<void> addSnippet(Snippet snippet) async {
    final categoryId = _selectedCategoryId;
    if (categoryId == null) {
      return;
    }

    await _repository.addSnippet(categoryId, snippet);
    _refreshFromRepository();
    notifyListeners();
  }

  Future<void> updateSnippet(String categoryId, String snippetId, Snippet updated) async {
    await _repository.updateSnippet(categoryId, snippetId, updated);
    _refreshFromRepository();
    notifyListeners();
  }

  Future<void> deleteSnippet(String categoryId, String snippetId) async {
    await _repository.deleteSnippet(categoryId, snippetId);
    _refreshFromRepository();
    notifyListeners();
  }

  Future<void> copySnippet(Snippet snippet) {
    return _clipboardService.copySnippet(snippet);
  }

  Future<void> exportToDirectory(String directoryPath) {
    return _backupService.exportToDirectory(directoryPath);
  }

  Future<void> importFromDirectory(
    String directoryPath, {
    required bool replaceExisting,
  }) async {
    await _backupService.importFromDirectory(
      directoryPath,
      replaceExisting: replaceExisting,
    );
    _refreshFromRepository();
    _ensureValidSelection();
    if (isSearching) {
      _ensureSearchSelection();
    }
    notifyListeners();
  }

  void _refreshFromRepository() {
    _categories = _repository.categories;
  }

  void _ensureValidSelection() {
    if (_categories.isEmpty) {
      _selectedCategoryId = null;
      return;
    }

    final stillExists = _categories.any((category) => category.id == _selectedCategoryId);
    if (!stillExists) {
      _selectedCategoryId = _categories.first.id;
    }
  }

  void _ensureSearchSelection() {
    if (_categories.isEmpty) {
      _selectedCategoryId = null;
      return;
    }

    final filtered = filteredCategories;
    if (filtered.isEmpty) {
      return;
    }

    final selectedStillVisible = filtered.any((category) => category.id == _selectedCategoryId);
    if (!selectedStillVisible) {
      _selectedCategoryId = filtered.first.id;
    }
  }
}
