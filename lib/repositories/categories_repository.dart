import 'dart:convert';
import 'dart:io';

import 'package:clipboard/models/category.dart';
import 'package:path_provider/path_provider.dart';

class CategoriesRepository {
  readCategoryDatabase() async {
    var file = await _localFile;

    if (!file.existsSync()) {
      List<Category> cats = <Category>[];
      List<String> testSnippets = [];
      testSnippets.add("snippet text");
      Category category = Category("Category", testSnippets);
      cats.add(category);
      String jsonTags = jsonEncode(cats);
      await file.writeAsString(jsonTags);
    }

    await readJson(file);
  }

  saveCategories() async {
    var file = await _localFile;
    String jsonTags = jsonEncode(categories);
    await file.writeAsString(jsonTags);
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/snippets.json');
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  static List<Category> categories = <Category>[];
  Map<String, dynamic> map = {};

  getCategories() {
    return categories;
  }

  static readJson(File file) async {
    final String response = await file.readAsString();
    final map = await json.decode(response);
    categories = (json.decode(response) as List)
        .map((i) => Category.fromJson(i))
        .toList();
  }
}
