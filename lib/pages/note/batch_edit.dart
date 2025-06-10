import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/note_item.dart';

// 动画泡泡模型
class Bubble {
  Offset position;
  Offset velocity;
  double size;
  Color color;
  Bubble({required this.position, required this.velocity, required this.size, required this.color});
}

// 自定义Header遮罩：单一大弧形 左高右低，遮罩往下移
class HeaderArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    // 右侧低点
    path.lineTo(size.width, size.height * 0.8);
    // 大弧形回到左侧高点
    path.quadraticBezierTo(
      size.width * 0.5, size.height * 1.0,
      0, size.height * 0.8,
    );
    path.close();
    return path;
  }
  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class BatchGeneratePage extends StatefulWidget {
  final List<NoteItem> notes;
  const BatchGeneratePage({Key? key, required this.notes}) : super(key: key);
  @override _BatchGeneratePageState createState() => _BatchGeneratePageState();
}

class _BatchGeneratePageState extends State<BatchGeneratePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _rand = Random();
  final List<Bubble> _bubbles = [];
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    // 初始化泡泡背景
    for (int i = 0; i < 5; i++) {
      _bubbles.add(Bubble(
        position: Offset(_rand.nextDouble(), _rand.nextDouble()),
        velocity: Offset(_rand.nextDouble()*0.002-0.001, _rand.nextDouble()*0.002-0.001),
        size: 60 + _rand.nextDouble()*40,
        color: Colors.primaries[_rand.nextInt(Colors.primaries.length)].withOpacity(0.3),
      ));
    }
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds:16))
      ..addListener(_moveBubbles)
      ..repeat();
    // 合并 notes 内容
    final combined = widget.notes.map((n) => '- \${n.title}: \${n.content}').join('\n');
    _contentController = TextEditingController(text: combined);
  }

  void _moveBubbles() {
    setState(() {
      final w = context.size!.width;
      final h = context.size!.height;
      for (var b in _bubbles) {
        double x = b.position.dx*w + b.velocity.dx*w;
        double y = b.position.dy*h + b.velocity.dy*h;
        if (x<0||x>w-b.size) b.velocity = Offset(-b.velocity.dx, b.velocity.dy);
        if (y<0||y>h-b.size) b.velocity = Offset(b.velocity.dx, -b.velocity.dy);
        b.position = Offset(x.clamp(0, w-b.size)/w, y.clamp(0, h-b.size)/h);
      }
    });
  }

  @override void dispose() {
    _controller.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveAll() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已保存整理内容')));
  }

  void _downloadAll() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('下载已开始')));
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
        title: Text('整理结果', style: GoogleFonts.robotoSlab()),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveAll),
          IconButton(icon: const Icon(Icons.download), onPressed: _downloadAll),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF6DEC8), Color(0xFFFAD5A5)],
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // 泡泡背景
          for (var b in _bubbles) Positioned(
            left: b.position.dx*w, top: b.position.dy*h,
            child: Container(width: b.size, height: b.size,
              decoration: BoxDecoration(color: b.color, shape: BoxShape.circle),),),
          // 主体内容
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ClipPath(
                    clipper: HeaderArcClipper(),
                    child: Image.asset(
                      'asset/images/5.jpeg', width: double.infinity,
                      height: 220, fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 整理后大块内容
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal:16),
                    child: TextField(
                      controller: _contentController,
                      maxLines: null,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      ),
                      style: TextStyle(fontSize: 16, height:1.5),
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
