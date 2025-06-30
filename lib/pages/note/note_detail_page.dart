import 'package:flutter/material.dart';
import '../../services/map_service.dart';
import '../../models/note_detail.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';

class NoteDetailPage extends StatelessWidget {
  final String noteId;
  const NoteDetailPage({super.key, required this.noteId});

  // 只显示最后一个空格后的内容
  String shortPosition(String pos) {
    if (pos.trim().isEmpty) return '';
    final parts = pos.trim().split(RegExp(r'\s+'));
    return parts.isNotEmpty ? parts.last : pos;
  }

  Future<List<String>> fetchNoteTags(String userId, String noteId) async {
    final url = Uri.parse(
        '${AppConfig.host}/service/note/getNotesByIds?userId=$userId');
    final resp = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode([noteId]),
    );
    final bodyStr = utf8.decode(resp.bodyBytes);
    final body = jsonDecode(bodyStr);
    if (body['success'] == true && body['data'] != null) {
      final notes = body['data']['notes'] as List;
      if (notes.isNotEmpty && notes[0]['tags'] != null) {
        final tags = notes[0]['tags'] as List;
        return tags.map<String>((tag) => tag['content'] as String).toList();
      }
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1), // 淡黄色背景
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
          return FutureBuilder<List<String>>(
            future: fetchNoteTags(note.userId, note.id),
            builder: (ctx, tagSnap) {
              final tags = tagSnap.data ?? [];
              return Stack(
                children: [
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 1. 顶部灰色日期
                          Text(
                            note.time.toLocal().toString().split(' ')[0],
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 20),
                          ),
                          const SizedBox(height: 12),
                          // 2. 天气加粗
                          Text(
                            note.weather,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          // 3. 地址加粗
                          Text(
                            shortPosition(note.position),
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          // 4. 标签圆角框
                          if (tags.isNotEmpty)
                            Wrap(
                              spacing: 8,
                              children: tags
                                  .map((tag) => Chip(
                                        label: Text(tag,
                                            style:
                                                const TextStyle(fontSize: 13)),
                                        backgroundColor: Colors.white,
                                        shape: StadiumBorder(
                                            side: BorderSide(
                                                color: Colors.grey.shade300)),
                                      ))
                                  .toList(),
                            ),
                          const SizedBox(height: 16),
                          // 5. 正文内容滚动
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    note.content,
                                    style: const TextStyle(
                                        fontSize: 16, height: 1.6),
                                  ),
                                  const SizedBox(height: 12),
                                  if (note.pictures.isNotEmpty) ...[
                                    const Text('图片：'),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: note.pictures
                                          .map((url) => Image.network(url,
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover))
                                          .toList(),
                                    )
                                  ],
                                  const SizedBox(height: 60), // 给底部插画留空间
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 右下角插画和字数统计
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${note.content.length} 字',
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Image.asset(
                          'asset/images/kitty1.png',
                          width: 130,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
