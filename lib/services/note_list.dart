import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/note_item.dart';

class ApiService {
  static const _baseUrl = 'http://10.22.66.126:8001'; // 后端地址

  /// 获取笔记列表
  static Future<List<NoteItem>> fetchNotes() async {
    final resp = await http.get(Uri.parse('$_baseUrl/notes'));
    if (resp.statusCode == 200) {
      final List data = json.decode(resp.body);
      return data.map((e) => NoteItem.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load notes');
    }
  }

  /// 新建或更新单条笔记（有 id 就更新，无 id 就新建）
  static Future<void> saveNote(NoteItem note) async {
    final uri = note.id.isEmpty
        ? Uri.parse('$_baseUrl/notes')
        : Uri.parse('$_baseUrl/notes/${note.id}');
    final resp = await (note.id.isEmpty
        ? http.post(uri, body: json.encode(note.toJson()))
        : http.put(uri, body: json.encode(note.toJson())));
    if (resp.statusCode >= 400) {
      throw Exception('Save note failed');
    }
  }

  /// 根据标签生成笔记内容
  static Future<String> generateByTags(List<String> tags) async {
    final resp = await http.post(
      Uri.parse('$_baseUrl/notes/generate'),
      body: json.encode({'tags': tags}),
    );
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      return data['content'] as String;
    } else {
      throw Exception('Generate failed');
    }
  }

  /// 批量整理选中笔记
  static Future<String> batchGenerate(List<NoteItem> notes) async {
    final resp = await http.post(
      Uri.parse('$_baseUrl/notes/batch'),
      body: json.encode({'notes': notes.map((e) => e.toJson()).toList()}),
    );
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      return data['report'] as String;
    } else {
      throw Exception('Batch generate failed');
    }
  }
}
