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
    final categories = await repository.load();

    expect(categories, hasLength(1));
    expect(categories.first.name, 'Category');
    expect(categories.first.snippets, hasLength(1));
    expect(categories.first.snippets.first.type, SnippetType.text);

    final file = File('${tempDir.path}/snippets.json');
    expect(file.existsSync(), isTrue);
  });

  test('addCategory persists and reloads', () async {
    await repository.load();
    await repository.addCategory('Notes');

    final reloaded = CategoriesRepository(basePath: tempDir.path);
    final loaded = await reloaded.load();

    expect(loaded, hasLength(2));
    expect(loaded.any((category) => category.name == 'Notes'), isTrue);
  });

  test('addSnippet and deleteSnippet persist changes', () async {
    await repository.load();
    final categoryId = repository.categories.first.id;

    final snippet = Snippet.text(
      id: 'snippet-1',
      snippetTitle: 'Greeting',
      snippetText: 'Hello',
    );
    await repository.addSnippet(categoryId, snippet);
    expect(repository.categories.first.snippets, hasLength(2));

    await repository.deleteSnippet(categoryId, snippet.id);
    expect(repository.categories.first.snippets, hasLength(1));
  });

  test('updateSnippet changes text snippet content', () async {
    await repository.load();
    final categoryId = repository.categories.first.id;
    final snippetId = repository.categories.first.snippets.first.id;

    await repository.updateSnippet(
      categoryId,
      snippetId,
      Snippet.text(
        id: snippetId,
        snippetTitle: 'Updated title',
        snippetText: 'Updated text',
      ),
    );

    final snippet = repository.categoryById(categoryId)!.snippets.first;
    expect(snippet.snippetTitle, 'Updated title');
    expect(snippet.snippetText, 'Updated text');
  });

  test('deleteCategory removes category and its snippets', () async {
    await repository.load();
    final categoryId = repository.categories.first.id;

    await repository.deleteCategory(categoryId);

    expect(repository.categories, isEmpty);
  });

  test('throws StorageException on invalid JSON', () async {
    await File('${tempDir.path}/snippets.json').writeAsString('{ invalid json');

    expect(repository.load(), throwsA(isA<StorageException>()));
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

    final categories = await repository.load();

    expect(categories.first.snippets.first.type, SnippetType.text);
    expect(categories.first.snippets.first.snippetText, 'data');
  });
}
