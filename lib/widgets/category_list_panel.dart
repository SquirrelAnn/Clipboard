import 'package:clipboard/models/category.dart';
import 'package:flutter/material.dart';

class CategoryListPanel extends StatelessWidget {
  const CategoryListPanel({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.scrollController,
    required this.onCategorySelected,
    required this.onCategoryDeleted,
  });

  final List<Category> categories;
  final String? selectedCategoryId;
  final ScrollController scrollController;
  final ValueChanged<String> onCategorySelected;
  final ValueChanged<String> onCategoryDeleted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.only(bottom: 4),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = category.id == selectedCategoryId;

        return Row(
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(left: 10, top: 4),
                child: TextButton(
                  style: _listItemStyle(theme, selected: isSelected),
                  onPressed: () => onCategorySelected(category.id),
                  child: Text(category.name),
                ),
              ),
            ),
            IconButton(
              onPressed: () => onCategoryDeleted(category.id),
              icon: const Icon(Icons.delete),
            ),
          ],
        );
      },
    );
  }

  ButtonStyle _listItemStyle(ThemeData theme, {required bool selected}) {
    final scheme = theme.colorScheme;

    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) {
          return scheme.surfaceContainerHighest;
        }
        if (selected) {
          return scheme.primary;
        }
        return Colors.transparent;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (selected) {
          return scheme.onPrimary;
        }
        return scheme.onSurface;
      }),
    );
  }
}
