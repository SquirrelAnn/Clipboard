enum SnippetType {
  text,
  image;

  static SnippetType fromString(String? value) {
    switch (value) {
      case 'image':
        return SnippetType.image;
      case 'text':
      default:
        return SnippetType.text;
    }
  }

  String toJson() => name;
}

class Category {
  final String id;
  final String name;
  final List<Snippet> snippets;

  Category({required this.id, required this.name, required this.snippets});

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'] as String,
        name: json['name'] as String,
        snippets: (json['snippets'] as List<dynamic>)
            .map((x) => Snippet.fromJson(x as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'snippets': snippets.map((x) => x.toJson()).toList(),
      };
}

class Snippet {
  final String id;
  final String snippetTitle;
  final SnippetType type;
  final String? snippetText;
  final String? imagePath;

  Snippet({
    required this.id,
    required this.snippetTitle,
    this.type = SnippetType.text,
    this.snippetText,
    this.imagePath,
  }) : assert(
          (type == SnippetType.text && snippetText != null) ||
              (type == SnippetType.image && imagePath != null),
          'Text snippets require snippetText; image snippets require imagePath.',
        );

  factory Snippet.text({
    required String id,
    required String snippetTitle,
    required String snippetText,
  }) =>
      Snippet(
        id: id,
        snippetTitle: snippetTitle,
        type: SnippetType.text,
        snippetText: snippetText,
      );

  factory Snippet.image({
    required String id,
    required String snippetTitle,
    required String imagePath,
  }) =>
      Snippet(
        id: id,
        snippetTitle: snippetTitle,
        type: SnippetType.image,
        imagePath: imagePath,
      );

  factory Snippet.fromJson(Map<String, dynamic> json) {
    final type = SnippetType.fromString(json['type'] as String?);
    return Snippet(
      id: json['id'] as String,
      snippetTitle: json['snippetTitle'] as String,
      type: type,
      snippetText: json['snippetText'] as String?,
      imagePath: json['imagePath'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'snippetTitle': snippetTitle,
        'type': type.toJson(),
        if (snippetText != null) 'snippetText': snippetText,
        if (imagePath != null) 'imagePath': imagePath,
      };
}
