import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<Map<String, String>> _covers = const [
    {'title': '甜蜜小憩', 'subtitle': '时光静好，与笔记有你'},
    {'title': '奇思妙想', 'subtitle': '每一刻灵感都值得被收藏'},
    {'title': '星空漫步', 'subtitle': '记录夜晚的闪烁与安宁'},
  ];

  late final PageController _pageController;
  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.75);
  }
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: const Text('MyNotes'), centerTitle: true),
      body: Stack(
        children: [
          // 背景层：宽度 = 屏宽 * 页数
          AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              final page = (_pageController.hasClients && _pageController.page != null)
                  ? _pageController.page!.clamp(0.0, (_covers.length - 1).toDouble())
                  : 0.0;
              final dx = -page * 3;
              return Transform.translate(
                offset: Offset(dx, 0),
                child: child,
              );
            },
            child: Container(
              width: screenW * _covers.length,
              height: MediaQuery.of(context).size.height,  // ← 指定高度为全屏高
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFFE0F0),
                    Color(0xFFE0F7FF),
                    Color(0xFFF0E0FF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // 卡片层
          Center(
            child: SizedBox(
              height: 300,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _covers.length,
                itemBuilder: (context, index) {
                  final delta = (_pageController.page ?? index) - index;
                  final scale = (1 - delta.abs() * 0.2).clamp(0.8, 1.0);
                  return Transform.scale(
                    scale: scale,
                    child: _buildCoverCard(_covers[index]),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      // … 底栏 & FAB 保持不变
    );
  }

  Widget _buildCoverCard(Map<String, String> cover) {
    final colors = [Colors.pink[100], Colors.lightBlue[100], Colors.purple[100]];
    final idx = _covers.indexOf(cover);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      color: colors[idx],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              cover['title']!,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              cover['subtitle']!,
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
