// lib/tag/tag.dart

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'tag_service.dart';

/// TagPage：展示当前用户的标签墙，标签会在屏幕上漂浮上下
class TagPage extends StatefulWidget {
  const TagPage({Key? key}) : super(key: key);

  @override
  State<TagPage> createState() => _TagPageState();
}

class _TagPageState extends State<TagPage> {
  late Future<List<String>> _tagsFuture;

  @override
  void initState() {
    super.initState();
    // 这里模拟 userId = '123'，实际可从参数或全局状态里获取
    _tagsFuture = TagService.fetchUserTags('123');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tag 墙'),
      ),
      body: FutureBuilder<List<String>>(
        future: _tagsFuture,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 数据还没到，显示加载中
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('加载失败：${snapshot.error}'));
          } else {
            final tags = snapshot.data!;
            if (tags.isEmpty) {
              return const Center(child: Text('暂无标签'));
            }
            // 有标签：用 Stack 把它们层叠起来，随机定位+漂浮动画
            return LayoutBuilder(
              builder: (ctx, constraints) {
                // 拿到父容器宽、高，方便随机定位
                final width = constraints.maxWidth;
                final height = constraints.maxHeight;
                return Stack(
                  children: [
                    for (int i = 0; i < tags.length; i++)
                      // 每个标签一个 FloatingTag，生成随机初始位置和动画参数
                      FloatingTag(
                        tag: tags[i],
                        // 随机横纵位置（保证不会越界），最左侧留 0-0.8*宽之间随机
                        initX: Random().nextDouble() * (width * 0.8),
                        initY: Random().nextDouble() * (height * 0.8),
                        // 随机动画时长：2~4 秒
                        duration: Duration(
                            milliseconds: 2000 + Random().nextInt(2000)),
                        // 每个标签之间的动画相位（延迟）：0~2s
                        delay: Duration(milliseconds: Random().nextInt(2000)),
                      ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}

/// 漂浮标签组件：给一个字符串 tag，在屏幕上左右偏移由 initX/initY 决定，然后做上下浮动动画
class FloatingTag extends StatefulWidget {
  final String tag;
  final double initX;
  final double initY;
  final Duration duration;
  final Duration delay;

  const FloatingTag({
    Key? key,
    required this.tag,
    required this.initX,
    required this.initY,
    required this.duration,
    required this.delay,
  }) : super(key: key);

  @override
  State<FloatingTag> createState() => _FloatingTagState();
}

class _FloatingTagState extends State<FloatingTag>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _upDownAnimation;

  @override
  void initState() {
    super.initState();
    // 1. 创建一个控制器，周期是 widget.duration
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    // 2. 定义上下浮动的动画：从 0 到 -20 像素，然后再来回
    _upDownAnimation = Tween<double>(begin: 0, end: -20).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // 3. 延迟 widget.delay 后再开始循环往复动画
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // AnimatedBuilder 监听 controller，并在值改变时重新构建 
    return AnimatedBuilder(
      animation: _upDownAnimation,
      builder: (ctx, child) {
        return Positioned(
          left: widget.initX,
          top: widget.initY + _upDownAnimation.value,
          child: child!,
        );
      },
      // child 部分只构建一次：一个带背景+圆角的文本容器
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16.w),
        ),
        child: Text(
          widget.tag,
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}