import 'package:flutter/material.dart';

class SnippetSearchBar extends StatefulWidget {
  const SnippetSearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  State<SnippetSearchBar> createState() => _SnippetSearchBarState();
}

class _SnippetSearchBarState extends State<SnippetSearchBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant SnippetSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleControllerChanged);
      widget.controller.addListener(_handleControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanged);
    super.dispose();
  }

  void _handleControllerChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        key: const Key('search_field'),
        controller: widget.controller,
        focusNode: widget.focusNode,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: 'Search snippets and categories...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: widget.controller.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear search',
                  onPressed: () {
                    widget.controller.clear();
                    widget.onClear();
                  },
                  icon: const Icon(Icons.clear),
                ),
        ),
        style: theme.textTheme.bodyMedium,
      ),
    );
  }
}
