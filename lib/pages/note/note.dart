import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/login_service.dart';
import '../../services/note_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geocoding/geocoding.dart' as geocoding;
import '../../utils/tool/sp_util.dart';
import '../../routes/route_name.dart'; // 确保引入

// 泡泡模型
class Bubble {
  Offset position;
  Offset velocity;
  double size;
  Color color;
  Bubble(
      {required this.position,
      required this.velocity,
      required this.size,
      required this.color});
}

// 绘制泡泡
class BubblePainter extends CustomPainter {
  final List<Bubble> bubbles;
  BubblePainter(this.bubbles);
  @override
  void paint(Canvas canvas, Size size) {
    for (var b in bubbles) {
      final paint = Paint()..color = b.color;
      final x = b.position.dx * size.width;
      final y = b.position.dy * size.height;
      canvas.drawCircle(Offset(x, y), b.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 自定义Header遮罩
class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 50,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class NotePage extends StatefulWidget {
  final String? userId; // 可通过构造传入
  final int? classificationId; // 新增：主题ID
  const NotePage({Key? key, this.userId, this.classificationId})
      : super(key: key);

  @override
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<NotePage>
    with SingleTickerProviderStateMixin {
  final NoteService _noteService = NoteService();
  late AnimationController _controller;
  final List<Bubble> _bubbles = [];

  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _weatherController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String? _userId;
  bool _loading = false;
  double? _latitude;
  double? _longitude;
  String _address = '';
  List<String> _tags = []; // 用于存储标签

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 16))
          ..addListener(_moveBubbles)
          ..repeat();
    _init();
  }

  Future<void> _init() async {
    // 拿到当前用户
    final user = await LoginService.getCurrentUser();
    if (user == null) {
      throw Exception('用户未登录');
    }
    _userId = user.id;

    // 优先用 geolocator 获取经纬度
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('定位服务未开启');
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('定位权限被拒绝');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('定位权限永久被拒绝');
      }
      Position pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _latitude = pos.latitude;
      _longitude = pos.longitude;
      print('获取到的经纬度: 经度: \\${_longitude}, 纬度: \\${_latitude}');
      _positionController.text = '';
      // 优先用 geocoding 本地逆地理编码
      await _getAddressFromGeocoding(_latitude!, _longitude!);
    } catch (e) {
      debugPrint('geolocator定位失败: $e');
      // 获取位置（后端IP定位，可能为空）
      try {
        final loc = await _noteService.getLocation();
        _positionController.text = '';
        _address = '\\${loc['country']}\\${loc['province']} \\${loc['city']}';
      } catch (e) {
        debugPrint('获取位置失败: $e');
        _positionController.text = '';
        _address = '定位失败';
      }
    }

    // 如果有主题ID，则获取默认AI标签
    if (widget.classificationId != null) {
      try {
        print('正在为主题ID ${widget.classificationId} 获取默认AI标签...');
        final defaultTags = await NoteService.getNoteDefaultAiTag(
          userId: _userId!,
          position: _address.isNotEmpty ? _address : '未知',
          classification: widget.classificationId!,
        );
        // 解析并设置AI标签
        setState(() {
          _tags = defaultTags
              .split(RegExp(r'[#\n]'))
              .where((s) => s.isNotEmpty)
              .toList();
        });
        print('默认AI标签获取成功: $defaultTags');
      } catch (e) {
        debugPrint('获取默认AI标签失败: $e');
        // 可以在这里给用户一个提示，比如用SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('获取推荐标签失败: $e')),
        );
      }
    }

    // 获取天气
    try {
      final w = await _noteService.getWeather();
      _weatherController.text = w;
    } catch (e) {
      debugPrint('获取天气失败: $e');
    }

    // 刷新页面
    setState(() {});
  }

  Future<void> _getAddressFromGeocoding(double lat, double lng) async {
    try {
      final placemarks = await geocoding.placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        _address = [
          p.country,
          p.administrativeArea,
          p.locality,
          p.street,
          p.name
        ].where((e) => e != null && e.isNotEmpty).join(' ');
        _positionController.text = _address;
      } else {
        _address = '未能获取详细地址';
        _positionController.text = _address;
      }
    } catch (e) {
      debugPrint('本地逆地理失败: $e');
      // 降级用高德API
      await _getAddressFromLatLng(lat, lng);
    }
  }

  Future<void> _getAddressFromLatLng(double lat, double lng) async {
    try {
      // 这里用高德逆地理API（需替换为你自己的key）
      final apiKey = '你的高德Key';
      final url =
          'https://restapi.amap.com/v3/geocode/regeo?location=\\$lng,\\$lat&key=\\$apiKey&radius=1000&extensions=base';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final addr = data['regeocode']?['formatted_address'] ?? '';
        _address = addr.isNotEmpty ? addr : '未能获取详细地址';
        _positionController.text = _address;
      } else {
        _address = '逆地理编码失败';
        _positionController.text = _address;
      }
    } catch (e) {
      _address = '逆地理编码异常';
      _positionController.text = _address;
    }
  }

  void _moveBubbles() {
    final size = MediaQuery.of(context).size;
    setState(() {
      for (var b in _bubbles) {
        final dx =
            (b.position.dx * size.width + b.velocity.dx).clamp(0, size.width);
        final dy =
            (b.position.dy * size.height + b.velocity.dy).clamp(0, size.height);
        b.position = Offset(dx / size.width, dy / size.height);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _tagController.dispose();
    _positionController.dispose();
    _weatherController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  Future<void> _saveNote() async {
    if (_userId == null) return;
    final content = _noteController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('笔记内容不能为空')));
      return;
    }
    setState(() {
      _loading = true;
    });
    try {
      final response = await NoteService.saveNote(
        content: _noteController.text,
        position: _address,
        userId: _userId!,
        weather: _weatherController.text.trim(),
        tags: _tags,
        classificationId: widget.classificationId,
      );

      // 调试：打印完整的后端响应
      print('【后端响应】: $response');

      setState(() {
        _loading = false;
      });

      // 保存成功后，显示AI回复对话框
      await showDialog(
        context: context,
        barrierDismissible: false, // 用户必须点击按钮才能关闭
        builder: (BuildContext context) {
          // 修正：从 response['data']['aiReply'] 获取AI回复
          final aiReply = response['data']?['aiReply'] as String? ?? '笔记已成功保存！';

          return AlertDialog(
            title: Text('AI 小助手'),
            content: SingleChildScrollView(
              // 使用可滚动视图以防内容过长
              child: Text(aiReply.isNotEmpty ? aiReply : '笔记已成功保存！'),
            ),
            actions: [
              TextButton(
                child: Text('好的'),
                onPressed: () {
                  // 修正：使用刚刚注册好的 noteList 路由
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    RouteName.noteList,
                    (route) => route.isFirst, // 跳转到列表页，并保留首页
                  );
                },
              ),
            ],
          );
        },
      );

      // Navigator.pop(context); // 确保这行是注释掉或者移除的
    } catch (e) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('保存出错: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // 增加加载状态判断，防止重复点击
          IconButton(
            icon: Icon(Icons.save, color: Colors.white),
            onPressed: _loading ? null : _saveNote,
          ),
        ],
      ),
      body: Stack(
        children: [
          CustomPaint(size: size, painter: BubblePainter(_bubbles)),
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ClipPath(
                    clipper: HeaderClipper(),
                    child: Image.asset(
                      'asset/images/4.jpeg',
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 标签展示区域
                        if (_tags.isNotEmpty)
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 4.0,
                            children: _tags
                                .map((tag) => Chip(
                                      label: Text(tag),
                                      onDeleted: () {
                                        setState(() {
                                          _tags.remove(tag);
                                        });
                                      },
                                      deleteIconColor: Colors.red.shade300,
                                      backgroundColor:
                                          Colors.white.withOpacity(0.8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        side: BorderSide(
                                            color: Colors.grey.shade300),
                                      ),
                                    ))
                                .toList(),
                          ),
                        if (_tags.isNotEmpty) const SizedBox(height: 12),
                        // 标签输入区域
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _tagController,
                                decoration: InputDecoration(
                                  hintText: '添加自定义标签',
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.4),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide.none),
                                ),
                                onSubmitted: (_) => _addTag(),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add_circle,
                                  size: 30, color: Colors.white),
                              onPressed: _addTag,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        TextField(
                          controller: _positionController,
                          decoration: InputDecoration(
                            hintText: '位置',
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none),
                            prefixIcon: Icon(Icons.location_on,
                                color: Colors.pinkAccent),
                          ),
                        ),
                        SizedBox(height: 12),
                        TextField(
                          controller: _weatherController,
                          decoration: InputDecoration(
                            hintText: '天气',
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none),
                          ),
                        ),
                        SizedBox(height: 12),
                        TextField(
                          controller: _noteController,
                          maxLines: 8,
                          decoration: InputDecoration(
                            hintText: '在这里输入你的笔记...',
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // 添加全局加载动画
          if (_loading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
