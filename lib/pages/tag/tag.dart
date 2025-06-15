import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TagNode {
  final String text;
  Offset position;
  Offset targetPosition;
  double z;
  double targetZ;
  double size;
  Color color;
  double opacity;
  double scale;
  bool isActive;
  bool showLabel;
  bool isHovered;
  double pulsePhase;
  double glowIntensity;

  TagNode({
    required this.text,
    required this.position,
    required this.targetPosition,
    required this.z,
    required this.targetZ,
    required this.size,
    required this.color,
    this.opacity = 0.0,
    this.scale = 0.0,
    this.isActive = false,
    this.showLabel = false,
    this.isHovered = false,
    this.pulsePhase = 0.0,
    this.glowIntensity = 0.0,
  });
}

class StarTunnelPainter extends CustomPainter {
  final List<TagNode> nodes;
  final double animationValue;
  final Size size;
  final bool flyIn;

  StarTunnelPainter({
    required this.nodes,
    required this.animationValue,
    required this.size,
    required this.flyIn,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var node in nodes) {
      if (!node.isActive) continue;
      // 透视投影
      double perspective = 1.0 / (0.7 + node.z);
      double x =
          (node.position.dx - 0.5) * size.width * perspective + size.width / 2;
      double y = (node.position.dy - 0.5) * size.height * perspective +
          size.height / 2;
      double r = node.size * node.scale * perspective;
      // 呼吸发光
      final glowPaint = Paint()
        ..color = node.color
            .withOpacity(0.18 * node.glowIntensity + (node.isHovered ? 0.3 : 0))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0);
      canvas.drawCircle(Offset(x, y), r * 1.7, glowPaint);
      // 节点本体
      final nodePaint = Paint()
        ..color =
            node.color.withOpacity(node.opacity + (node.isHovered ? 0.2 : 0))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y),
          r * (node.showLabel || node.isHovered ? 1.3 : 1.0), nodePaint);
      // 显示标签内容
      if (node.showLabel || node.isHovered) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: node.text,
            style: GoogleFonts.robotoSlab(
              fontSize: 16 * node.scale * perspective,
              color: Colors.white.withOpacity(node.opacity),
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        double textX = x - textPainter.width / 2;
        double textY = y - r * 1.3 - textPainter.height;
        // 边界修正
        if (textX < 0) textX = 0;
        if (textX + textPainter.width > size.width)
          textX = size.width - textPainter.width;
        if (textY < 0) textY = y + r * 1.3;
        if (textY + textPainter.height > size.height)
          textY = size.height - textPainter.height;
        textPainter.paint(
          canvas,
          Offset(textX, textY),
        );
      }
    }
  }

  @override
  bool shouldRepaint(StarTunnelPainter oldDelegate) => true;
}

class TagWallPage extends StatefulWidget {
  const TagWallPage({Key? key}) : super(key: key);
  @override
  _TagWallPageState createState() => _TagWallPageState();
}

class _TagWallPageState extends State<TagWallPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final Random _rand = Random();
  final List<TagNode> _nodes = [];
  bool _isFlyIn = true;
  static const int minNodes = 50;
  static const int maxNodes = 80;
  static const int labelNodes = 10;
  final List<Color> _coldColors = [
    Colors.white,
    Color(0xFFB0C4DE), // LightSteelBlue
    Color(0xFF87CEEB), // SkyBlue
    Color(0xFFB0E0E6), // PowderBlue
    Color(0xFFB8B8B8), // Gray
    Color(0xFF6CA0DC), // Soft Blue
    Color(0xFFB4D2E7), // Pale Blue
  ];
  final List<String> _diaryTags = [
    '清晨的阳光',
    '咖啡香气',
    '夜晚的思考',
    '朋友的问候',
    '下雨的午后',
    '独自散步',
    '书页的声音',
    '温暖的灯光',
    '远方的家',
    '偶遇的微笑',
    '失眠的夜',
    '新发现的歌',
    '写下的心情',
    '安静的时刻',
    '城市的霓虹',
    '回忆的片段',
    '期待明天',
    '简单的快乐',
    '成长的烦恼',
    '温柔的风',
    '午后的慵懒',
    '陌生的街道',
    '熟悉的旋律',
    '静静发呆',
    '心跳的瞬间',
    '温暖的拥抱',
    '遗憾的告别',
    '闪烁的星光',
    '夜色温柔',
    '晨跑的脚步',
    '雨后的清新',
    '童年的味道',
    '远行的列车',
    '午餐的味道',
    '晚霞的余晖',
    '夜空的星辰',
    '偶然的邂逅',
    '温柔的晚安',
    '清新的空气',
    '静谧的湖面',
    '初雪的惊喜',
    '夏日的蝉鸣',
    '秋天的落叶',
    '冬日的暖阳',
    '节日的烟火',
    '旅行的照片',
    '写给自己的信',
    '久违的重逢',
    '心中的梦想',
    '努力的日子',
    '安静的午后',
    '温柔的目光',
    '夜晚的灯火',
    '晨曦的微光',
    '午后的阳光',
    '夜色的温度',
    '静静的守候',
    '温暖的回忆',
    '远方的祝福',
    '熟悉的背影',
    '偶遇的惊喜',
    '成长的足迹',
    '温柔的守护',
    '夜色的静谧',
    '晨光的希望',
    '午后的微风',
    '夜晚的星空',
    '温暖的手心',
    '安静的夜晚',
    '远方的牵挂',
    '熟悉的味道',
    '静静的陪伴',
    '温柔的声音',
    '夜色的温柔',
    '晨曦的希望',
    '午后的咖啡',
    '夜晚的安静',
    '温暖的笑容',
    '远方的思念',
    '熟悉的气息',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    int nodeCount = minNodes + _rand.nextInt(maxNodes - minNodes + 1);
    List<int> labelIndexes = [];
    while (labelIndexes.length < labelNodes) {
      int idx = _rand.nextInt(nodeCount);
      if (!labelIndexes.contains(idx)) labelIndexes.add(idx);
    }
    List<String> tags = List.from(_diaryTags)..shuffle(_rand);
    // 均匀分布大节点，保证安全边距
    double safeMargin = 0.18; // 18% 边距
    double centerX = 0.5, centerY = 0.5;
    double maxR = 0.5 - safeMargin; // 最大半径，保证不会超出边界
    for (int i = 0; i < nodeCount; i++) {
      bool isLabel = labelIndexes.contains(i);
      double targetX, targetY;
      if (isLabel) {
        double angle = 2 * pi * labelIndexes.indexOf(i) / labelNodes;
        double r = maxR * (0.7 + 0.3 * _rand.nextDouble()); // 圆环内抖动，避免重叠
        targetX = centerX + r * cos(angle);
        targetY = centerY + r * sin(angle);
        // 限制在安全区
        targetX = targetX.clamp(safeMargin, 1 - safeMargin);
        targetY = targetY.clamp(safeMargin, 1 - safeMargin);
      } else {
        targetX = safeMargin + _rand.nextDouble() * (1 - 2 * safeMargin);
        targetY = safeMargin + _rand.nextDouble() * (1 - 2 * safeMargin);
      }
      final angle = _rand.nextDouble() * 2 * pi;
      final radius = 1.5 + _rand.nextDouble() * 0.5;
      final startX = 0.5 + cos(angle) * radius;
      final startY = 0.5 + sin(angle) * radius;
      final z = 2.5 + _rand.nextDouble() * 1.5;
      final color = _coldColors[_rand.nextInt(_coldColors.length)];
      _nodes.add(TagNode(
        text: tags[i % tags.length],
        position: Offset(startX, startY),
        targetPosition: Offset(targetX, targetY),
        z: z,
        targetZ: 0.0,
        size:
            isLabel ? 18 + _rand.nextDouble() * 8 : 8 + _rand.nextDouble() * 4,
        color: color,
        showLabel: isLabel,
        isActive: true,
        pulsePhase: _rand.nextDouble() * 2 * pi,
      ));
    }
    _controller.forward().then((_) {
      setState(() {
        _isFlyIn = false;
      });
      _startBreathAnimation();
    });
  }

  void _startBreathAnimation() {
    _controller.duration = const Duration(seconds: 2);
    _controller.repeat();
  }

  void _onNodeHover(int index, bool hover) {
    setState(() {
      _nodes[index].isHovered = hover;
    });
  }

  void _onNodeTap(int index) {
    setState(() {
      if (_nodes[index].showLabel && _isInitialLabel(index)) {
        // 初始大节点点击无效
        return;
      }
      if (_nodes[index].showLabel) {
        // 只允许点击后显示内容的小点再次点击才隐藏
        _nodes[index].showLabel = false;
        _nodes[index].isHovered = false;
      } else {
        // 只允许一个小点被激活
        for (int i = 0; i < _nodes.length; i++) {
          if (!_isInitialLabel(i)) {
            _nodes[i].showLabel = false;
            _nodes[i].isHovered = false;
          }
        }
        _nodes[index].showLabel = true;
        _nodes[index].isHovered = true;
      }
    });
  }

  bool _isInitialLabel(int index) {
    // 初始大节点
    return _nodes[index].showLabel && _nodes[index].size > 16;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.2),
            radius: 1.2,
            colors: [
              Color(0xFF181C2A),
              Color(0xFF232946),
              Color(0xFF3A506B),
              Color(0xFFB0C4DE),
              Color(0xFF181C2A),
            ],
            stops: [0.0, 0.3, 0.6, 0.85, 1.0],
          ),
        ),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            for (var node in _nodes) {
              if (_isFlyIn) {
                final t = _animation.value;
                node.position = Offset(
                  node.position.dx +
                      (node.targetPosition.dx - node.position.dx) * t,
                  node.position.dy +
                      (node.targetPosition.dy - node.position.dy) * t,
                );
                node.z = node.z + (node.targetZ - node.z) * t;
                node.opacity = t;
                node.scale = 0.5 + 0.5 * t;
              } else {
                node.z = 0.0;
                node.opacity = 1.0;
                node.scale = 0.9 +
                    0.1 *
                        (sin(node.pulsePhase + _animation.value * 2 * pi) + 1) /
                        2;
                node.pulsePhase += 0.04;
                node.glowIntensity = (sin(node.pulsePhase) + 1) / 2;
              }
            }
            return Stack(
              children: [
                CustomPaint(
                  painter: StarTunnelPainter(
                    nodes: _nodes,
                    animationValue: _animation.value,
                    size: size,
                    flyIn: _isFlyIn,
                  ),
                  size: Size.infinite,
                ),
                ..._nodes.asMap().entries.map((entry) {
                  int i = entry.key;
                  TagNode node = entry.value;
                  // 透视投影
                  double perspective = 1.0 / (0.7 + node.z);
                  double x =
                      (node.position.dx - 0.5) * size.width * perspective +
                          size.width / 2;
                  double y =
                      (node.position.dy - 0.5) * size.height * perspective +
                          size.height / 2;
                  double r = node.size * node.scale * perspective;
                  return Positioned(
                    left: x - r,
                    top: y - r,
                    width: r * 2,
                    height: r * 2,
                    child: MouseRegion(
                      onEnter: (_) => _onNodeHover(i, true),
                      onExit: (_) => _onNodeHover(i, false),
                      child: GestureDetector(
                        onTap: () => _onNodeTap(i),
                        child: Container(
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            );
          },
        ),
      ),
    );
  }
}
