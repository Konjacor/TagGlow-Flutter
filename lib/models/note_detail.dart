// models/note_detail.dart
class NoteDetail {
  final String id;
  final String userId;
  final String content;
  final String position;
  final String weather;
  final DateTime time;
  final List<String> pictures;

  NoteDetail({
    required this.id,
    required this.userId,
    required this.content,
    required this.position,
    required this.weather,
    required this.time,
    required this.pictures,
  });

  factory NoteDetail.fromJson(Map<String, dynamic> note, List<dynamic> pics) {
    return NoteDetail(
      id: note['id'],
      userId: note['userId'],
      content: note['content'],
      position: note['position'] ?? '',
      weather: note['weather'] ?? '',
      time: DateTime.parse(note['time']),
      pictures: pics.cast<String>(),
    );
  }
}
