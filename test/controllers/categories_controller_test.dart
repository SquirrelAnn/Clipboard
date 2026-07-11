import 'dart:io';

import 'package:clipboard/controllers/categories_controller.dart';
import 'package:clipboard/models/category.dart';
import 'package:clipboard/repositories/categories_repository.dart';
import 'package:clipboard/services/clipboard_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tempDir;
  late CategoriesRepository repository;
  late CategoriesController controller;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('clipboard_controller_test');
    repository = CategoriesRepository(basePath: tempDir.path);
    controller = CategoriesController(
      repository,
      ClipboardService(imageStorageService: repository.imageStorageService),
    );
  });

  tearDown(() async {
    controller.dispose();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('load selects first category', () async {
    await controller.load();

    expect(controller.categories, isNotEmpty);
    expect(controller.selectedCategoryId, controller.categories.first.id);
    expect(controller.error, isNull);
  });

  test('addCategory selects new category', () async {
    await controller.load();

    await controller.addCategory('Projects');

    expect(controller.categories.any((category) => category.name == 'Projects'), isTrue);
    expect(controller.selectedCategory?.name, 'Projects');
  });

  test('deleteCategory updates selection', () async {
    await controller.load();
    final firstId = controller.selectedCategoryId!;

    await controller.addCategory('Temporary');
    await controller.deleteCategory(firstId);

    expect(controller.categories.any((category) => category.id == firstId), isFalse);
    expect(controller.selectedCategoryId, isNotNull);
  });

  test('addSnippet adds to selected category', () async {
    await controller.load();
    final categoryId = controller.selectedCategoryId!;

    await controller.addSnippet(
      Snippet.text(id: 's1', snippetTitle: 'Title', snippetText: 'Value'),
    );

    final category = repository.categoryById(categoryId)!;
    expect(category.snippets.any((snippet) => snippet.snippetText == 'Value'), isTrue);
  });

  test('updateSnippet updates existing snippet', () async {
    await controller.load();
    final categoryId = controller.selectedCategoryId!;
    final snippetId = controller.selectedCategory!.snippets.first.id;

    await controller.updateSnippet(
      categoryId,
      snippetId,
      Snippet.text(
        id: snippetId,
        snippetTitle: 'Updated',
        snippetText: 'New value',
      ),
    );

    final snippet = repository.categoryById(categoryId)!.snippets.firstWhere((s) => s.id == snippetId);
    expect(snippet.snippetTitle, 'Updated');
    expect(snippet.snippetText, 'New value');
  });

  test('setSearchQuery filters visible snippets globally', () async {
    await controller.load();
    await controller.addCategory('Docker');
    await controller.addSnippet(
      Snippet.text(id: 's2', snippetTitle: 'Build', snippetText: 'docker-compose up --build'),
    );

    controller.setSearchQuery('compose');

    expect(controller.isSearching, isTrue);
    expect(controller.filteredCategories.any((category) => category.name == 'Docker'), isTrue);
    expect(
      controller.visibleSnippets.any((result) => result.snippet.snippetText?.contains('compose') ?? false),
      isTrue,
    );
  });

  test('clearSearch restores normal snippet view', () async {
    await controller.load();

    controller.setSearchQuery('missing');
    controller.clearSearch();

    expect(controller.isSearching, isFalse);
    expect(controller.visibleSnippets, isNotEmpty);
  });
}
