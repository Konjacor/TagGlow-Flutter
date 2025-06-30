import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import '../../services/login_service.dart'; // 获取 userId
import 'dart:ui' as ui;

// 向量归一化
extension OffsetExtension on Offset {
  Offset get normalized {
    final length = distance;
    return length > 0 ? this / length : this;
  }
}

class TagBubble {
  String text;
  Offset position;
  Offset velocity;
  final Offset targetPos;
  double radius;
  Color color;
  bool hasText;
  double rotationAngle;
  double orbitFactor;
  bool isSelected;
  double pulseValue;
  bool isDragging;
  Offset dragStartPosition;
  Offset dragStartVelocity;
  DateTime? lastTapTime;

  TagBubble({
    required this.text,
    required this.position,
    required this.velocity,
    required this.targetPos,
    required this.radius,
    required this.color,
    this.rotationAngle = 0,
    this.orbitFactor = 1.0,
    this.isSelected = false,
    this.pulseValue = 0.0,
    this.isDragging = false,
    this.dragStartPosition = Offset.zero,
    this.dragStartVelocity = Offset.zero,
  }) : hasText = text.trim().isNotEmpty;
}

class TagWallPage extends StatefulWidget {
  const TagWallPage({super.key});
  @override
  _TagWallPageState createState() => _TagWallPageState();
}

class _TagWallPageState extends State<TagWallPage>
    with TickerProviderStateMixin {
 AnimationController? _flyController;
 late AnimationController _moveController;
 late AnimationController _breathController;
 late AnimationController _pulseController;
 late List<Animation<double>> _flyAnims;
 // 添加变换控制器
 late TransformationController _transformationController;
 //添加镜头缩放动画控制器
 late AnimationController _cameraController;
 late Animation<double> _cameraAnimation;
 bool _isCameraAnimationActive = true; // 摄像机动画是否激活

  final List<TagBubble> _bubbles = [];
  final Random _rand = Random();
  //final String _baseUrl = 'http://192.168.3.9:8001/service/tag';
  final String _baseUrl = 'http://10.22.75.56:8001/service/tag';
  // final List<String> _tagPool = [
  //   "创意", "灵感", "梦想", "探索", "科技",
  //   "艺术", "音乐", "旅行", "美食", "学习",
  //   "成长", "挑战", "平衡", "健康", "友谊",
  //   "家庭", "成功", "反思", "未来", "当下","北海道","佛罗里达"
  // ];
 List<String> _tagPool = [];

 // 添加虚拟画布尺寸（2倍屏幕）
 final double _virtualWidth = 2.0;
 final double _virtualHeight = 2.0;

 // 添加背景拖动锁定标志
 bool _isBackgroundDragging = true;

  //关于拖动效果的变量
  TagBubble? _draggingBubble;
  Offset _dragStartGlobal = Offset.zero;
  double _dragStartTime = 0;
 // 添加拖动速度跟踪
 final List<Offset> _dragPositions = [];
 final List<DateTime> _dragTimes = [];
 static const int _maxDragSamples = 5; // 保留最近5个位置样本

 DateTime? _lastUpdate;

 // 预先创建占位气泡
 void _createPlaceholderBubbles() {
   // 使用默认标签作为占位符
   final defaultTags = [
     "创意", "灵感", "梦想", "探索", "科技",
     "艺术", "音乐", "旅行", "美食", "学习",
   ];
   for (int i = 0; i < 10; i++) {
     final content = defaultTags[i % defaultTags.length];
     _bubbles.add(TagBubble(
       text: content,
       position: const Offset(0.5, 0.5),
       velocity: Offset.zero,
       targetPos: Offset(
           _rand.nextDouble() * _virtualWidth,
           _rand.nextDouble() * _virtualHeight
       ),
       radius: 30.0,
       color: Colors.grey.withOpacity(0.3),
       orbitFactor: 1.0,
     ));
   }
 }

 // 单独拆分预加载动画
 void _initPreloadAnimations() {
   // 提前初始化不需要气泡数据的控制器
   _breathController = AnimationController(
     vsync: this,
     duration: const Duration(milliseconds: 5000),
   )..repeat(reverse: true);

   _pulseController = AnimationController(
     vsync: this,
     duration: const Duration(milliseconds: 500),
   );
   // 运动控制器
   _moveController = AnimationController(
     vsync: this,
     duration: const Duration(milliseconds: 16),
   )..addListener(_updatePositions)..repeat();

   // 为占位气泡创建初始动画
   if (_bubbles.isNotEmpty) {
     _initFlyController();
   }
 }

 void _initFlyController() {
   _flyController?.dispose();

   final count = _bubbles.length;
   _flyController = AnimationController(
     vsync: this,
     duration: const Duration(milliseconds: 1500), // 延长动画时间
   );

   _flyAnims = List.generate(count, (i) {
     // 随机延迟 (0-0.5秒)
     final delay = _rand.nextDouble() * 0.5;
     // 缩放动画曲线
     final curve = Curves.easeOutBack;

     return TweenSequence<double>([
       TweenSequenceItem(tween: ConstantTween(0.0), weight: delay * 100),
       TweenSequenceItem(
           tween: Tween(begin: 0.0, end: 1.0)
               .chain(CurveTween(curve: curve)),
           weight: 100
       ),
     ]).animate(
       CurvedAnimation(
         parent: _flyController!,
         curve: Interval(0.0, 1.0),
       ),
     );
   });

   _flyController!.forward();
   _flyController!.addStatusListener((status) {
     if (status == AnimationStatus.completed) {
       // 动画完成后设置气泡到目标位置
       for (var bubble in _bubbles) {
         bubble.position = bubble.targetPos;
       }
       // 触发一次位置更新
       if (mounted) setState(() {});
     }
   });
 }

 void _createRealBubbles(List<Map<String, dynamic>> tags) {
   _bubbles.clear(); // 清除占位气泡

   // 限制标签数量为30个
   final limitedTags = tags.length > 30 ? tags.take(30).toList() : tags;

   // 按 type 区分内外层
   for (var tag in limitedTags) {
     final content = tag['content'] as String;
     final type = tag['type'] as String;
     // 添加随机速度（方向随机，速度大小在0.001-0.003之间）
     final speed = 0.001 + _rand.nextDouble() * 0.002;
     final angle = _rand.nextDouble() * 2 * pi;// 随机角度
     final velocity = Offset(cos(angle) * speed, sin(angle) * speed);
     final orbitFactor = 0.7 + _rand.nextDouble() * 0.6;
     final normR = type == 'b'
         ? 0.25 + _rand.nextDouble() * 0.1
         : 0.45 + _rand.nextDouble() * 0.05;
     // final target = Offset(
     //     0.5 + normR * cos(angle) * orbitFactor,
     //     0.5 + normR * sin(angle) * orbitFactor
     // );
     // 修改初始位置范围为整个虚拟空间
     final target = Offset(
         _rand.nextDouble() * _virtualWidth, // 使用虚拟宽度
         _rand.nextDouble() * _virtualHeight // 使用虚拟高度
     );

     // 圆形半径计算公式
     final baseRadius = type == 'b' ? 30.0 : 20.0;
     final radius = type == 'b'
         ? (baseRadius + sqrt(content.length) * 3).clamp(25, 50).toDouble()
         : baseRadius + _rand.nextDouble() * 5;

     final color = type == 'b'
         ? HSLColor.fromAHSL(
         1.0,
         _rand.nextDouble() * 360, // 随机色相
         0.8 + _rand.nextDouble() * 0.2, // 饱和度在 0.7-1.0 之间
         0.7 + _rand.nextDouble() * 0.2 // 亮度在 0.5-0.8 之间
     ).toColor().withOpacity(0.9)
         : HSLColor.fromAHSL(
         1.0,
         _rand.nextDouble() * 360,
         0.5 + _rand.nextDouble() * 0.3,
         0.7 + _rand.nextDouble() * 0.2
     ).toColor().withOpacity(0.9);
     // : Colors.grey.shade400.withOpacity(0.6);

     _bubbles.add(TagBubble(
       text: content,
       position: const Offset(0.5, 0.5),
       // velocity: Offset.zero,
       velocity: velocity,// 使用随机速度
       targetPos: target,
       radius: radius,
       color: color,
       rotationAngle: _rand.nextDouble() * pi,
       orbitFactor: orbitFactor,
     ));
   }
 }

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();

    // 初始化摄像机缩放动画
    _cameraController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3000), // 3秒缩放动画
    );

    _cameraAnimation = Tween<double>(
    begin: 0.5, // 初始缩放比例（看到更多气泡）
    end: 1.0,   // 最终缩放比例（正常大小）
    ).animate(CurvedAnimation(
    parent: _cameraController,
    curve: Curves.easeInOut,
    ));

    // 监听动画完成
    _cameraController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isCameraAnimationActive = false; // 动画完成后停止自动控制
        });
      }
    });

    _createPlaceholderBubbles();
    _initPreloadAnimations();
    _setup();


  }

  Future<void> _setup() async {
    // 获取登录用户
    final user = await LoginService.getCurrentUser();
    if (user == null) throw Exception('用户未登录');
    final userId = user.id;

    // 获取后端标签列表
    var tags = await _fetchTags(userId);
    // 提取所有标签内容到 _tagPool
    _tagPool = tags.map((tag) => tag['content'] as String).toList();
    // if (tags.length > 30) {
    //   // 截取前 size 个元素
    //   tags = tags.sublist(0, 30);
    // }
    // 处理 tags 长度，使其始终为 30 个元素
    // List<String> adjustedTags = _adjustTagsToSize(tags.cast<String>(), size: 30);
    // _createBubbles(tags);
    _initAnimations();
    // 更新状态时保留现有动画状态
    setState(() {
      _createRealBubbles(tags);
      _initFlyController(); // 为真实气泡重新初始化动画
      _restartMoveController();
    });

    // 延迟启动摄像机缩放动画（等待气泡入场动画开始）
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _cameraController.forward();
      }
    });

  }

 // 新增：重启运动控制器
 void _restartMoveController() {
   _moveController.dispose();
   _moveController = AnimationController(
     vsync: this,
     duration: const Duration(milliseconds: 16),
   )..addListener(_updatePositions)..repeat();
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
      final orbitFactor = 0.7 + _rand.nextDouble() * 0.6;
      final normR = type == 'b'
          ? 0.25 + _rand.nextDouble() * 0.1
          : 0.45 + _rand.nextDouble() * 0.05;
      // final target = Offset(
      //     0.5 + normR * cos(angle) * orbitFactor,
      //     0.5 + normR * sin(angle) * orbitFactor
      // );
      // 修改初始位置范围为整个虚拟空间
      final target = Offset(
          _rand.nextDouble() * _virtualWidth, // 使用虚拟宽度
          _rand.nextDouble() * _virtualHeight // 使用虚拟高度
      );

      // 圆形半径计算公式
      final baseRadius = type == 'b' ? 30.0 : 20.0;
      final radius = type == 'b'
          ? (baseRadius + sqrt(content.length) * 3).clamp(25, 50).toDouble()
          : baseRadius + _rand.nextDouble() * 5;

      final color = type == 'b'
          ? HSLColor.fromAHSL(
          1.0,
          _rand.nextDouble() * 360, // 随机色相
          0.8 + _rand.nextDouble() * 0.2, // 饱和度在 0.7-1.0 之间
          0.7 + _rand.nextDouble() * 0.2 // 亮度在 0.5-0.8 之间
      ).toColor().withOpacity(0.9)
          : HSLColor.fromAHSL(
          1.0,
          _rand.nextDouble() * 360,
          0.5 + _rand.nextDouble() * 0.3,
          0.7 + _rand.nextDouble() * 0.2
      ).toColor().withOpacity(0.9);
          // : Colors.grey.shade400.withOpacity(0.6);

      _bubbles.add(TagBubble(
        text: content,
        position: const Offset(0.5, 0.5),
        velocity: Offset.zero,
        targetPos: target,
        radius: radius,
        color: color,
        rotationAngle: _rand.nextDouble() * pi,
        orbitFactor: orbitFactor,
      ));
    }
  }

  void _initAnimations() {
    final count = _bubbles.length;

    // 增强入场动画效果
    _flyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // 延长持续时间
    );

    _flyAnims = List.generate(count, (i) {
      final start = (i / count) * 0.5;
      final end = (start + 0.5).clamp(0.0, 1.0).toDouble();
      return TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 50), // 添加过冲效果
        TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50),
      ]).animate(
        CurvedAnimation(
          parent: _flyController!,
          curve: Interval(start, end, curve: Curves.easeOutBack),
        ),
      );
    });

    // 触发 UI 更新，确保 build() 使用最新的 _flyController
    if (mounted) setState(() {});

    _flyController!.forward();
    _flyController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        for (var b in _bubbles) {
          b.position = b.targetPos;
        }
      }
    });
  }

 Offset _calculateEnvironmentalForce(Offset position, int bubbleIndex) {
   // 方案1：向中心的微弱引力
   final center = Offset(_virtualWidth / 2, _virtualHeight / 2);
   final toCenter = center - position;
   final distance = toCenter.distance;
   final gravityStrength = 0.00001; // 很小的引力
   final gravity = distance > 0 ? toCenter.normalized * gravityStrength : Offset.zero;

   // 方案2：基于时间的轻微湍流
   final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
   final turbulence = Offset(
     sin(time * 0.5 + bubbleIndex * 0.1) * 0.00005,
     cos(time * 0.3 + bubbleIndex * 0.15) * 0.00005,
   );

   // 方案3：边界排斥力（让气泡避开边界）
   Offset boundaryRepulsion = Offset.zero;
   final margin = 0.1; // 边界排斥区域

   if (position.dx < margin) {
     boundaryRepulsion += Offset((margin - position.dx) * 0.0001, 0);
   } else if (position.dx > _virtualWidth - margin) {
     boundaryRepulsion += Offset((_virtualWidth - margin - position.dx) * 0.0001, 0);
   }

   if (position.dy < margin) {
     boundaryRepulsion += Offset(0, (margin - position.dy) * 0.0001);
   } else if (position.dy > _virtualHeight - margin) {
     boundaryRepulsion += Offset(0, (_virtualHeight - margin - position.dy) * 0.0001);
   }

   // 根据需要选择组合不同的力
   return gravity + turbulence + boundaryRepulsion;
   // return gravity + boundaryRepulsion;
 }
 void _updatePositions() {
   final size = MediaQuery.of(context).size;
   final w = size.width;
   final h = size.height;

   // 边界（归一化坐标）
   final screenLeft = 0.0;
   final screenRight = _virtualWidth;
   final screenTop = 0.0;
   final screenBottom = _virtualHeight;

   // 1. 更新位置
   for (int i = 0; i < _bubbles.length; i++) {
     final b = _bubbles[i];
     if (b.isDragging) continue;

     // 应用阻力（让速度逐渐减小）
     final dampingFactor = 0.995;
     b.velocity = b.velocity * dampingFactor;

     // 动态最低速度（根据气泡类型和大小调整）
     final baseMinSpeed = 0.0008;
     final sizeMultiplier = (b.radius / 40.0).clamp(0.8, 1.2); // 大气泡移动稍慢
     final minSpeed = baseMinSpeed * sizeMultiplier;

     final currentSpeed = b.velocity.distance;

     if (currentSpeed > 0 && currentSpeed < minSpeed) {
       // 当速度低于最低速度时，有几种策略：

       // 策略1：简单维持最低速度
       final direction = b.velocity.normalized;
       b.velocity = direction * minSpeed;

       // 策略2：添加轻微的随机扰动（让运动更自然）
       final perturbation = Offset(
         (_rand.nextDouble() - 0.5) * 0.0001,
         (_rand.nextDouble() - 0.5) * 0.0001,
       );
       b.velocity += perturbation;

     } else if (currentSpeed == 0) {
       // 策略3：给静止的气泡随机方向和速度
       final randomAngle = _rand.nextDouble() * 2 * pi;
       b.velocity = Offset(
         cos(randomAngle) * minSpeed,
         sin(randomAngle) * minSpeed,
       );
     }

     // // 策略4：添加环境力（可选 - 模拟风力或引力场）
     // // 可以根据气泡位置添加微小的环境力
     // final environmentalForce = _calculateEnvironmentalForce(b.position, i);
     // b.velocity += environmentalForce;

     // 应用速度更新位置
     b.position += b.velocity;

     // 边界碰撞检测与反弹
     if (b.position.dx - b.radius/w < screenLeft) {
       b.position = Offset(screenLeft + b.radius/w, b.position.dy);
       b.velocity = Offset(-b.velocity.dx * 0.8, b.velocity.dy);
     } else if (b.position.dx + b.radius/w > screenRight) {
       b.position = Offset(screenRight - b.radius/w, b.position.dy);
       b.velocity = Offset(-b.velocity.dx * 0.8, b.velocity.dy);
     }

     if (b.position.dy - b.radius/h < screenTop) {
       b.position = Offset(b.position.dx, screenTop + b.radius/h);
       b.velocity = Offset(b.velocity.dx, -b.velocity.dy * 0.8);
     } else if (b.position.dy + b.radius/h > screenBottom) {
       b.position = Offset(b.position.dx, screenBottom - b.radius/h);
       b.velocity = Offset(b.velocity.dx, -b.velocity.dy * 0.8);
     }
   }

     // 2. 气泡间碰撞检测（保持原有逻辑）
     for (int i = 0; i < _bubbles.length; i++) {
       for (int j = i + 1; j < _bubbles.length; j++) {
         final a = _bubbles[i];
         final b = _bubbles[j];

         if (a.isDragging || b.isDragging) continue;

         final dx = (a.position.dx - b.position.dx) * w;
         final dy = (a.position.dy - b.position.dy) * h;
         final distance = sqrt(dx * dx + dy * dy);
         final minDist = a.radius + b.radius + 10;

         if (distance < minDist) {
           // 碰撞响应
           final nx = dx / distance;
           final ny = dy / distance;
           final p = 2.0 * (a.velocity.dx * nx + a.velocity.dy * ny -
               b.velocity.dx * nx - b.velocity.dy * ny) /
               (a.radius + b.radius);

           // 更新速度
           a.velocity = Offset(
               a.velocity.dx - p * b.radius * nx,
               a.velocity.dy - p * b.radius * ny
           );

           b.velocity = Offset(
               b.velocity.dx + p * a.radius * nx,
               b.velocity.dy + p * a.radius * ny
           );

           // 轻微分离气泡防止粘连
           final overlap = (minDist - distance) / 2;
           a.position = Offset(
               a.position.dx + (nx * overlap) / w,
               a.position.dy + (ny * overlap) / h
           );
           b.position = Offset(
               b.position.dx - (nx * overlap) / w,
               b.position.dy - (ny * overlap) / h
           );

           // 触发点击效果
           _onBubbleTap(i, isCollision: true);
           _onBubbleTap(j, isCollision: true);
         }
       }
     }

   // 3. 限制更新频率
   if (_lastUpdate == null || DateTime.now().difference(_lastUpdate!).inMilliseconds > 16) {
     _lastUpdate = DateTime.now();
     if (mounted) setState(() {});
   }
 }

  // 计算高对比度文字颜色
  Color _getContrastColor(Color background) {
    final luminance = background.computeLuminance();
    return luminance > 0.9 ? Colors.black : Colors.white;
  }

  // 生成随机标签
  String _getRandomTag() {
    return _tagPool[_rand.nextInt(_tagPool.length)];
  }

  // 处理标签点击
 void _onBubbleTap(int index, {bool isCollision = false}) {
   if (_bubbles[index].isDragging) return;

   final now = DateTime.now();
   final bubble = _bubbles[index];

   // 只对碰撞应用冷却时间
   if (isCollision) {
     // 添加冷却时间检查（2秒内只能点击一次）
     if (bubble.lastTapTime != null &&
         now
             .difference(bubble.lastTapTime!)
             .inMilliseconds < 2000) {
       return;
     }
     bubble.lastTapTime = now; // 更新最后点击时间
   }

   setState(() {
     _bubbles[index].isSelected = true;
     _bubbles[index].pulseValue = 0.8;
   });

   // 立即更新标签内容
   Future.delayed(const Duration(milliseconds: 300), () {
     if (!mounted) return;
     setState(() {
       final newTag = _getRandomTag();
       _bubbles[index].text = newTag;

       // 更新半径
       final newRadius = 25 + newTag.length * 3;
       _bubbles[index].radius = newRadius.clamp(30, 60).toDouble();

       // 更新颜色
       final currentColor = _bubbles[index].color;
       final newHue = (HSLColor.fromColor(currentColor).hue + 180) % 360;
       _bubbles[index].color = HSLColor.fromAHSL(
           1.0,
           newHue,
           0.8,
           0.7
       ).toColor().withOpacity(0.9);

       _bubbles[index].isSelected = false;
       _bubbles[index].pulseValue = 0.0;
     });
   });
 }

 // 开始拖动气泡
 void _startDrag(int index, Offset globalPosition) {
   final size = MediaQuery.of(context).size;

   setState(() {
     _bubbles[index].isDragging = true;
     _bubbles[index].dragStartPosition = _bubbles[index].position;
     _bubbles[index].dragStartVelocity = _bubbles[index].velocity;
     // 清空速度，停止当前运动
     _bubbles[index].velocity = Offset.zero;
     _draggingBubble = _bubbles[index];
     _dragStartGlobal = globalPosition;
     _dragStartTime = DateTime.now().millisecondsSinceEpoch.toDouble();

     // 初始化拖动轨迹跟踪
     _dragPositions.clear();
     _dragTimes.clear();
     _dragPositions.add(globalPosition);
     _dragTimes.add(DateTime.now());
   });
 }

  // 更新拖动位置
 void _updateDrag(Offset globalPosition, Size size) {
   if (_draggingBubble == null) return;

   // 获取当前变换矩阵的缩放比例
   final currentScale = _transformationController.value.getMaxScaleOnAxis();

   setState(() {
     // // 计算新的位置（归一化坐标）
     // final deltaX = (globalPosition.dx - _dragStartGlobal.dx) / size.width;
     // final deltaY = (globalPosition.dy - _dragStartGlobal.dy) / size.height;
     // 计算新的位置（归一化坐标），考虑缩放比例
     final deltaX = (globalPosition.dx - _dragStartGlobal.dx) / (size.width * currentScale);
     final deltaY = (globalPosition.dy - _dragStartGlobal.dy) / (size.height * currentScale);

     final newPosition = Offset(
       _draggingBubble!.dragStartPosition.dx + deltaX,
       _draggingBubble!.dragStartPosition.dy + deltaY,
     );

     _draggingBubble!.position = newPosition;

     // 记录拖动轨迹（用于计算抛掷速度）
     _dragPositions.add(globalPosition);
     _dragTimes.add(DateTime.now());

     // 只保留最近的几个样本点
     if (_dragPositions.length > _maxDragSamples) {
       _dragPositions.removeAt(0);
       _dragTimes.removeAt(0);
     }
   });
 }

  // 结束拖动并赋予速度
 void _endDrag(Offset globalPosition, Size size) {
   if (_draggingBubble == null) return;

   // 获取当前变换矩阵的缩放比例
   final currentScale = _transformationController.value.getMaxScaleOnAxis();

   // 确保有足够的样本点来计算速度
   if (_dragPositions.length < 2) {
     setState(() {
       _draggingBubble!.velocity = Offset.zero;
       _draggingBubble!.isDragging = false;
       _draggingBubble = null;
       _isBackgroundDragging = true;
     });
     return;
   }

   // 使用最近的几个点计算平均速度
   final now = DateTime.now();
   final recentPositions = <Offset>[];
   final recentTimes = <DateTime>[];

   // 只使用最近100毫秒内的数据点
   for (int i = _dragPositions.length - 1; i >= 0; i--) {
     final timeDiff = now.difference(_dragTimes[i]).inMilliseconds;
     if (timeDiff <= 100) { // 100毫秒内的数据
       recentPositions.insert(0, _dragPositions[i]);
       recentTimes.insert(0, _dragTimes[i]);
     } else {
       break;
     }
   }

   if (recentPositions.length >= 2) {
     // 计算速度（使用最后两个点）
     final lastPos = recentPositions.last;
     final firstPos = recentPositions.first;
     final timeDelta = recentTimes.last.difference(recentTimes.first).inMilliseconds / 1000.0;

     if (timeDelta > 0) {
       final velocityX = (lastPos.dx - firstPos.dx) / timeDelta;
       final velocityY = (lastPos.dy - firstPos.dy) / timeDelta;

       // // 转换为归一化速度并应用合适的系数
       // final normalizedVelocity = Offset(
       //   velocityX / size.width,
       //   velocityY / size.height,
       // );
       // 转换为归一化速度并考虑缩放比例
       final normalizedVelocity = Offset(
         velocityX / (size.width * currentScale),
         velocityY / (size.height * currentScale),
       );

       setState(() {
         // 应用抛掷速度，增加系数让效果更明显
         _draggingBubble!.velocity = normalizedVelocity * 0.01; // 调整这个系数控制抛掷力度
         _draggingBubble!.isDragging = false;
         _draggingBubble = null;
         _isBackgroundDragging = true;
       });

       // 清理拖动数据
       _dragPositions.clear();
       _dragTimes.clear();
       return;
     }
   }

   // 如果无法计算速度，则设为零速度
   setState(() {
     _draggingBubble!.velocity = Offset.zero;
     _draggingBubble!.isDragging = false;
     _draggingBubble = null;
     _isBackgroundDragging = true;
   });

   _dragPositions.clear();
   _dragTimes.clear();
 }

  @override
  void dispose() {
    _flyController?.dispose();
    _moveController.dispose();
    _breathController.dispose();
    _pulseController.dispose();
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_flyController == null) {
      // return Center(child: CircularProgressIndicator()); // 异步初始化期间显示加载状态
      return Center(
        child: Image.asset(
          'asset/images/earth.gif',
          width: 200,
          height: 200,
        ),
      );
    }
    // 在访问控制器前添加空检查
    final breathScale = 1.0 + (_breathController.value ?? 0.0) * 0.05;
    final size = MediaQuery.of(context).size;
    // 计算地球位置（虚拟画布中的位置）
    final globalEarthPos = Offset(
        (size.width * _virtualWidth) / 2 - (size.width * 1.0) / 2,
        (size.height * _virtualHeight) / 2 - (size.width * 1.0) / 2
    );
    // 计算地球中心点（屏幕坐标系）
    final earthCenter = Offset(
        globalEarthPos.dx + size.width * 0.5,
        globalEarthPos.dy + size.width * 0.5
    );

    // 计算需要应用的变换（将地球中心移动到屏幕中心）
    final screenCenter = Offset(size.width / 2, size.height / 2);
    final translation = screenCenter - earthCenter;

    // 设置初始变换（仅在第一次构建时）
    if (_transformationController.value == Matrix4.identity()) {
      _transformationController.value = Matrix4.identity()
        ..translate(translation.dx, translation.dy);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body:Listener(
        onPointerMove: (details) {
      // 当有标签被拖动时禁用背景拖动
      if (_draggingBubble != null) {
        setState(() => _isBackgroundDragging = false);
      } else {
        // 用户开始交互时，停止摄像机自动动画
        if (_isCameraAnimationActive) {
          setState(() {
            _isCameraAnimationActive = false;
          });
        }
      }
    },
    child: AnimatedBuilder(
    animation: _cameraAnimation,
    builder: (context, child) {
    // 只在动画激活时自动设置变换
    if (_isCameraAnimationActive) {
      // 计算当前缩放值
      final currentScale = _cameraAnimation.value;

      // 设置变换（缩放 + 居中）
      final screenCenter = Offset(size.width / 2, size.height / 2);
      final earthCenter = Offset(
          (size.width * _virtualWidth) / 2,
          (size.height * _virtualHeight) / 2
      );
      final translation = screenCenter - earthCenter * currentScale;

      _transformationController.value = Matrix4.identity()
        ..translate(translation.dx, translation.dy)
        ..scale(currentScale);
    }

    return InteractiveViewer( // 替换为InteractiveViewer
        constrained: false,
        boundaryMargin: EdgeInsets.all(0),
        minScale: 0.7,
        maxScale: 1.3,
        panEnabled: _isBackgroundDragging,// 启用平移
        scaleEnabled: _isBackgroundDragging,// 启用缩放
        transformationController: _transformationController,
    child:
    SizedBox(
      // width: MediaQuery.of(context).size.width * _virtualWidth,
      // height: MediaQuery.of(context).size.height * _virtualHeight,
      width: size.width * _virtualWidth,
      height: size.height * _virtualHeight,
      child:
        Stack(
          children: [
            // 星空背景
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.5,
                    colors: [
                      Colors.deepPurple.shade800.withOpacity(0.8),
                      Colors.black,
                    ],
                    stops: [0.1, 1.0],
                  ),
                ),
              ),
            ),

            // 星空粒子
            ...List.generate(80, (index) {
              final offsetX = sin(index * 0.7) * 0.01;
              final offsetY = cos(index * 0.5) * 0.01;

              return AnimatedBuilder(
                animation: _breathController,
                builder: (context, child) {
                  final progress = _breathController.value;
                  final opacity = 0.4 + 0.3 * sin(progress * pi * 2 + index);

                  return Positioned(
                    // left: (_rand.nextDouble() + offsetX * progress) * size.width,
                    // top: (_rand.nextDouble() + offsetY * progress) * size.height,
                    left: (_rand.nextDouble() * _virtualWidth * size.width),
                    top: (_rand.nextDouble() * _virtualHeight * size.height),
                    child: Container(
                      width: _rand.nextDouble() * 2 + 1,
                      height: _rand.nextDouble() * 2 + 1,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(opacity),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              );
            }),

            // 添加地球 GIF - 在气泡下层
            Positioned(
              // left: (size.width * _virtualWidth) / 2 - (size.width * 1.0) / 2,
              left: globalEarthPos.dx,
              // top: (size.height * _virtualHeight) / 2 - (size.width * 1.0) / 2,
              top: globalEarthPos.dy,
              child: Transform.scale(
                scale: 2.0, // 放大1.5倍
                child: IgnorePointer(
                  child:Image.asset(
                  'asset/images/earth.gif', // 你的 GIF 路径
                  width: size.width * 1.0,   // 调整大小
                  height: size.width * 1.0,
                  fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // 标签气泡
            // if(_flyController != null && _flyController!.isCompleted)
            if(_flyController != null)
            ..._bubbles.asMap().entries.map((entry) {
            final i = entry.key;
            final b = entry.value;
            return AnimatedBuilder(
              animation: Listenable.merge([
                _flyController,
                _breathController,
                _pulseController,
                // _moveController
              ]),
              builder: (context, _) {
                final t = _flyAnims[i].value;

                // 根据动画状态选择位置
                final useRealPosition = _flyController!.isCompleted;
                final currentX = useRealPosition ? b.position.dx : (0.5 + (b.targetPos.dx - 0.5) * t);
                final currentY = useRealPosition ? b.position.dy : (0.5 + (b.targetPos.dy - 0.5) * t);

                // 1. 使用目标位置（不进行动画过渡）
                final px = currentX * size.width;
                final py = currentY * size.height;

                // 2. 计算缩放和透明度
                final scaleValue = t;
                final opacityValue = t.clamp(0.0, 1.0);
                final pulseScale = 1.0 + b.pulseValue * 0.3;
                final textColor = _getContrastColor(b.color);
                // final xNorm = _flyController!.isCompleted
                //     ? b.position.dx
                //     : (0.5 + (b.targetPos.dx - 0.5) * t);
                // final yNorm = _flyController!.isCompleted
                //     ? b.position.dy
                //     : (0.5 + (b.targetPos.dy - 0.5) * t);
                // final px = xNorm * size.width;
                // final py = yNorm * size.height;
                final breathScale = 1.0 + _breathController.value * 0.05;
                // final pulseScale = 1.0 + b.pulseValue * 0.3;
                // final textColor = _getContrastColor(b.color);
                // final scale = _breathController.value * 0.2 + 0.9;

                return Positioned(
                  left: px - b.radius,
                  top: py - b.radius,
                  child:
                  Listener( // 添加Listener确保手势检测
                    behavior: HitTestBehavior.translucent,
                    child: Opacity(
                    opacity: opacityValue,
                    child: Transform.scale(
                    scale: scaleValue * pulseScale * breathScale,
                    child:
                    GestureDetector(
                    onPanStart: (details) {
                      _startDrag(i, details.globalPosition);
                    },
                    onPanUpdate: (details) {
                      _updateDrag(details.globalPosition, size);
                    },
                    onPanEnd: (details) {
                      _endDrag(details.globalPosition, size);
                      // 解锁背景拖动
                      setState(() => _isBackgroundDragging = true);
                    },
                    onPanCancel: () {
                      // 解锁背景拖动
                      setState(() => _isBackgroundDragging = true);
                    },
                    onTap: () => _onBubbleTap(i),
                    child: Transform.scale(
                      scale: _flyController!.isCompleted
                          ? breathScale * pulseScale
                          : _flyAnims[i].value * breathScale,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        width: b.radius * 2,
                        height: b.radius * 2,
                        decoration: BoxDecoration(
                          color: b.color,
                          borderRadius: BorderRadius.circular(b.radius),
                          boxShadow: [
                            BoxShadow(
                              color: b.color.withOpacity(0.6),
                              blurRadius: b.isSelected ? 20 : 10,
                              spreadRadius: b.isSelected ? 5 : 2,
                            ),
                            if (b.isSelected)
                              BoxShadow(
                                color: Colors.white.withOpacity(0.8),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                          ],
                        ),
                        child: Center(
                          // child: _buildCircularText(
                          //   b.text,
                          //   b.radius * 0.7,
                          //   textColor,
                          // ),
                          child: Padding(
                        padding: EdgeInsets.all(8.0), // 添加 8 像素的内边距
                          child:FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              b.text,
                              style: GoogleFonts.roboto(
                                color: textColor,
                                fontSize: b.radius * 0.45, // 增大字体大小
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    blurRadius: 2,
                                    color: Colors.black.withOpacity(0.5),
                                    offset: const Offset(1, 1),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),
                          ),
                          ),
                        ),
                      ),
                    ),
                    // ),
                  ),
                  ),
                  ),
                  ),
                );
              },
            );
          }),
          ],
        ),
    ),
      );
    },
    ),
      ),
    // ),
    );
  }
}

