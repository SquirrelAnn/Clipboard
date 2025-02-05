import 'dart:convert';
import 'dart:io';

import 'package:clipboard/models/category.dart';
import 'package:path_provider/path_provider.dart';

import 'package:uuid/uuid.dart';

class CategoriesRepository {
  readCategoryDatabase() async {
    var file = await _localFile;

    if (!file.existsSync()) {
      List<Category> cats = <Category>[];
      List<Snippet> testSnippets = [];
      var uuid = const Uuid();
      var v1 = uuid.v1();
      Snippet snippet =
          Snippet(id: v1, snippetText: "snippet text", snippetTitle: "snippet title"); // Named parameters!
      testSnippets.add(snippet);
      var cuuid = const Uuid();
      var cv1 = cuuid.v1();
      Category category = Category(id: cv1, name: "Category", snippets: testSnippets); // Named parameters!

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
    final String jsonString = await file.readAsString();
    List<dynamic> jsonList = jsonDecode(jsonString);
    List<Category> categories = jsonList.map((json) => Category.fromJson(json)).toList();
  }
}
