import 'dart:convert';
import 'dart:io';

import 'package:clipboard/models/category.dart';
import 'package:clipboard/repositories/categories_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tempDir;
  late CategoriesRepository repository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('clipboard_repo_test');
    repository = CategoriesRepository(basePath: tempDir.path);
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('creates default database when file is missing', () async {
    final categories = await repository.readCategoryDatabase();

    expect(categories, hasLength(1));
    expect(categories.first.name, 'Category');
    expect(categories.first.snippets, hasLength(1));
    expect(categories.first.snippets.first.type, SnippetType.text);

    final file = File('${tempDir.path}/snippets.json');
    expect(file.existsSync(), isTrue);
  });

  test('persists and reloads categories', () async {
    await repository.readCategoryDatabase();
    final categories = repository.getCategories();
    categories.add(
      Category(
        id: 'cat-2',
        name: 'Notes',
        snippets: [
          Snippet.text(id: 's-1', snippetTitle: 'Note', snippetText: 'Remember'),
        ],
      ),
    );
    await repository.saveCategories();

    final reloaded = CategoriesRepository(basePath: tempDir.path);
    final loaded = await reloaded.readCategoryDatabase();

    expect(loaded, hasLength(2));
    expect(loaded.last.name, 'Notes');
    expect(loaded.last.snippets.first.snippetText, 'Remember');
  });

  test('loads legacy JSON without snippet type', () async {
    final legacy = [
      {
        'id': 'cat-legacy',
        'name': 'Legacy',
        'snippets': [
          {
            'id': 's-legacy',
            'snippetTitle': 'Old',
            'snippetText': 'data',
          },
        ],
      },
    ];
    await File('${tempDir.path}/snippets.json').writeAsString(jsonEncode(legacy));

    final categories = await repository.readCategoryDatabase();

    expect(categories.first.snippets.first.type, SnippetType.text);
    expect(categories.first.snippets.first.snippetText, 'data');
  });
}
