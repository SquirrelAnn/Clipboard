import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:clipboard/models/category.dart';
import 'package:clipboard/pages/categories_overview.dart';
import 'package:clipboard/repositories/categories_repository.dart';
import 'package:clipboard/theme/dark_theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());

  doWhenWindowReady(() {
    final win = appWindow;
    const initialSize = Size(1200, 600);
    const maxSize = Size(1200, 1200);
    win.size = initialSize;
    win.maxSize = maxSize;
    win.minSize = const Size(1000, 500);
    win.alignment = Alignment.center;
    win.title = "Clipboard app";
    win.show();
  });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<Category>> _categoriesFuture;
  bool flag = true;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = categoriesRepository.readCategoryDatabase();
  }

  CategoriesRepository categoriesRepository = CategoriesRepository();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: CustomDarkTheme.darkTheme,
      home: FutureBuilder<List<Category>>(
        future: _categoriesFuture, // The Future we're waiting for
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Show a loading indicator
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); // Handle errors
          } else {
            List<Category> categories = snapshot.data!; // Data is available
            return CategoriesOverview(
              categories: categories,
              saveCategories: saveCategories,
            );
          }
        },
      ),
    );
  }

  Future<void> saveCategories() async {
    await categoriesRepository.saveCategories();
    //_categoriesFuture = categoriesRepository.readCategoryDatabase(); // Refresh the Future
    setState(() {}); // Trigger a rebuild
  }
}
