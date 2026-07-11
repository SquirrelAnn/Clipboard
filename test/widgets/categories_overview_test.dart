import 'dart:io';

import 'package:clipboard/models/category.dart';
import 'package:clipboard/pages/categories_overview.dart';
import 'package:clipboard/repositories/categories_repository.dart';
import 'package:clipboard/services/clipboard_service.dart';
import 'package:clipboard/theme/dark_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<Category> categories;
  late CategoriesRepository repository;
  var saveCount = 0;

  Future<void> saveCategories() async {
    saveCount++;
    await repository.saveCategories();
  }

  Widget buildApp() {
    return MaterialApp(
      theme: CustomDarkTheme.darkTheme,
      home: CategoriesOverview(
        categories: categories,
        saveCategories: saveCategories,
        repository: repository,
        clipboardService: ClipboardService(
          imageStorageService: repository.imageStorageService,
        ),
      ),
    );
  }

  late Directory tempDir;

  setUp(() async {
    saveCount = 0;
    tempDir = await Directory.systemTemp.createTemp('clipboard_widget_test');
    repository = CategoriesRepository(basePath: tempDir.path);
    categories = await repository.readCategoryDatabase();
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      try {
        await tempDir.delete(recursive: true);
      } on FileSystemException {
        // Temp dir may still be locked briefly on Windows after widget tests.
      }
    }
  });

  testWidgets('shows categories and snippets', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Category'), findsOneWidget);
    expect(find.textContaining('snippet title'), findsOneWidget);
  });

  testWidgets('adds a category and refreshes list', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(categories.length, 1);

    await tester.tap(find.byTooltip('Add new category'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('category_name_field')), findsOneWidget);

    tester.testTextInput.register();
    await tester.enterText(find.byType(EditableText), 'Projects');
    await tester.tap(find.widgetWithText(TextButton, 'OK'));
    await tester.pumpAndSettle();

    expect(categories.length, 2);
    expect(categories.any((category) => category.name == 'Projects'), isTrue);
    expect(saveCount, greaterThan(0));
  });

  testWidgets('opens add snippet dialog with text and screenshot modes', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Add snippet'));
    await tester.pumpAndSettle();

    expect(find.text('Add new snippet'), findsOneWidget);
    expect(find.text('Text'), findsOneWidget);
    expect(find.text('Screenshot'), findsOneWidget);
    expect(find.text('Paste from clipboard'), findsNothing);

    await tester.tap(find.text('Screenshot'));
    await tester.pumpAndSettle();

    expect(find.text('Paste from clipboard'), findsOneWidget);
  });
}
