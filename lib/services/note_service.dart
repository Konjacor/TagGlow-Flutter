import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../config/app_config.dart';

class NoteService {
  static String get _baseUrl => '${AppConfig.host}/service/note';

  /// 获取用户所有笔记
  static Future<List<Note>> getNotesByUserId(String userId) async {
    final uri = Uri.parse('$_baseUrl/getNotesByUserId/$userId');
    final resp = await http.get(uri);

    if (resp.statusCode == 200) {
      final bodyStr = utf8.decode(resp.bodyBytes);
      final body = jsonDecode(bodyStr);

      // 修正：此接口的成功 code 是 20000
      if (body['code']?.toString() == '20000' &&
          body['data']?['items'] != null) {
        final items = body['data']['items'] as List;

        return items
            .map((e) => Note.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        // 抛出包含原始响应的错误，方便调试。
        throw Exception('未能解析笔记列表。后端原始返回: $bodyStr');
      }
    }
    throw Exception('获取笔记接口失败: ${resp.statusCode}');
  }

  /// 保存笔记，包括内容和标签
  static Future<Map<String, dynamic>> saveNote({
    required String content,
    required String position,
    required String userId,
    required String weather,
    required List<String> tags,
    int? classificationId,
  }) async {
    // 构造请求的 URI，将 tagList 作为查询参数
    final uri = Uri.parse('$_baseUrl/saveNote').replace(queryParameters: {
      'tagList': tags,
    });

    // 构造请求体 note 对象
    final noteBody = {
      'content': content,
      'position': position,
      'userId': userId,
      'weather': weather,
      'classification': classificationId,
      // 修正：将时间格式化为后端需要的 'yyyy-MM-dd'T'HH:mm:ss.SSSZ' 格式
      'time': DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
          .format(DateTime.now().toUtc()),
    };

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode(noteBody),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final bodyStr = utf8.decode(response.bodyBytes);
      final resp = jsonDecode(bodyStr);

      // 全新、更健壮的成功判断逻辑：
      // 修正：后端返回的字段是 'aiReply' 而不是 'content'
      final aiContent = resp['data']?['aiReply'] as String?;

      if (aiContent != null && aiContent.isNotEmpty) {
        // 只要有 AI 回复，就认为是成功！
        return resp;
      } else {
        // 如果没有AI回复，抛出包含原始响应的错误，方便调试。
        throw Exception('未能解析AI回复。后端原始返回: $bodyStr');
      }
    } else {
      throw Exception(
          '保存笔记接口失败 (status=${response.statusCode}): ${response.body}');
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
      throw Exception('Get location failed: ${response.statusCode}');
    }
  }

  /// 获取天气
  Future<String> getWeather() async {
    print('【调试】准备请求后端天气接口...');
    final uri = Uri.parse('$_baseUrl/getWeather');
    final response = await http.get(uri);
    print('【调试】天气接口响应: ${response.statusCode} ${response.body}');
    if (response.statusCode == 200) {
      final bodyStr = utf8.decode(response.bodyBytes);
      final resp = jsonDecode(bodyStr);
      return resp['data']['weather'];
    } else {
      throw Exception('Get weather failed: ${response.statusCode}');
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

  /// 根据主题ID获取主题名称
  static Future<String> getClassificationName(int classification) async {
    final uri = Uri.parse('$_baseUrl/getClassificationName/$classification');
    final response = await http.get(uri, headers: {'Accept': 'text/plain'});
    if (response.statusCode == 200) {
      return utf8.decode(response.bodyBytes);
    } else {
      throw Exception('获取主题名称失败: ${response.statusCode}');
    }
  }

  /// 根据主题、用户、位置生成默认AI标签
  static Future<String> getNoteDefaultAiTag({
    required String userId,
    required String position,
    required int classification,
  }) async {
    final uri =
        Uri.parse('$_baseUrl/NoteDefaultaitag').replace(queryParameters: {
      'userId': userId,
      'position': position,
      'classification': classification.toString(),
    });
    final response = await http.post(
      uri,
      headers: {'Accept': 'application/json'},
    );
    if (response.statusCode == 200) {
      final bodyStr = utf8.decode(response.bodyBytes);
      final resp = jsonDecode(bodyStr);
      if (resp['success'] == true) {
        return resp['data']['NoteDefaultaitag'] as String;
      } else {
        throw Exception('获取AI标签失败: ${resp['message']}');
      }
    } else {
      throw Exception('获取AI标签接口失败: ${response.statusCode}');
    }
  }
}
