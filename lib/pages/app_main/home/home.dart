import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../note/note.dart';
import '../../note/letter_detail_page.dart';

class DiaryHomePage extends StatefulWidget {
  const DiaryHomePage({super.key});

  @override
  State<DiaryHomePage> createState() => _DiaryHomePageState();
}

class _DiaryHomePageState extends State<DiaryHomePage> {
  final PageController _pageController = PageController(viewportFraction: 0.75);
  int _currentIndex = 0;

  // 只保留一份"今日笔记"卡片和一份"感谢相遇"卡片
  final List<Map<String, dynamic>> _cards = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy年MM月dd日').format(now);
    final dayStr = DateFormat('d').format(now);

    // 今日笔记卡片
    _cards.add({
      'type': 'today',
      'title': '今日笔记',
      'date': dateStr,
      'day': dayStr,
      'cover': 'asset/images/kitty.png',
      'tip': '疲惫的一天终于结束\n打开日记写下今天的故事叭',
    });

    // 感谢相遇卡片
    _cards.add({
      'type': 'letter',
      'title': '感谢相遇',
      'cover': 'asset/images/kitty3.png',
      'subtitle': '一封tagglow的来信',
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF6DEC8), Color(0xFFFAD5A5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 上半屏：GIF 动画
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'asset/animations/notetaker.gif',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      gaplessPlayback: true,
                    ),
                  ),
                ),
              ),

              // 下半屏：PageView 卡片，icon -> 标题 -> cover -> details
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _cards.length,
                        onPageChanged: (index) {
                          setState(() => _currentIndex = index);
                        },
                        itemBuilder: (context, index) {
                          final card = _cards[index];
                          double scale = 1.0;
                          try {
                            final page = _pageController.page!;
                            scale = (index == page.round()) ? 1.0 : 0.9;
                          } catch (_) {}
                          if (card['type'] == 'today') {
                            return Transform.scale(
                              scale: scale,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 16),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  elevation: 4,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, '/themeSelection');
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            const SizedBox(width: 24),
                                            Text(
                                              card['day'],
                                              style: const TextStyle(
                                                fontSize: 48,
                                                color: Colors.teal,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              card['date'],
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.grey[700]),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Center(
                                          child: Text(
                                            card['tip'],
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black87),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Expanded(
                                          child: Center(
                                            child: Image.asset(
                                              card['cover'],
                                              height: 100,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Center(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 32, vertical: 12),
                                            decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius:
                                                  BorderRadius.circular(32),
                                            ),
                                            child: const Text(
                                              '记录我的今天',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                          if (card['type'] == 'letter') {
                            return Transform.scale(
                              scale: scale,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 16),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  elevation: 4,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const LetterDetailPage(),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        const SizedBox(height: 24),
                                        Expanded(
                                          child: Center(
                                            child: Image.asset(
                                              card['cover'],
                                              height: 160,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                        // 黑色底部区域
                                        ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(20),
                                            bottomRight: Radius.circular(20),
                                          ),
                                          child: Container(
                                            color: Colors.black87,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 20, horizontal: 8),
                                            child: Column(
                                              children: [
                                                Text(
                                                  card['title'] ?? '',
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                const SizedBox(height: 8),
                                                Container(
                                                  width: 24,
                                                  height: 2,
                                                  color: Colors.white24,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  card['subtitle'] ?? '',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white70,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),

                    // 指示器
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_cards.length, (i) {
                        return GestureDetector(
                          onTap: () => _pageController.animateToPage(
                            i,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease,
                          ),
                          child: Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentIndex == i
                                  ? Colors.brown.shade800
                                  : Colors.grey.shade400,
                            ),
                          ),
                        );
                      }),
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
