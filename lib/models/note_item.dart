// lib/models/note_item.dart

class NoteItem {
  final String id;
  final String title;
  late final String content;
  final DateTime updatedAt;
  List<String> tags;

  NoteItem({
    required this.id,
    required this.title,
    required this.content,
    required this.updatedAt,
    this.tags = const [],
  });
  factory NoteItem.fromJson(Map<String, dynamic> json) => NoteItem(
    id: json['id'] ?? '',
    title: json['title'] as String,
    content: json['content'] as String,
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    tags: List<String>.from(json['tags'] ?? []),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'updatedAt': updatedAt.toIso8601String(),
    'tags': tags,
  };
}
