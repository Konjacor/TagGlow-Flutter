import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import '../../services/login_service.dart'; // 获取 userId

class TagBubble {
  final String text;
  Offset position;
  Offset velocity;
  final Offset targetPos;
  final double radius;
  final Color color;
  final bool hasText;

  TagBubble({
    required this.text,
    required this.position,
    required this.velocity,
    required this.targetPos,
    required this.radius,
    required this.color,
  }) : hasText = text.trim().isNotEmpty;
}

class TagWallPage extends StatefulWidget {
  const TagWallPage({Key? key}) : super(key: key);
  @override
  _TagWallPageState createState() => _TagWallPageState();
}

class _TagWallPageState extends State<TagWallPage>
    with TickerProviderStateMixin {
  late AnimationController _flyController;
  late AnimationController _moveController;
  late AnimationController _breathController;
  late List<Animation<double>> _flyAnims;

  final List<TagBubble> _bubbles = [];
  final Random _rand = Random();
  final String _baseUrl = 'http://10.22.66.126:8001/service/tag';

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    // 获取登录用户
    final user = await LoginService.getCurrentUser();
    if (user == null) throw Exception('用户未登录');
    final userId = user.id;

    // 获取后端标签列表
    final tags = await _fetchTags(userId);
    _createBubbles(tags);
    _initAnimations();
  }

  Future<List<Map<String, dynamic>>> _fetchTags(String userId) async {
    final uri = Uri.parse('$_baseUrl/user/$userId');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final bodyStr = utf8.decode(response.bodyBytes);
      final List data = jsonDecode(bodyStr);
      // 直接返回列表
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('获取标签失败：${response.statusCode}');
    }
  }

  void _createBubbles(List<Map<String, dynamic>> tags) {
    // 按 type 区分内外层
    for (var tag in tags) {
      final content = tag['content'] as String;
      final type = tag['type'] as String;
      // 随机角度
      final angle = _rand.nextDouble() * 2 * pi;
      final normR = type == 'b'
          ? 0.25 + _rand.nextDouble() * 0.1
          : 0.45 + _rand.nextDouble() * 0.05;
      final target = Offset(0.5 + normR * cos(angle), 0.5 + normR * sin(angle));
      final radius = type == 'b'
          ? (20 + content.length * 5).clamp(30, 80).toDouble()
          : 15 + _rand.nextDouble() * 10;
      final color = type == 'b'
          ? Colors.primaries[_rand.nextInt(Colors.primaries.length)]
              .withOpacity(0.5)
          : Colors.grey.shade400.withOpacity(0.5);
      _bubbles.add(TagBubble(
        text: content,
        position: const Offset(0.5, 0.5),
        velocity: Offset.zero,
        targetPos: target,
        radius: radius,
        color: color,
      ));
    }
  }

  void _initAnimations() {
    final count = _bubbles.length;
    _flyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _flyAnims = List.generate(count, (i) {
      final start = (i / count) * 0.5;
      final end = (start + 0.5).clamp(0.0, 1.0).toDouble();
      return CurvedAnimation(
        parent: _flyController,
        curve: Interval(start, end, curve: Curves.easeOut),
      );
    });
    _flyController.forward();
    _flyController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // 确保精准到位
        for (var b in _bubbles) b.position = b.targetPos;
      }
    });

    _moveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )
      ..addListener(_updatePositions)
      ..repeat();

    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  void _updatePositions() {
    if (!_flyController.isCompleted) return;
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    for (var b in _bubbles) {
      if (b.velocity == Offset.zero) {
        final speed = b.hasText ? 0.002 : 0.0015;
        b.velocity = Offset(
          (_rand.nextDouble() * 2 - 1) * speed,
          (_rand.nextDouble() * 2 - 1) * speed,
        );
      }
      var newPos =
          Offset(b.position.dx + b.velocity.dx, b.position.dy + b.velocity.dy);
      final maxDist = b.hasText ? 0.35 : 0.5;
      final dx = newPos.dx - 0.5;
      final dy = newPos.dy - 0.5;
      final dist = sqrt(dx * dx + dy * dy);
      if (dist > maxDist) {
        final normal = Offset(dx / dist, dy / dist);
        final dot = b.velocity.dx * normal.dx + b.velocity.dy * normal.dy;
        b.velocity = Offset(
          b.velocity.dx - 2 * dot * normal.dx,
          b.velocity.dy - 2 * dot * normal.dy,
        );
        newPos = Offset(
            b.position.dx + b.velocity.dx, b.position.dy + b.velocity.dy);
      }
      b.position = newPos;
    }

    // 碰撞和分离
    for (int i = 0; i < _bubbles.length; i++) {
      for (int j = i + 1; j < _bubbles.length; j++) {
        final a = _bubbles[i];
        final c = _bubbles[j];
        final dx = (a.position.dx - c.position.dx) * w;
        final dy = (a.position.dy - c.position.dy) * h;
        final distance = sqrt(dx * dx + dy * dy);
        final minDist = a.radius + c.radius;
        if (distance < minDist && distance > 0) {
          final nx = dx / distance;
          final ny = dy / distance;
          final overlap = (minDist - distance) / 2;
          a.position = Offset(
            a.position.dx + (nx * overlap) / w,
            a.position.dy + (ny * overlap) / h,
          );
          c.position = Offset(
            c.position.dx - (nx * overlap) / w,
            c.position.dy - (ny * overlap) / h,
          );
          final tmp = a.velocity;
          a.velocity = c.velocity;
          c.velocity = tmp;
        }
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    _flyController.dispose();
    _moveController.dispose();
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      body: Stack(
        children: _bubbles.asMap().entries.map((entry) {
          final i = entry.key;
          final b = entry.value;
          return AnimatedBuilder(
            animation: Listenable.merge([_flyController, _breathController]),
            builder: (context, _) {
              final t = _flyAnims[i].value;
              final xNorm = _flyController.isCompleted
                  ? b.position.dx
                  : (0.5 + (b.targetPos.dx - 0.5) * t);
              final yNorm = _flyController.isCompleted
                  ? b.position.dy
                  : (0.5 + (b.targetPos.dy - 0.5) * t);
              final px = xNorm * size.width;
              final py = yNorm * size.height;
              final scale = _breathController.value * 0.2 + 0.9;

              return Positioned(
                left: px - b.radius * (b.hasText ? 1.5 : 2) / 2,
                top: py - b.radius / 2,
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: b.hasText ? null : b.radius * 2,
                    height: b.radius,
                    padding: b.hasText
                        ? EdgeInsets.symmetric(horizontal: b.radius * 0.5)
                        : null,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: b.color,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: b.color.withOpacity(0.4),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: b.hasText
                        ? Text(
                            b.text,
                            style: GoogleFonts.robotoSlab(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : null,
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
