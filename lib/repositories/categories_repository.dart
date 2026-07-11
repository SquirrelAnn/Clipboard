import 'dart:convert';
import 'dart:io';

import 'package:clipboard/models/category.dart';
import 'package:clipboard/services/image_storage_service.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class StorageException implements Exception {
  StorageException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CategoriesRepository {
  CategoriesRepository({
    String? basePath,
    ImageStorageService? imageStorageService,
  })  : _basePath = basePath,
        _imageStorageService = imageStorageService ?? ImageStorageService(basePath: basePath);

  final String? _basePath;
  final ImageStorageService _imageStorageService;
  List<Category> _categories = [];

  ImageStorageService get imageStorageService => _imageStorageService;

  Future<String> get storagePath => _localPath;

  Future<List<Category>> load() async {
    final file = await _localFile;

    if (!file.existsSync()) {
      _categories = _createInitialCategories();
      await _persist();
    } else {
      _categories = await _readJson(file);
    }

    return categories;
  }

  @Deprecated('Use load() instead')
  Future<List<Category>> readCategoryDatabase() => load();

  List<Category> get categories {
    return List.unmodifiable(
      _categories.map(
        (category) => Category(
          id: category.id,
          name: category.name,
          snippets: List.unmodifiable(category.snippets),
        ),
      ),
    );
  }

  @Deprecated('Use categories instead')
  List<Category> getCategories() => categories;

  Category? categoryById(String id) {
    for (final category in _categories) {
      if (category.id == id) {
        return Category(
          id: category.id,
          name: category.name,
          snippets: List.unmodifiable(category.snippets),
        );
      }
    }
    return null;
  }

  Snippet? snippetById(String categoryId, String snippetId) {
    final category = categoryById(categoryId);
    if (category == null) {
      return null;
    }
    for (final snippet in category.snippets) {
      if (snippet.id == snippetId) {
        return snippet;
      }
    }
    return null;
  }

  Future<Category> addCategory(String name) async {
    const uuid = Uuid();
    final category = Category(id: uuid.v1(), name: name, snippets: []);
    _categories.add(category);
    await _persist();
    return category;
  }

  Future<void> deleteCategory(String categoryId) async {
    final index = _categories.indexWhere((category) => category.id == categoryId);
    if (index == -1) {
      return;
    }

    for (final snippet in _categories[index].snippets) {
      await _deleteSnippetImage(snippet);
    }
    _categories.removeAt(index);
    await _persist();
  }

  Future<void> addSnippet(String categoryId, Snippet snippet) async {
    final category = _findCategory(categoryId);
    category.snippets.add(snippet);
    await _persist();
  }

  Future<void> updateSnippet(String categoryId, String snippetId, Snippet updated) async {
    final category = _findCategory(categoryId);
    final index = category.snippets.indexWhere((snippet) => snippet.id == snippetId);
    if (index == -1) {
      throw StorageException('Snippet not found: $snippetId');
    }

    final previous = category.snippets[index];
    if (previous.type == SnippetType.image &&
        previous.imagePath != null &&
        previous.imagePath != updated.imagePath) {
      await _deleteSnippetImage(previous);
    }

    category.snippets[index] = updated;
    await _persist();
  }

  Future<void> deleteSnippet(String categoryId, String snippetId) async {
    final category = _findCategory(categoryId);
    final index = category.snippets.indexWhere((snippet) => snippet.id == snippetId);
    if (index == -1) {
      return;
    }

    await _deleteSnippetImage(category.snippets[index]);
    category.snippets.removeAt(index);
    await _persist();
  }

  Future<void> replaceAll(List<Category> imported, {String? importImagesDirectory}) async {
    for (final category in _categories) {
      for (final snippet in category.snippets) {
        await _deleteSnippetImage(snippet);
      }
    }

    _categories = imported;
    if (importImagesDirectory != null) {
      await _copyImportImages(importImagesDirectory);
    }
    await _persist();
  }

  Future<void> mergeFrom(List<Category> imported, {String? importImagesDirectory}) async {
    if (importImagesDirectory != null) {
      await _copyImportImages(importImagesDirectory);
    }

    for (final importedCategory in imported) {
      final existingIndex = _categories.indexWhere((category) => category.id == importedCategory.id);
      if (existingIndex == -1) {
        _categories.add(importedCategory);
        continue;
      }

      final existing = _categories[existingIndex];
      for (final importedSnippet in importedCategory.snippets) {
        final snippetExists = existing.snippets.any((snippet) => snippet.id == importedSnippet.id);
        if (!snippetExists) {
          existing.snippets.add(importedSnippet);
        }
      }
    }

    await _persist();
  }

  Category _findCategory(String categoryId) {
    final index = _categories.indexWhere((category) => category.id == categoryId);
    if (index == -1) {
      throw StorageException('Category not found: $categoryId');
    }
    return _categories[index];
  }

  List<Category> _createInitialCategories() {
    const uuid = Uuid();
    final snippet = Snippet.text(
      id: uuid.v1(),
      snippetTitle: 'snippet title',
      snippetText: 'snippet text',
    );
    return [
      Category(
        id: uuid.v1(),
        name: 'Category',
        snippets: [snippet],
      ),
    ];
  }

  Future<void> _persist() async {
    final file = await _localFile;
    final jsonTags = jsonEncode(_categories.map((category) => category.toJson()).toList());
    await file.writeAsString(jsonTags);
  }

  @Deprecated('Use _persist via CRUD methods')
  Future<void> saveCategories() => _persist();

  Future<void> _deleteSnippetImage(Snippet snippet) async {
    if (snippet.type == SnippetType.image && snippet.imagePath != null) {
      await _imageStorageService.deleteImage(snippet.imagePath!);
    }
  }

  Future<void> _copyImportImages(String importImagesDirectory) async {
    final sourceDir = Directory(importImagesDirectory);
    if (!sourceDir.existsSync()) {
      return;
    }

    for (final entity in sourceDir.listSync()) {
      if (entity is! File || !entity.path.toLowerCase().endsWith('.png')) {
        continue;
      }
      final snippetId = p.basenameWithoutExtension(entity.path);
      final bytes = await entity.readAsBytes();
      await _imageStorageService.saveImage(bytes, snippetId);
    }
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File(p.join(path, 'snippets.json'));
  }

  Future<String> get _localPath async {
    return _basePath ?? (await getApplicationDocumentsDirectory()).path;
  }

  Future<List<Category>> _readJson(File file) async {
    try {
      final jsonString = await file.readAsString();
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList.map((json) => Category.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw StorageException('Error reading or parsing JSON: $e');
    }
  }

  static Future<List<Category>> parseCategoriesFile(File file) async {
    try {
      final jsonString = await file.readAsString();
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList.map((json) => Category.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw StorageException('Error reading or parsing JSON: $e');
    }
  }
}
