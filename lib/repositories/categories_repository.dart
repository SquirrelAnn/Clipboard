import 'dart:convert';
import 'dart:io';

import 'package:clipboard/models/category.dart';
import 'package:clipboard/services/image_storage_service.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class CategoriesRepository {
  CategoriesRepository({
    String? basePath,
    ImageStorageService? imageStorageService,
  })  : _basePath = basePath,
        _imageStorageService = imageStorageService ?? ImageStorageService(basePath: basePath);

  final String? _basePath;
  final ImageStorageService _imageStorageService;
  List<Category> _categories = [];

  Future<List<Category>> readCategoryDatabase() async {
    final file = await _localFile;

    if (!file.existsSync()) {
      _categories = _createInitialCategories();
      await saveCategories();
    } else {
      _categories = await readJson(file);
    }

    return _categories;
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

  Future<void> saveCategories() async {
    final file = await _localFile;
    final jsonTags = jsonEncode(_categories.map((c) => c.toJson()).toList());
    await file.writeAsString(jsonTags);
  }

  Future<void> deleteSnippetImage(Snippet snippet) async {
    if (snippet.type == SnippetType.image && snippet.imagePath != null) {
      await _imageStorageService.deleteImage(snippet.imagePath!);
    }
  }

  ImageStorageService get imageStorageService => _imageStorageService;

  Future<File> get _localFile async {
    final path = await _localPath;
    return File(p.join(path, 'snippets.json'));
  }

  Future<String> get _localPath async {
    return _basePath ?? (await getApplicationDocumentsDirectory()).path;
  }

  List<Category> getCategories() => _categories;

  Future<List<Category>> readJson(File file) async {
    try {
      final jsonString = await file.readAsString();
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList.map((json) => Category.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      // ignore: avoid_print
      print('Error reading or parsing JSON: $e');
      return [];
    }
  }
}
