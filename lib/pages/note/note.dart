import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/login_service.dart';
import '../../services/note_service.dart';

// 泡泡模型
class Bubble {
  Offset position;
  Offset velocity;
  double size;
  Color color;
  Bubble({required this.position, required this.velocity, required this.size, required this.color});
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
      size.width / 2, size.height,
      size.width, size.height - 50,
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
  const NotePage({Key? key, this.userId}) : super(key: key);

  @override
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> with SingleTickerProviderStateMixin {
  final NoteService _noteService = NoteService();
  late AnimationController _controller;
  final List<Bubble> _bubbles = [];

  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _weatherController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String? _userId;
  bool _loading = false;
  String _currentAddress = '定位中…';
  Position? _currentPosition;
  String? _address;
  bool _locating = false;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 16))
      ..addListener(_moveBubbles)
      ..repeat();
    _getUserAddress();
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
  void _moveBubbles() {
    final size = MediaQuery.of(context).size;
    setState(() {
      for (var b in _bubbles) {
        final dx = (b.position.dx * size.width + b.velocity.dx).clamp(0, size.width);
        final dy = (b.position.dy * size.height + b.velocity.dy).clamp(0, size.height);
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
      // 若后端支持 tags，可加入列表逻辑
      _tagController.clear();
    }
  }

  Future<void> _saveNote() async {
    if (_userId == null) return;
    final content = _noteController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('笔记内容不能为空')));
      return;
    }

    setState(() => _loading = true);
    final noteId = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      final success = await NoteService.addNote(
        id: noteId,
        content: content,
        position: _positionController.text.trim(),
        userId: _userId!,
        weather: _weatherController.text.trim(),
        tags: [],
      );
      if (success) {
        Navigator.pop(context, true);
      } else {
        throw Exception('接口返回失败');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('保存失败: \$e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(onPressed: _saveNote, icon: Icon(Icons.save)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _currentAddress,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _tagController,
                            decoration: InputDecoration(
                              hintText: '添加标签',
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.4),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                            ),
                            onSubmitted: (_) => _addTag(),
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.add_circle, size: 30, color: Colors.white),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        SizedBox(height: 12),
                        TextField(
                          controller: _weatherController,
                          decoration: InputDecoration(
                            hintText: '天气',
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
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
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
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
        ],
      ),
    );
  }
}