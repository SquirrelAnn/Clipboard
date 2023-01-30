import 'package:uuid/uuid.dart';

class Category {
  String id = "";
  String name = "";
  List<String> snippets = <String>[];

  Category(this.name, this.snippets) {
    var uuid = const Uuid();
    var v1 = uuid.v1();
    id = v1;
  }

  Category.fromJson(Map<String, dynamic> json) {
    var snippetsJson = json['snippets'];
    List<String> snippets = List<String>.from(snippetsJson);
    id = json['id'];
    name = json['name'];
    this.snippets = snippets; //json['snippets'];
  }

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'snippets': snippets};
}
