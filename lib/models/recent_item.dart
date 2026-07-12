enum RecentItemType {
  text,
  image;

  static RecentItemType fromString(String? value) {
    switch (value) {
      case 'image':
        return RecentItemType.image;
      case 'text':
      default:
        return RecentItemType.text;
    }
  }

  String toJson() => name;
}

class RecentItem {
  RecentItem({
    required this.id,
    required this.type,
    required this.contentHash,
    required this.capturedAt,
    this.text,
    this.imagePath,
  }) : assert(
          (type == RecentItemType.text && text != null) ||
              (type == RecentItemType.image && imagePath != null),
          'Text items require text; image items require imagePath.',
        );

  final String id;
  final RecentItemType type;
  final String contentHash;
  final DateTime capturedAt;
  final String? text;
  final String? imagePath;

  factory RecentItem.fromJson(Map<String, dynamic> json) {
    final type = RecentItemType.fromString(json['type'] as String?);
    return RecentItem(
      id: json['id'] as String,
      type: type,
      contentHash: json['contentHash'] as String,
      capturedAt: DateTime.parse(json['capturedAt'] as String),
      text: json['text'] as String?,
      imagePath: json['imagePath'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.toJson(),
        'contentHash': contentHash,
        'capturedAt': capturedAt.toIso8601String(),
        if (text != null) 'text': text,
        if (imagePath != null) 'imagePath': imagePath,
      };

  String get preview {
    if (type == RecentItemType.image) {
      return 'Image';
    }
    final value = text ?? '';
    if (value.length <= 120) {
      return value;
    }
    return '${value.substring(0, 120)}…';
  }
}
