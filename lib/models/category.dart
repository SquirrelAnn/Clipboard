class Category {
  final String id;
  final String name;
  final List<Snippet> snippets;

  Category({required this.id, required this.name, required this.snippets});

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'],
        name: json['name'],
        snippets: List<Snippet>.from(json['snippets'].map((x) => Snippet.fromJson(x))),
      );

    Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'snippets': List<dynamic>.from(snippets.map((x) => x.toJson())),
      };
}

class Snippet {
  final String id;
  final String snippetText;
  final String snippetTitle;

  Snippet({required this.id, required this.snippetText, required this.snippetTitle});

  factory Snippet.fromJson(Map<String, dynamic> json) => Snippet(
        id: json['id'],
        snippetText: json['snippetText'],
        snippetTitle: json['snippetTitle'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'snippetText': snippetText,
        'snippetTitle': snippetTitle,
      };
}
