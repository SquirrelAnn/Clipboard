import 'dart:io';

import 'package:clipboard/controllers/categories_controller.dart';
import 'package:clipboard/pages/categories_page.dart';
import 'package:clipboard/repositories/categories_repository.dart';
import 'package:clipboard/services/clipboard_service.dart';
import 'package:clipboard/theme/dark_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late CategoriesRepository repository;
  late CategoriesController controller;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('clipboard_widget_test');
    repository = CategoriesRepository(basePath: tempDir.path);
    controller = CategoriesController(
      repository,
      ClipboardService(imageStorageService: repository.imageStorageService),
    );
    await controller.load();
  });

  tearDown(() async {
    controller.dispose();
    if (tempDir.existsSync()) {
      try {
        await tempDir.delete(recursive: true);
      } on FileSystemException {
        // Temp dir may still be locked briefly on Windows after widget tests.
      }
    }
  });

  Widget buildApp() {
    return MaterialApp(
      theme: CustomDarkTheme.darkTheme,
      home: CategoriesPage(controller: controller),
    );
  }

  testWidgets('shows categories and snippets', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump();

    expect(find.text('Category'), findsOneWidget);
    expect(find.textContaining('snippet title'), findsOneWidget);
  });

  testWidgets('opens add category dialog', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump();

    await tester.tap(find.byKey(const Key('add_category_fab')));
    await tester.pumpAndSettle();

    expect(find.text('Add new category'), findsOneWidget);
    expect(find.byKey(const Key('category_name_field')), findsOneWidget);
  });

  testWidgets('opens add snippet dialog with text and screenshot modes', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump();

    await tester.tap(find.byKey(const Key('add_snippet_fab')));
    await tester.pumpAndSettle();

    expect(find.text('Add new snippet'), findsOneWidget);
    expect(find.text('Text'), findsOneWidget);
    expect(find.text('Screenshot'), findsOneWidget);
    expect(find.text('Paste from clipboard'), findsNothing);

    await tester.tap(find.text('Screenshot'));
    await tester.pumpAndSettle();

    expect(find.text('Paste from clipboard'), findsOneWidget);
  });

  testWidgets('filters snippets when typing in search field', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump();

    tester.testTextInput.register();
    await tester.enterText(find.byKey(const Key('search_field')), 'compose');
    await tester.pump();

    expect(controller.isSearching, isTrue);
    expect(find.textContaining('compose'), findsWidgets);
  });
}
