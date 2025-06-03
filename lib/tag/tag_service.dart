import 'dart:async';

/// 模拟从后端获取某个用户的标签（string 列表）
/// 真实项目请换成真正的 HTTP 请求
class TagService {
  /// 模拟异步请求，1 秒后返回一组标签
  static Future<List<String>> fetchUserTags(String userId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(seconds: 1));

    // 示例数据，实际请用 http.get 等方式拿到真实的 JSON，解析成 List<String>
    return [
      '活泼',
      '乐观',
      '爱运动',
      '技术宅',
      '美食家',
      '旅行达人',
      '摄影师',
      '阅读者',
      '电影迷',
      '程序员',
    ];
  }
}