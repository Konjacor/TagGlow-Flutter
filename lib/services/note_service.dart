import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/note.dart';

class NoteService {
  static const _baseUrl = 'http://127.0.0.1:8001/service/note';

  /// 获取用户所有笔记
  static Future<List<Note>> getNotesByUserId(String userId) async {
    final uri = Uri.parse('$_baseUrl/getNotesByUserId/$userId');
    final resp = await http.get(uri);

    if (resp.statusCode == 200) {
      final bodyStr = utf8.decode(resp.bodyBytes);
      final body = jsonDecode(bodyStr);

      if (body['success'] == true) {
        // 根据实际返回结构调整，现在数据在 data.items 中
        final data = body['data'] as Map<String, dynamic>;
        final items = data['items'] as List;

        return items.map((e) => Note.fromJson(e as Map<String, dynamic>)).toList();
      }
    }
    throw Exception('获取笔记失败: ${resp.body}');
  }

  /// 新增笔记
  static Future<bool> addNote({
    required String id,
    required String content,
    required String position,
    required String userId,
    required String weather,
    required List<String> tags,
  }) async {
    final uri = Uri.parse('$_baseUrl/addNote');
    final body = {

      'content': content,
      'position': position,
      'userId': userId,
      'weather': weather,
      // 如果后端支持 tags 字段，可以启用以下行：
      // 'tags': tags,
    };
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final bodyStr = utf8.decode(response.bodyBytes);
      final resp = jsonDecode(bodyStr);
      return resp['success'] == true && resp['code'] == 20000;
    } else {
      throw Exception('Add note failed (status=${response.statusCode}): ${response.body}');
    }
  }
  /// 获取位置
  Future<Map<String, String>> getLocation() async {
    final uri = Uri.parse('$_baseUrl/getLocation');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final bodyStr = utf8.decode(response.bodyBytes);
      final resp = jsonDecode(bodyStr);
      final loc = resp['data']['location'];
      return {
        'country': loc['country'],
        'province': loc['province'],
        'city': loc['city'],
      };
    } else {
      throw Exception('Get location failed: \${response.statusCode}');
    }
  }

  /// 获取天气
  Future<String> getWeather() async {
    final uri = Uri.parse('$_baseUrl/getWeather');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final bodyStr = utf8.decode(response.bodyBytes);
      final resp = jsonDecode(bodyStr);

      return resp['data']['weather'];
    } else {
      throw Exception('Get weather failed: \${response.statusCode}');
    }
  }

  /// 删除笔记
  static Future<bool> deleteNote(String id, String noteId) async {
    // 构造 URI，path 用 id，query 用 noteId
    final uri = Uri.parse('$_baseUrl/delete/$noteId?userId=$id');
    final resp = await http.delete(uri);

    if (resp.statusCode == 200) {
      // 后端返回体可能含有 non-UTF8 字符，建议用 bodyBytes + utf8.decode
      final body = jsonDecode(utf8.decode(resp.bodyBytes));
      return body['success'] == true;
    }
    return false;
  }

}