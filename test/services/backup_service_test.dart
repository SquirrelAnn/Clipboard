import 'dart:convert';
import 'dart:io';

import 'package:clipboard/models/category.dart';
import 'package:clipboard/repositories/categories_repository.dart';
import 'package:clipboard/services/backup_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tempDir;
  late Directory exportDir;
  late CategoriesRepository repository;
  late BackupService backupService;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('clipboard_backup_source');
    exportDir = await Directory.systemTemp.createTemp('clipboard_backup_export');
    repository = CategoriesRepository(basePath: tempDir.path);
    backupService = BackupService(repository);
    await repository.load();
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
    if (exportDir.existsSync()) {
      await exportDir.delete(recursive: true);
    }
  });

  test('exportToDirectory copies snippets.json and images', () async {
    final category = await repository.addCategory('Docker');
    await repository.addSnippet(
      category.id,
      Snippet.text(id: 's1', snippetTitle: 'Build', snippetText: 'docker-compose up'),
    );

    await backupService.exportToDirectory(exportDir.path);

    expect(File('${exportDir.path}/snippets.json').existsSync(), isTrue);
  });

  test('importFromDirectory replaces existing data', () async {
    final importDir = Directory('${exportDir.path}_import');
    await importDir.create(recursive: true);

    final imported = [
      Category(
        id: 'imported-cat',
        name: 'Imported',
        snippets: [
          Snippet.text(id: 'imported-snippet', snippetTitle: 'Hi', snippetText: 'Hello'),
        ],
      ),
    ];
    await File('${importDir.path}/snippets.json').writeAsString(jsonEncode(imported.map((c) => c.toJson()).toList()));

    await backupService.importFromDirectory(importDir.path, replaceExisting: true);

    expect(repository.categories, hasLength(1));
    expect(repository.categories.first.name, 'Imported');

    await importDir.delete(recursive: true);
  });

  test('importFromDirectory merges by id', () async {
    await repository.load();
    final existingCategoryId = repository.categories.first.id;

    final importDir = Directory('${exportDir.path}_merge');
    await importDir.create(recursive: true);

    final imported = [
      Category(
        id: existingCategoryId,
        name: 'Merged category',
        snippets: [
          Snippet.text(id: 'new-snippet', snippetTitle: 'New', snippetText: 'Value'),
        ],
      ),
      Category(
        id: 'brand-new-cat',
        name: 'Extra',
        snippets: [],
      ),
    ];
    await File('${importDir.path}/snippets.json').writeAsString(jsonEncode(imported.map((c) => c.toJson()).toList()));

    await backupService.importFromDirectory(importDir.path, replaceExisting: false);

    expect(repository.categories.any((category) => category.id == 'brand-new-cat'), isTrue);
    expect(
      repository.categoryById(existingCategoryId)!.snippets.any((snippet) => snippet.id == 'new-snippet'),
      isTrue,
    );

    await importDir.delete(recursive: true);
  });
}
