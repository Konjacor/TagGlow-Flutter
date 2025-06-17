import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';



class LoginService {
  // 登录接口地址，Android 模拟器访问宿主机
  static const _loginUrl = 'http://127.0.0.1:8001/service/user/login';

  /// 登录并保存用户信息到本地
  /// 返回 true 表示登录成功
  static Future<bool> login(String username, String password) async {
    final uri = Uri.parse(_loginUrl);
    final body = {
      'username': username,
      'password': password,
    };

    try {
      final response = await http.post(
        uri,
          headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final bodyStr = utf8.decode(response.bodyBytes);
        final result = jsonDecode(bodyStr);
        if (result['success'] == true) {
          final userJson = result['data']['user'] as Map<String, dynamic>;
          final user = User.fromJson(userJson);

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_id', user.id);
          await prefs.setString('username', user.username);
          await prefs.setString('avatar', user.avatar);
          await prefs.setString('signature', user.signature);
          await prefs.setString('gmt_create', user.gmtCreate);
          await prefs.setString('gmt_modified', user.gmtModified);
          await prefs.setInt('is_deleted', user.isDeleted);
          await prefs.setBool('is_logged_in', true);

          return true;
        }
      }
      return false;
    } catch (e) {
      print('登录异常: $e');
      return false;
    }
  }

  /// 检查本地是否已登录
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  /// 获取当前登录的用户信息
  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('user_id');
    if (id == null) return null;
    return User(
      id: id,
      username: prefs.getString('username') ?? '',
      avatar: prefs.getString('avatar') ?? '',
      signature: prefs.getString('signature') ?? '',
      gmtCreate: prefs.getString('gmt_create') ?? '',
      gmtModified: prefs.getString('gmt_modified') ?? '',
      isDeleted: prefs.getInt('is_deleted') ?? 0,
    );
  }

  /// 注销登录并清除本地数据
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
  /// 更新头像：向 /updateAvatar/{userId} 上传 file 字段
  static Future<bool> updateAvatar(String userId, File imageFile) async {
    final uri = Uri.parse('http://127.0.0.1:8001/service/user/updateAvatar/$userId');
    try {
      // 使用 MultipartRequest
      final request = http.MultipartRequest('POST', uri);
      // 注意后端 formData 字段名叫 “file”
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      // 如果需要带 token 或其他 header，也可以这样加：
      // request.headers['Authorization'] = 'Bearer $token';

      final streamedResp = await request.send();
      final resp = await http.Response.fromStream(streamedResp);

      print('🔄 updateAvatar 上传状态码: ${resp.statusCode}');
      print('🔄 updateAvatar 返回内容: ${resp.body}');

      if (resp.statusCode == 200) {
        final bodyStr = utf8.decode(resp.bodyBytes);
        final result = jsonDecode(bodyStr);
        return result['success'] == true;
      }
    } catch (e) {
      print('❗️ updateAvatar 异常: $e');
    }
    return false;
  }


  // 更新个性签名
  static Future<bool> updateSignature(String userId, String signature) async {
    final uri = Uri.parse('http://127.0.0.1:8001/service/user/updateSignature/$userId');
    final body = {'signature': signature};
    try {
      final resp = await http.post(
        uri,
          headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode(body),
      );
      if (resp.statusCode == 200) {
        final bodyStr = utf8.decode(resp.bodyBytes);
        final result = jsonDecode(bodyStr);
        return result['success'] == true;
      }
    } catch (e) {
      print('updateSignature 异常: $e');
    }
    return false;
  }
}


class AuthService {
  static const _baseUrl = 'http://127.0.0.1:8001/service'; // 替换成实际后端地址

  /// 向后端发送注册请求，成功返回 User 对象，失败抛出异常
  static Future<User> register({
    required String username,
    required String password,
    required String avatar,
    required String signature,
  }) async {
    final uri = Uri.parse('$_baseUrl/user/register');

    final payload = {
      "username": username,
      "password": password,
      "avatar": avatar,
      "signature": signature,
      // gmtCreate、gmtModified、isDeleted、id 由后端处理
    };

    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode(payload),
    );

    if (resp.statusCode == 200) {
      final bodyStr = utf8.decode(resp.bodyBytes);
      final body = jsonDecode(bodyStr);
      if (body['success'] == true) {
        return User.fromJson(body['data']['user']);
      } else {
        throw Exception("注册失败：${body['message']}");
      }
    } else {
      throw Exception('HTTP ${resp.statusCode}');
    }
  }
}