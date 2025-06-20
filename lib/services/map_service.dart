// 在 services/login_service.dart 里
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/note_detail.dart'; // 新增一个 detail 模型
import '../config/app_config.dart';

class MapService {
  static String get _baseUrl => '${AppConfig.host}/service/map';

  /// 获取单条笔记详情
  static Future<NoteDetail> getNoteDetail(String noteId) async {
    final resp = await http.get(
      Uri.parse('$_baseUrl/noteDetail/$noteId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (resp.statusCode == 200) {
      final bodyStr = utf8.decode(resp.bodyBytes);
      final body = jsonDecode(bodyStr);
      if (body['success'] == true) {
        return NoteDetail.fromJson(
            body['data']['note'], body['data']['pictures']);
      } else {
        throw Exception(body['message']);
      }
    } else {
      throw Exception('网络异常：${resp.statusCode}');
    }
  }
}
