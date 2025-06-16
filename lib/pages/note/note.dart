import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

// 动画泡泡模型
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

// 自定义Header图片遮罩: 单波Z弯形, 右侧更低，往下移一点
class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.85);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.95,
      0,
      size.height * 0.85,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class NotePage extends StatefulWidget {
  final Map<String, dynamic>? params;
  const NotePage({Key? key, this.params}) : super(key: key);
  @override
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<NotePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _rand = Random();
  final List<Bubble> _bubbles = [];
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _tagInputController = TextEditingController();

  // 预设标签列表
  final List<String> _presetTags = ['工作', '生活', '学习', '旅行', '心情'];

  String? _address;
  bool _locating = false;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 5; i++) {
      _bubbles.add(Bubble(
        position: Offset(_rand.nextDouble(), _rand.nextDouble()),
        velocity: Offset(_rand.nextDouble() * 0.002 - 0.001,
            _rand.nextDouble() * 0.002 - 0.001),
        size: 60 + _rand.nextDouble() * 40,
        color: Colors.primaries[_rand.nextInt(Colors.primaries.length)]
            .withOpacity(0.3),
      ));
    }
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )
      ..addListener(_moveBubbles)
      ..repeat();
    _getUserAddress();
  }

  void _moveBubbles() {
    setState(() {
      final w = context.size!.width;
      final h = context.size!.height;
      for (var b in _bubbles) {
        double x = b.position.dx * w + b.velocity.dx * w;
        double y = b.position.dy * h + b.velocity.dy * h;
        if (x < 0 || x > w - b.size) {
          b.velocity = Offset(-b.velocity.dx, b.velocity.dy);
        }
        if (y < 0 || y > h - b.size) {
          b.velocity = Offset(b.velocity.dx, -b.velocity.dy);
        }
        b.position =
            Offset(x.clamp(0, w - b.size) / w, y.clamp(0, h - b.size) / h);
      }
    });
  }

  Future<void> _getUserAddress() async {
    setState(() {
      _locating = true;
    });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _address = '定位服务未开启';
          _locating = false;
        });
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _address = '定位权限被拒绝';
            _locating = false;
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _address = '定位权限被永久拒绝';
          _locating = false;
        });
        return;
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('定位超时，请检查网络或定位设置');
      });
      _latitude = position.latitude;
      _longitude = position.longitude;
      print('当前经度: \\$_longitude, 纬度: \\$_latitude');
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('地址解析超时');
      });
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        setState(() {
          _address =
              '${p.country ?? ''}${p.administrativeArea ?? ''}${p.locality ?? ''}${p.street ?? ''}';
          _locating = false;
        });
      } else {
        setState(() {
          _address = '无法获取地址';
          _locating = false;
        });
      }
    } catch (e) {
      setState(() {
        _address = '定位失败: $e';
        _locating = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _noteController.dispose();
    _tagInputController.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagInputController.text.trim();
    if (tag.isNotEmpty && !_presetTags.contains(tag)) {
      setState(() {
        _presetTags.add(tag);
        _tagInputController.clear();
      });
    }
  }

  void _saveNote() {
    // TODO: 保存逻辑
    print('保存笔记时的经度: \\$_longitude, 纬度: \\$_latitude');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('笔记已保存')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(onPressed: _saveNote, icon: const Icon(Icons.save)),
        ],
      ),
      body: Stack(
        children: [
          // 渐变背景
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF6DEC8), Color(0xFFFAD5A5)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // 漂浮泡泡
          for (var b in _bubbles)
            Positioned(
              left: b.position.dx * w,
              top: b.position.dy * h,
              child: Container(
                width: b.size,
                height: b.size,
                decoration:
                    BoxDecoration(color: b.color, shape: BoxShape.circle),
              ),
            ),
          // 主内容滚动区
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 地址显示
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: Colors.redAccent, size: 20),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _locating ? '正在获取地址...' : (_address ?? '未获取到地址'),
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black54),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Header 图片与遮罩
                  ClipPath(
                    clipper: HeaderClipper(),
                    child: Image.asset(
                      'asset/images/4.jpeg',
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 标签输入框及添加按钮
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _tagInputController,
                            decoration: InputDecoration(
                              hintText: '添加标签',
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.4),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onSubmitted: (_) => _addTag(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _addTag,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.brown.shade700,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 预设标签展示
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _presetTags.map((tag) {
                        return Container(
                          constraints:
                              const BoxConstraints(minWidth: 60, maxWidth: 100),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            tag,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.robotoSlab(fontSize: 14),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 笔记输入框
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _noteController,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: '在这里输入你的笔记...',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
