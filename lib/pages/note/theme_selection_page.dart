import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'note.dart'; // 导入笔记编辑页

class ThemeSelectionPage extends StatefulWidget {
  const ThemeSelectionPage({Key? key}) : super(key: key);

  @override
  _ThemeSelectionPageState createState() => _ThemeSelectionPageState();
}

class _ThemeSelectionPageState extends State<ThemeSelectionPage> {
  int? _selectedThemeId; // 用于存储选中的主题ID

  @override
  Widget build(BuildContext context) {
    // 定义主题及其图标和ID
    final List<Map<String, dynamic>> themes = [
      {'icon': Icons.book_outlined, 'label': '学习', 'id': 0},
      {'icon': Icons.work_outline, 'label': '工作', 'id': 1},
      {'icon': Icons.wb_sunny_outlined, 'label': '日常', 'id': 2},
      {'icon': Icons.home_outlined, 'label': '生活', 'id': 3},
      {'icon': Icons.airplanemode_active_outlined, 'label': '旅行', 'id': 4},
      {'icon': Icons.favorite_border, 'label': '情感', 'id': 5},
      {'icon': Icons.fastfood_outlined, 'label': '美食', 'id': 6},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部的文本和兔子图片
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '是什么事情\n让你感到暖心吶',
                  style: GoogleFonts.lato(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                ),
                // 你可以替换成你的兔子图片
                Icon(Icons.cruelty_free, size: 80, color: Colors.grey.shade400),
              ],
            ),
            const SizedBox(height: 40),
            // 主题网格
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.0,
                ),
                itemCount: themes.length,
                itemBuilder: (context, index) {
                  final theme = themes[index];
                  final isSelected = _selectedThemeId == theme['id'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedThemeId = theme['id'];
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.black
                            : Colors.grey.shade100.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: Colors.grey.shade200, width: 1),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(theme['icon'],
                              size: 40,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey.shade800),
                          const SizedBox(height: 8),
                          Text(
                            theme['label'],
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // 底部的按钮
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40.0, top: 20.0),
                child: TextButton(
                  onPressed: _selectedThemeId == null
                      ? null // 如果未选择主题，则禁用按钮
                      : () {
                          // 点击后跳转到笔记编辑页，并传递主题ID
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotePage(
                                classificationId: _selectedThemeId,
                              ),
                            ),
                          );
                        },
                  style: TextButton.styleFrom(
                    backgroundColor:
                        _selectedThemeId == null ? Colors.white : Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(color: Colors.black, width: 1.5),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: Text(
                    _selectedThemeId == null ? '可能因为这些事' : '因为这件事',
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _selectedThemeId == null
                          ? Colors.black
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
