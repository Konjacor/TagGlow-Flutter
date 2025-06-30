import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/tag.dart';

class TagService {
  static Future<List<Tag>> getUserTags(String userId) async {
    final resp = await http.get(
      Uri.parse('${AppConfig.host}/service/tag/user/$userId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (resp.statusCode == 200) {
      final List data = json.decode(resp.body);
      return data.map((e) => Tag.fromJson(e)).toList();
    } else {
      throw Exception('标签获取失败');
    }
  }
}
