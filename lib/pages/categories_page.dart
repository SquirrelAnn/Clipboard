import 'package:clipboard/controllers/categories_controller.dart';
import 'package:clipboard/controllers/recent_controller.dart';
import 'package:clipboard/models/category.dart';
import 'package:clipboard/models/recent_item.dart';
import 'package:clipboard/utils/snippet_search.dart';
import 'package:clipboard/widgets/add_category_dialog.dart';
import 'package:clipboard/widgets/category_list_panel.dart';
import 'package:clipboard/widgets/recent_list_panel.dart';
import 'package:clipboard/widgets/snippet_dialog.dart';
import 'package:clipboard/widgets/snippet_list_panel.dart';
import 'package:clipboard/widgets/snippet_search_bar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum _MainTab { snippets, recent }

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({
    super.key,
    required this.controller,
    required this.recentController,
  });

  final CategoriesController controller;
  final RecentController recentController;

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  late final ScrollController _categoryScrollController;
  late final ScrollController _snippetScrollController;
  late final ScrollController _recentScrollController;
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  _MainTab _selectedTab = _MainTab.snippets;

  CategoriesController get _controller => widget.controller;
  RecentController get _recentController => widget.recentController;

  @override
  void initState() {
    super.initState();
    _categoryScrollController = ScrollController(initialScrollOffset: 10);
    _snippetScrollController = ScrollController(initialScrollOffset: 10);
    _recentScrollController = ScrollController(initialScrollOffset: 10);
    _searchController = TextEditingController(text: _controller.searchQuery);
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _categoryScrollController.dispose();
    _snippetScrollController.dispose();
    _recentScrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_controller, _recentController]),
      builder: (context, _) {
        final theme = Theme.of(context);
        final isRecentTab = _selectedTab == _MainTab.recent;

        return CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.keyF, control: true): _focusSearch,
            const SingleActivator(LogicalKeyboardKey.keyN, control: true): _showAddSnippetDialog,
            const SingleActivator(LogicalKeyboardKey.keyN, control: true, shift: true): _showAddCategoryDialog,
          },
          child: Focus(
            autofocus: true,
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Clipboard app'),
                actions: [
                  if (isRecentTab)
                    IconButton(
                      tooltip: 'Clear recent history',
                      onPressed: _recentController.items.isEmpty ? null : _confirmClearRecentHistory,
                      icon: const Icon(Icons.delete_sweep_outlined),
                    ),
                  IconButton(
                    tooltip: 'Export backup',
                    onPressed: _exportBackup,
                    icon: const Icon(Icons.upload),
                  ),
                  IconButton(
                    tooltip: 'Import backup',
                    onPressed: _importBackup,
                    icon: const Icon(Icons.download),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'More',
                    onSelected: _handleMenuSelection,
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'shortcuts',
                        child: Text('Keyboard shortcuts'),
                      ),
                    ],
                  ),
                ],
              ),
              body: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: SegmentedButton<_MainTab>(
                      segments: const [
                        ButtonSegment(
                          value: _MainTab.snippets,
                          label: Text('Snippets'),
                          icon: Icon(Icons.bookmarks_outlined),
                        ),
                        ButtonSegment(
                          value: _MainTab.recent,
                          label: Text('Recent'),
                          icon: Icon(Icons.history),
                        ),
                      ],
                      selected: {_selectedTab},
                      onSelectionChanged: (selection) {
                        setState(() => _selectedTab = selection.first);
                      },
                    ),
                  ),
                  if (!isRecentTab)
                    SnippetSearchBar(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      onChanged: _controller.setSearchQuery,
                      onClear: _clearSearch,
                    ),
                  Expanded(
                    child: isRecentTab
                        ? RecentListPanel(
                            items: _recentController.items,
                            imageStorage: _recentController.repository.imageStorageService,
                            scrollController: _recentScrollController,
                            onItemCopied: _copyRecentItem,
                            onItemDeleted: _confirmDeleteRecentItem,
                            onSaveAsSnippet: _saveRecentAsSnippet,
                          )
                        : Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: CategoryListPanel(
                                  categories: _controller.filteredCategories,
                                  selectedCategoryId: _controller.selectedCategoryId,
                                  scrollController: _categoryScrollController,
                                  onCategorySelected: _controller.selectCategory,
                                  onCategoryDeleted: _confirmDeleteCategory,
                                ),
                              ),
                              VerticalDivider(color: theme.colorScheme.primary),
                              Expanded(
                                flex: 3,
                                child: SnippetListPanel(
                                  entries: _controller.visibleSnippets,
                                  imageStorage: _controller.repository.imageStorageService,
                                  scrollController: _snippetScrollController,
                                  showCategoryNames: _controller.isSearching,
                                  onSnippetCopied: _copySnippetResult,
                                  onSnippetEdited: _showEditSnippetDialog,
                                  onSnippetDeleted: _confirmDeleteSnippet,
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
              floatingActionButton: isRecentTab
                  ? null
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const SizedBox(width: 30),
                        FloatingActionButton(
                          key: const Key('add_category_fab'),
                          onPressed: _showAddCategoryDialog,
                          tooltip: 'Add new category (Ctrl+Shift+N)',
                          child: const Icon(Icons.add),
                        ),
                        const Spacer(),
                        FloatingActionButton(
                          key: const Key('add_snippet_fab'),
                          onPressed: _showAddSnippetDialog,
                          tooltip: 'Add snippet (Ctrl+N)',
                          child: const Icon(Icons.add),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  void _focusSearch() {
    if (_selectedTab != _MainTab.snippets) {
      return;
    }
    _searchFocusNode.requestFocus();
  }

  void _clearSearch() {
    _controller.clearSearch();
  }

  void _handleMenuSelection(String value) {
    if (value == 'shortcuts') {
      _showShortcutsDialog();
    }
  }

  Future<void> _showShortcutsDialog() async {
    final theme = Theme.of(context);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Keyboard shortcuts', style: theme.dialogTheme.titleTextStyle),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ctrl+F — Focus search'),
            Text('Ctrl+N — Add snippet'),
            Text('Ctrl+Shift+N — Add category'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportBackup() async {
    final directoryPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Choose export folder',
    );
    if (directoryPath == null) return;

    try {
      await _controller.exportToDirectory(directoryPath);
      if (!mounted) return;
      _showSnackBar('Backup exported successfully.');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Export failed: $e');
    }
  }

  Future<void> _importBackup() async {
    final directoryPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Choose backup folder',
    );
    if (directoryPath == null) return;

    final replaceExisting = await _confirmImportMode();
    if (replaceExisting == null) return;

    try {
      await _controller.importFromDirectory(
        directoryPath,
        replaceExisting: replaceExisting,
      );
      if (!mounted) return;
      _showSnackBar(replaceExisting ? 'Backup replaced current data.' : 'Backup merged successfully.');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Import failed: $e');
    }
  }

  Future<bool?> _confirmImportMode() {
    final theme = Theme.of(context);
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Import backup', style: theme.dialogTheme.titleTextStyle),
        content: Text(
          'Replace all current snippets or merge with existing data?',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Merge'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Replace'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddCategoryDialog() async {
    final name = await AddCategoryDialog.show(context);
    if (name == null) return;
    await _controller.addCategory(name);
  }

  Future<void> _showAddSnippetDialog() async {
    if (_controller.categories.isEmpty) {
      _showSnackBar('Add a category first.');
      return;
    }

    final snippet = await SnippetDialog.showAdd(
      context,
      clipboardService: _controller.clipboardService,
      imageStorageService: _controller.repository.imageStorageService,
    );
    if (snippet == null) return;

    await _controller.addSnippet(snippet);
  }

  Future<void> _showEditSnippetDialog(SnippetSearchResult result) async {
    final updated = await SnippetDialog.showEdit(
      context,
      clipboardService: _controller.clipboardService,
      imageStorageService: _controller.repository.imageStorageService,
      existingSnippet: result.snippet,
    );
    if (updated == null) return;

    await _controller.updateSnippet(result.categoryId, result.snippet.id, updated);
  }

  Future<void> _confirmDeleteCategory(String categoryId) async {
    final theme = Theme.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Warning', style: theme.dialogTheme.titleTextStyle),
        content: Text('Delete category?', style: theme.textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _controller.deleteCategory(categoryId);
    }
  }

  Future<void> _confirmDeleteSnippet(String categoryId, String snippetId) async {
    final theme = Theme.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Warning', style: theme.dialogTheme.titleTextStyle),
        content: Text('Delete snippet?', style: theme.textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _controller.deleteSnippet(categoryId, snippetId);
    }
  }

  Future<void> _confirmDeleteRecentItem(RecentItem item) async {
    final theme = Theme.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Warning', style: theme.dialogTheme.titleTextStyle),
        content: Text('Remove this item from recent history?', style: theme.textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _recentController.removeItem(item.id);
    }
  }

  Future<void> _confirmClearRecentHistory() async {
    final theme = Theme.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Clear recent history', style: theme.dialogTheme.titleTextStyle),
        content: Text(
          'Remove all recent clipboard entries?',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _recentController.clearHistory();
    }
  }

  Future<void> _saveRecentAsSnippet(RecentItem item) async {
    if (_controller.categories.isEmpty) {
      _showSnackBar('Add a category first.');
      return;
    }

    final categoryId = _controller.selectedCategoryId ?? _controller.categories.first.id;
    final defaultTitle = item.type == RecentItemType.image ? 'Screenshot' : _defaultTextTitle(item.text ?? '');
    final title = await _showSaveRecentDialog(defaultTitle);
    if (title == null) return;

    try {
      await _recentController.saveAsSnippet(
        item: item,
        categoryId: categoryId,
        title: title,
      );
      _controller.refreshFromRepository();
      if (!mounted) return;
      _showSnackBar('Saved to snippets.');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Failed to save snippet: $e');
    }
  }

  String _defaultTextTitle(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return 'Snippet';
    }
    if (trimmed.length <= 40) {
      return trimmed;
    }
    return '${trimmed.substring(0, 40)}…';
  }

  Future<String?> _showSaveRecentDialog(String defaultTitle) async {
    final theme = Theme.of(context);
    final titleController = TextEditingController(text: defaultTitle);

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Save as snippet', style: theme.dialogTheme.titleTextStyle),
        content: TextField(
          controller: titleController,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Snippet title'),
          onSubmitted: (_) => Navigator.pop(dialogContext, true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved != true) {
      return null;
    }

    return titleController.text.trim();
  }

  Future<void> _copySnippetResult(SnippetSearchResult result) async {
    await _copySnippet(result.snippet);
  }

  Future<void> _copySnippet(Snippet snippet) async {
    try {
      await _controller.copySnippet(snippet);
      if (!mounted) return;
      _showSnackBar(
        snippet.type == SnippetType.image ? 'Image copied to clipboard.' : 'Text copied to clipboard.',
      );
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Failed to copy: $e');
    }
  }

  Future<void> _copyRecentItem(RecentItem item) async {
    try {
      await _recentController.copyItem(item);
      if (!mounted) return;
      _showSnackBar(
        item.type == RecentItemType.image ? 'Image copied to clipboard.' : 'Text copied to clipboard.',
      );
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Failed to copy: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
