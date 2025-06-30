import 'package:flutter/material.dart';
import 'dart:async';
import '../../../routes/route_name.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:crypto/crypto.dart';

/// APP入口全屏广告页面
class AdPage extends StatefulWidget {
  @override
  State<AdPage> createState() => _AdPageState();
}

class _AdPageState extends State<AdPage> {
  String _info = '';
  late Timer? _timer;
  int timeCount = 3;
  String _greeting = '';

  @override
  void initState() {
    super.initState();
    fetchGreeting();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// App广告页逻辑。
  void _initSplash() {
    const timeDur = Duration(seconds: 1); // 1秒

    _timer = Timer.periodic(timeDur, (Timer t) {
      setState(() {
        _info = "广告页，$timeCount 秒后跳转到主页";
      });
      if (timeCount <= 0) {
        _timer?.cancel();
        Navigator.pushReplacementNamed(context, RouteName.appMain);
        return;
      }
      timeCount--;
    });
  }

  Future<void> fetchGreeting() async {
    const appId = '2025598090';
    const appKey = 'dVKCtQXbkjCeyimY';
    const url = 'https://api-ai.vivo.com.cn/vivogpt/completions';
    const httpMethod = 'POST';
    const httpUri = '/vivogpt/completions';
    const canonicalQueryString = '';
    final timestamp =
        (DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000).toString();
    final nonce = Random().nextInt(1000000000).toString();
    final signedHeadersString =
        'x-ai-gateway-app-id:$appId\nx-ai-gateway-timestamp:$timestamp\nx-ai-gateway-nonce:$nonce';
    final signingString =
        '$httpMethod\n$httpUri\n$canonicalQueryString\n$appId\n$timestamp\n$nonce\n$signedHeadersString';
    final hmacSha256 = Hmac(sha256, utf8.encode(appKey));
    final digest = hmacSha256.convert(utf8.encode(signingString));
    final signature = base64Encode(digest.bytes);

    final headers = {
      'Content-Type': 'application/json',
      'X-AI-GATEWAY-APP-ID': appId,
      'X-AI-GATEWAY-TIMESTAMP': timestamp,
      'X-AI-GATEWAY-NONCE': nonce,
      'X-AI-GATEWAY-SIGNATURE': signature,
    };
    final body = jsonEncode({
      'model': 'vivo-BlueLM-TB-Pro',
      'messages': [
        {'role': 'user', 'content': '请生成一句温暖的中文问候语，适合在app开屏时显示。'}
      ]
    });
    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);
      print('蓝心API响应状态: \\${response.statusCode}');
      print('蓝心API响应内容: \\${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['result']?['choices']?[0]?['message']?['content'];
        if (content != null && content is String && content.trim().isNotEmpty) {
          setState(() {
            _greeting = content.trim();
          });
          _initSplash();
          return;
        }
      }
      setState(() {
        _greeting = '记录此刻，TagGlow为你点亮专属坐标';
      });
      _initSplash();
    } catch (e) {
      print('蓝心API调用异常: \\${e.toString()}');
      setState(() {
        _greeting = '记录此刻，TagGlow为你点亮专属坐标';
      });
      _initSplash();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 80), // 顶部留白，插画偏上
            Center(
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.3),
                ),
                alignment: Alignment.center,
                child: Image.asset(
                  'asset/images/kitty.png',
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              '记录此刻，TagGlow为你点亮专属坐标',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.black87,
                fontWeight: FontWeight.normal, // 不加粗
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget flotSkipWidget() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      right: 20,
      child: InkWell(
        onTap: () {
          Navigator.pushReplacementNamed(context, RouteName.appMain);
        },
        child: Container(
          alignment: Alignment.center,
          width: 70,
          height: 30,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(0, 2.0),
                blurRadius: 2.0,
              ),
            ],
          ),
          child: const Text('跳过', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
