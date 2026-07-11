import 'package:clipboard/models/category.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Snippet', () {
    test('text snippet serializes and deserializes', () {
      final snippet = Snippet.text(
        id: 'id-1',
        snippetTitle: 'Title',
        snippetText: 'Hello',
      );

      final json = snippet.toJson();
      final restored = Snippet.fromJson(json);

      expect(restored.id, 'id-1');
      expect(restored.type, SnippetType.text);
      expect(restored.snippetTitle, 'Title');
      expect(restored.snippetText, 'Hello');
      expect(restored.imagePath, isNull);
    });

    test('image snippet serializes and deserializes', () {
      final snippet = Snippet.image(
        id: 'id-2',
        snippetTitle: 'Screenshot',
        imagePath: 'images/id-2.png',
      );

      final restored = Snippet.fromJson(snippet.toJson());

      expect(restored.type, SnippetType.image);
      expect(restored.imagePath, 'images/id-2.png');
      expect(restored.snippetText, isNull);
    });

    test('legacy JSON without type defaults to text', () {
      final restored = Snippet.fromJson({
        'id': 'legacy',
        'snippetTitle': 'Old',
        'snippetText': 'value',
      });

      expect(restored.type, SnippetType.text);
      expect(restored.snippetText, 'value');
    });
  });

  group('Category', () {
    test('round-trips through JSON with mixed snippet types', () {
      final category = Category(
        id: 'cat-1',
        name: 'Work',
        snippets: [
          Snippet.text(id: 's1', snippetTitle: 'Greeting', snippetText: 'Hi'),
          Snippet.image(id: 's2', snippetTitle: 'Shot', imagePath: 'images/s2.png'),
        ],
      );

      final restored = Category.fromJson(category.toJson());

      expect(restored.name, 'Work');
      expect(restored.snippets.length, 2);
      expect(restored.snippets[0].type, SnippetType.text);
      expect(restored.snippets[1].type, SnippetType.image);
    });
  });
}
