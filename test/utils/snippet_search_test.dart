import 'package:clipboard/models/category.dart';
import 'package:clipboard/utils/snippet_search.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final category = Category(
    id: 'cat-1',
    name: 'Docker',
    snippets: [
      Snippet.text(id: 's1', snippetTitle: 'Build', snippetText: 'docker-compose up --build'),
      Snippet.text(id: 's2', snippetTitle: 'Greeting', snippetText: 'Hello world'),
      Snippet.image(id: 's3', snippetTitle: 'Desktop shot', imagePath: 'images/s3.png'),
    ],
  );

  test('matches snippet title and text case-insensitively', () {
    expect(SnippetSearch.snippetMatches(category.snippets[0], 'DOCKER'), isTrue);
    expect(SnippetSearch.snippetMatches(category.snippets[0], 'compose'), isTrue);
    expect(SnippetSearch.snippetMatches(category.snippets[1], 'hello'), isTrue);
    expect(SnippetSearch.snippetMatches(category.snippets[1], 'docker'), isFalse);
  });

  test('matches image snippets by title and keywords', () {
    expect(SnippetSearch.snippetMatches(category.snippets[2], 'desktop'), isTrue);
    expect(SnippetSearch.snippetMatches(category.snippets[2], 'screenshot'), isTrue);
    expect(SnippetSearch.snippetMatches(category.snippets[2], 'compose'), isFalse);
  });

  test('categoryMatches considers category name and snippet content', () {
    expect(SnippetSearch.categoryMatches(category, 'docker'), isTrue);
    expect(SnippetSearch.categoryMatches(category, 'compose'), isTrue);
    expect(SnippetSearch.categoryMatches(category, 'missing'), isFalse);
  });

  test('resultsForCategories returns global matches when searching', () {
    final results = SnippetSearch.resultsForCategories([category], 'compose');

    expect(results, hasLength(1));
    expect(results.first.snippet.id, 's1');
    expect(results.first.categoryName, 'Docker');
  });

  test('resultsForCategories returns selected category snippets when not searching', () {
    final results = SnippetSearch.resultsForCategories(
      [category],
      '',
      categoryId: 'cat-1',
    );

    expect(results, hasLength(3));
  });
}
