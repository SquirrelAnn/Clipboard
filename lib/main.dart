import 'package:clipboard/controllers/categories_controller.dart';
import 'package:clipboard/controllers/recent_controller.dart';
import 'package:clipboard/pages/categories_page.dart';
import 'package:clipboard/platform/window_setup.dart'
    if (dart.library.io) 'package:clipboard/platform/window_setup_io.dart';
import 'package:clipboard/repositories/categories_repository.dart';
import 'package:clipboard/repositories/recent_history_repository.dart';
import 'package:clipboard/services/clipboard_monitor_service.dart';
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
  late final RecentHistoryRepository _recentRepository;
  late final ClipboardService _clipboardService;
  late final CategoriesController _controller;
  late final RecentController _recentController;
  late final ClipboardMonitorService _clipboardMonitor;
  late final Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _repository = CategoriesRepository();
    _recentRepository = RecentHistoryRepository(
      imageStorageService: _repository.imageStorageService,
    );
    _clipboardService = ClipboardService(
      imageStorageService: _repository.imageStorageService,
    );
    _controller = CategoriesController(_repository, _clipboardService);
    _recentController = RecentController(
      _recentRepository,
      _clipboardService,
      categoriesRepository: _repository,
    );
    _clipboardMonitor = ClipboardMonitorService(
      clipboardService: _clipboardService,
      repository: _recentRepository,
      onHistoryChanged: _recentController.refreshFromRepository,
    );
    _loadFuture = _loadAppData();
  }

  Future<void> _loadAppData() async {
    await Future.wait([
      _controller.load(),
      _recentController.load(),
    ]);
    _clipboardMonitor.start();
  }

  @override
  void dispose() {
    _clipboardMonitor.dispose();
    _controller.dispose();
    _recentController.dispose();
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
          if (snapshot.connectionState == ConnectionState.waiting ||
              _controller.isLoading ||
              _recentController.isLoading) {
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

          if (_recentController.error != null) {
            return Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Error: ${_recentController.error}'),
                ),
              ),
            );
          }

          return CategoriesPage(
            controller: _controller,
            recentController: _recentController,
          );
        },
      ),
    );
  }
}
