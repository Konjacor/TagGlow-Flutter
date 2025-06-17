// lib/pages/note_detail_page.dart
import 'package:flutter/material.dart';
import '../../services/map_service.dart';
import '../../models/note_detail.dart';

class NoteDetailPage extends StatelessWidget {
  final String noteId;
  const NoteDetailPage({Key? key, required this.noteId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('笔记详情'),
      ),
      body: FutureBuilder<NoteDetail>(
        future: MapService.getNoteDetail(noteId),
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('加载失败：${snap.error}'));
          }
          final note = snap.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Text('位置：${note.position}'),
                const SizedBox(height: 8),
                Text('天气：${note.weather}'),
                const SizedBox(height: 8),
                Text('时间：${note.time.toLocal()}'),
                const SizedBox(height: 16),
                Text('内容：${note.content}', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (note.pictures.isNotEmpty) ...[
                  const Text('图片：'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: note.pictures
                        .map((url) => Image.network(url, width: 100, height: 100, fit: BoxFit.cover))
                        .toList(),
                  )
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
