import 'dart:convert';
import 'dart:io';
import 'package:clipboard/models/category.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class CategoriesRepository {
  List<Category> _categories = []; // Private list

  Future<List<Category>> readCategoryDatabase() async {
    var file = await _localFile;

    if (!file.existsSync()) {
      // Initialize with default data *and* update _categories
      _categories = _createInitialCategories(); // Use a helper function
      await saveCategories(); // Save the initial data
    } else {
      _categories = await readJson(file); // Load from file and update _categories
    }

    return _categories; // Return the updated list
  }

  List<Category> _createInitialCategories() {
    List<Category> cats = <Category>[];
    List<Snippet> testSnippets = [];
    var uuid = const Uuid();
    var v1 = uuid.v1();
    Snippet snippet = Snippet(
        id: v1, snippetText: "snippet text", snippetTitle: "snippet title");
    testSnippets.add(snippet);
    var cuuid = const Uuid();
    var cv1 = cuuid.v1();
    Category category =
        Category(id: cv1, name: "Category", snippets: testSnippets);
    cats.add(category);
    return cats;
  }


  Future<void> saveCategories() async {
    var file = await _localFile;
    String jsonTags = jsonEncode(_categories); // Encode the correct list
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

  List<Category> getCategories() {
    return _categories; // Return the private list
  }

  Future<List<Category>> readJson(File file) async {
    try {
      String jsonString = await file.readAsString();
      List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Category.fromJson(json)).toList();
    } catch (e) {
      print('Error reading or parsing JSON: $e');
      return [];
    }
  }
}