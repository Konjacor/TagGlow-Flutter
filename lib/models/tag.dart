class Tag {
  final String content;
  Tag({required this.content});
  factory Tag.fromJson(Map<String, dynamic> json) =>
      Tag(content: json['content']);
}
