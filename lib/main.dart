import 'package:clipboard/models/category.dart';
import 'package:clipboard/pages/categories_overview.dart';
import 'package:clipboard/platform/window_setup.dart'
    if (dart.library.io) 'package:clipboard/platform/window_setup_io.dart';
import 'package:clipboard/repositories/categories_repository.dart';
import 'package:clipboard/services/clipboard_service.dart';
import 'package:clipboard/theme/dark_theme.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
  configureDesktopWindow();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<Category>> _categoriesFuture;
  final CategoriesRepository _categoriesRepository = CategoriesRepository();
  late final ClipboardService _clipboardService = ClipboardService(
    imageStorageService: _categoriesRepository.imageStorageService,
  );

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _categoriesRepository.readCategoryDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clipboard app',
      theme: CustomDarkTheme.darkTheme,
      home: FutureBuilder<List<Category>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')),
            );
          }
          return CategoriesOverview(
            categories: snapshot.data!,
            saveCategories: _saveCategories,
            repository: _categoriesRepository,
            clipboardService: _clipboardService,
          );
        },
      ),
    );
  }

  Future<void> _saveCategories() async {
    await _categoriesRepository.saveCategories();
  }
}
