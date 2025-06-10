import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TagBubble {
  final String text;
  Offset position;
  Offset velocity;
  double size;
  Color color;
  bool popped;

  TagBubble({
    required this.text,
    required this.position,
    required this.velocity,
    required this.size,
    required this.color,
    this.popped = false,
  });
}

class TagWallPage extends StatefulWidget {
  const TagWallPage({Key? key}) : super(key: key);

  @override
  _TagWallPageState createState() => _TagWallPageState();
}

class _TagWallPageState extends State<TagWallPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _rand = Random();
  final List<String> _tags = [
    'Flutter', 'Dart', 'UI', 'Animation', 'AI', 'UX',
    'OpenAI', 'Mobile', 'Cloud', 'Design', 'DevOps',
  ];
  final List<TagBubble> _bubbles = [];

  @override
  void initState() {
    super.initState();
    for (var tag in _tags) {
      _bubbles.add(TagBubble(
        text: tag,
        position: Offset(_rand.nextDouble(), _rand.nextDouble()),
        velocity: Offset(_rand.nextDouble() * 0.002 - 0.001, _rand.nextDouble() * 0.002 - 0.001),
        size: 60 + _rand.nextDouble() * 40,
        color: Colors.primaries[_rand.nextInt(Colors.primaries.length)].withOpacity(0.4 + _rand.nextDouble() * 0.3),
      ));
    }
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 16))
      ..addListener(_updateBubbles)
      ..repeat();
  }

  void _updateBubbles() {
    if (!mounted) return;
    setState(() {
      final w = context.size?.width ?? 1;
      final h = context.size?.height ?? 1;
      for (var b in _bubbles) {
        if (b.popped) continue;
        double x = b.position.dx * w + b.velocity.dx * w;
        double y = b.position.dy * h + b.velocity.dy * h;
        if (x < 0 || x > w - b.size) b.velocity = Offset(-b.velocity.dx, b.velocity.dy);
        if (y < 0 || y > h - b.size) b.velocity = Offset(b.velocity.dx, -b.velocity.dy);
        b.position = Offset((x.clamp(0, w - b.size) / w), (y.clamp(0, h - b.size) / h));
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _popBubble(int index) {
    setState(() {
      _bubbles[index].popped = true;
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _bubbles.removeAt(index);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF6DEC8), Color(0xFFFAD5A5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: _bubbles.asMap().entries.map((entry) {
            int i = entry.key;
            TagBubble b = entry.value;
            return AnimatedPositioned(
              duration: const Duration(milliseconds: 16),
              left: b.position.dx * MediaQuery.of(context).size.width,
              top: b.position.dy * MediaQuery.of(context).size.height,
              child: GestureDetector(
                onTap: () => _popBubble(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: b.popped ? 0 : b.size,
                  height: b.popped ? 0 : b.size,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: b.color,
                    borderRadius: BorderRadius.circular(b.popped ? 0 : b.size / 2),
                  ),
                  child: b.popped
                      ? null
                      : Text(
                    b.text,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.robotoSlab(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
