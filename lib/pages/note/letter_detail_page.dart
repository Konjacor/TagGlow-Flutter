import 'package:flutter/material.dart';

class LetterDetailPage extends StatelessWidget {
  const LetterDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    const content =
        '''世界是由无数个未被命名的瞬间组成的---早晨打翻的豆浆在桌面蜿蜒成地图，偶然抬头遇见海棠花开成薄云在瞳孔里溶解......

在这个容易孤独的世界里，TagGlow想做的很简单：让每一次情绪波动都被温柔地承接住。当你再次说"学校门口的海棠花开了"，你可能会收到回信"要不要逆光拍张照片，花瓣会变成透明色"。当然，TagGlow会给每个记录的人奖励，慢慢被点亮的泡泡墙，是你一次次在琐碎中努力泅渡的证明。

某个瞬间也许你会重新思考记录的意义---不是粗暴地把生活压缩成文字，而是让生命中的光，都有迹可循。''';
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}",
                style: const TextStyle(color: Colors.grey, fontSize: 20),
              ),
              const SizedBox(height: 12),
              Text(
                "晴",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                "tagglow星球",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  Chip(
                    label:
                        const Text("相逢的人会再相逢", style: TextStyle(fontSize: 13)),
                    backgroundColor: Colors.white,
                    shape: StadiumBorder(side: BorderSide(color: Colors.grey)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    content,
                    style: const TextStyle(fontSize: 16, height: 1.6),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${content.length} 字",
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Image.asset(
                      'asset/images/kitty3.png',
                      width: 130,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
