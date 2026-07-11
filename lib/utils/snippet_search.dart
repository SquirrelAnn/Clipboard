import 'package:clipboard/models/category.dart';

class SnippetSearchResult {
  const SnippetSearchResult({
    required this.categoryId,
    required this.categoryName,
    required this.snippet,
  });

  final String categoryId;
  final String categoryName;
  final Snippet snippet;
}

class SnippetSearch {
  static String normalize(String query) => query.trim().toLowerCase();

  static bool isActive(String query) => normalize(query).isNotEmpty;

  static bool categoryNameMatches(Category category, String query) {
    final normalized = normalize(query);
    if (normalized.isEmpty) {
      return true;
    }
    return category.name.toLowerCase().contains(normalized);
  }

  static bool snippetMatches(Snippet snippet, String query) {
    final normalized = normalize(query);
    if (normalized.isEmpty) {
      return true;
    }

    if (snippet.snippetTitle.toLowerCase().contains(normalized)) {
      return true;
    }

    if (snippet.type == SnippetType.text) {
      return snippet.snippetText!.toLowerCase().contains(normalized);
    }

    return normalized.contains('screenshot') ||
        normalized.contains('image') ||
        normalized.contains('bild');
  }

  static bool categoryMatches(Category category, String query) {
    if (!isActive(query)) {
      return true;
    }
    if (categoryNameMatches(category, query)) {
      return true;
    }
    return category.snippets.any((snippet) => snippetMatches(snippet, query));
  }

  static Iterable<Snippet> matchingSnippets(Category category, String query) {
    if (!isActive(query)) {
      return category.snippets;
    }
    if (categoryNameMatches(category, query)) {
      return category.snippets;
    }
    return category.snippets.where((snippet) => snippetMatches(snippet, query));
  }

  static List<SnippetSearchResult> resultsForCategories(
    List<Category> categories,
    String query, {
    String? categoryId,
  }) {
    if (!isActive(query)) {
      if (categoryId == null) {
        return const [];
      }
      final category = categories.where((item) => item.id == categoryId).firstOrNull;
      if (category == null) {
        return const [];
      }
      return category.snippets
          .map(
            (snippet) => SnippetSearchResult(
              categoryId: category.id,
              categoryName: category.name,
              snippet: snippet,
            ),
          )
          .toList();
    }

    final scopedCategories = categoryId == null
        ? categories
        : categories.where((category) => category.id == categoryId);

    final results = <SnippetSearchResult>[];
    for (final category in scopedCategories) {
      for (final snippet in matchingSnippets(category, query)) {
        results.add(
          SnippetSearchResult(
            categoryId: category.id,
            categoryName: category.name,
            snippet: snippet,
          ),
        );
      }
    }
    return results;
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) {
      return null;
    }
    return iterator.current;
  }
}
