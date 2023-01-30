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
  List<Category> categories = <Category>[];

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  CategoriesRepository categoriesRepository = CategoriesRepository();
  loadCategories() async {
    await categoriesRepository.readCategoryDatabase();
    setState(() {
      categories = categoriesRepository.getCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: CustomDarkTheme.darkTheme,
      home: CategoriesOverview(categories: categories, saveCategories: saveCategories),
    );
  }

  saveCategories() async {
    await categoriesRepository.saveCategories();
    setState(() {
      categories = categoriesRepository.getCategories();
    });
  }
}
