import 'package:flutter/material.dart';

class NotePage extends StatefulWidget {
  final dynamic params;

  const NotePage({Key? key, this.params}) : super(key: key);

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final TextEditingController _editableController = TextEditingController(
    text: '这里是初始笔记内容，你可以编辑我。',
  );

  final String fixedNote = '''
今天的目标是完成笔记功能页面开发：

- 显示天气、时间、地点信息
- 支持输入、编辑笔记
- 美观布局
- 后续集成云同步与分类标签功能

继续加油！💪
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('笔记'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部信息
            const Text(
              '☁️ 阴天 · 14:30 · 北京',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // 标签
            Wrap(
              spacing: 8.0,
              children: const [
                Chip(label: Text('工作')),
                Chip(label: Text('生活')),
                Chip(label: Text('学习')),
              ],
            ),
            const SizedBox(height: 20),

            // 可编辑文本区域（带初始内容）
            const Text(
              '可编辑内容：',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _editableController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // 固定内容文本框（只读）
            const Text(
              '固定内容区：',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Container(
              width: double.infinity,
              height: 120,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Text(
                  fixedNote,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
