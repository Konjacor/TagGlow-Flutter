class Note {
  final String id;
  final String userId;
  final String content;
  final String position;
  final String weather;
  final DateTime time;
  final DateTime gmtCreate;
  final DateTime gmtModified;
  final int isDeleted;

  Note({
    required this.id,
    required this.userId,
    required this.content,
    required this.position,
    required this.weather,
    required this.time,
    required this.gmtCreate,
    required this.gmtModified,
    required this.isDeleted,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      userId: json['userId'] as String,
      content: json['content'] as String,
      position: json['position'] as String,
      weather: json['weather'] as String,
      time: DateTime.parse(json['time'] as String),
      gmtCreate: DateTime.parse(json['gmtCreate'] as String),
      gmtModified: DateTime.parse(json['gmtModified'] as String),
      isDeleted: json['isDeleted'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'content': content,
    'position': position,
    'weather': weather,
    'time': time.toIso8601String(),
    'gmtCreate': gmtCreate.toIso8601String(),
    'gmtModified': gmtModified.toIso8601String(),
    'isDeleted': isDeleted,
  };
}
