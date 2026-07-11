import 'package:clipboard/controllers/categories_controller.dart';
import 'package:clipboard/pages/categories_page.dart';
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
  late final CategoriesRepository _repository;
  late final CategoriesController _controller;
  late final Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _repository = CategoriesRepository();
    final clipboardService = ClipboardService(
      imageStorageService: _repository.imageStorageService,
    );
    _controller = CategoriesController(_repository, clipboardService);
    _loadFuture = _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clipboard app',
      theme: CustomDarkTheme.darkTheme,
      home: FutureBuilder<void>(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || _controller.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (_controller.error != null) {
            return Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Error: ${_controller.error}'),
                ),
              ),
            );
          }

          return CategoriesPage(controller: _controller);
        },
      ),
    );
  }
}
