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
  final String travelGuide;
  const BatchGeneratePage({Key? key, required this.travelGuide}) : super(key: key);

  @override
  _BatchGeneratePageState createState() => _BatchGeneratePageState();
}

class _BatchGeneratePageState extends State<BatchGeneratePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _contentController = TextEditingController();
  late AnimationController _bubbleController;
  final List<Bubble> _bubbles = [];

  @override
  void initState() {
    super.initState();
    // 将接口返回的 travelGuide 填入文本框
    _contentController.text = widget.travelGuide;

    // 初始化泡泡动画控制器及泡泡列表（保持原有逻辑）
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat();
  }

  @override
  void dispose() {
    _contentController.dispose();
    _bubbleController.dispose();
    super.dispose();
  }

  // 保存所有笔记逻辑
  void _saveAll() {
    // TODO: 实现保存
  }

  // 下载所有整理内容逻辑
  void _downloadAll() {
    // TODO: 实现下载
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery
        .of(context)
        .size
        .width;
    final h = MediaQuery
        .of(context)
        .size
        .height;
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
          // 背景渐变
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

          // 泡泡背景
          for (var b in _bubbles)
            Positioned(
              left: b.position.dx * w,
              top: b.position.dy * h,
              child: Container(
                width: b.size,
                height: b.size,
                decoration: BoxDecoration(
                  color: b.color,
                  shape: BoxShape.circle,
                ),
              ),
            ),

          // 主体内容
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ClipPath(
                    clipper: HeaderArcClipper(),
                    child: Image.asset(
                      'asset/images/5.jpeg',
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 整理后大块内容
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _contentController,
                      maxLines: null,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(fontSize: 16, height: 1.5),
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