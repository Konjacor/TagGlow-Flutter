import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/note_item.dart';

class BatchGeneratePage extends StatefulWidget {
  const BatchGeneratePage({Key? key, required this.notes}) : super(key: key);
  final List<NoteItem> notes;

  @override
  _BatchGeneratePageState createState() => _BatchGeneratePageState();
}

class _BatchGeneratePageState extends State<BatchGeneratePage> {
  bool _loading = false;
  String _generated = '';

  Future<void> _doGenerate() async {
    setState(() => _loading = true);
    // 模拟把 widget.notes 发送给后端，然后获取整理后的内容
    await Future.delayed(Duration(seconds: 2));
    // 示例返回
    final buf = StringBuffer('=== 整理报告 ===\n');
    for (var n in widget.notes) {
      buf.writeln('- ${n.title}: ${n.content.substring(0, min(n.content.length, 20))}...');
    }
    buf.writeln('\n以上是自动整理后的笔记摘要');
    setState(() {
      _generated = buf.toString();
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _doGenerate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('批量整理'), centerTitle: true),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Text(_generated),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // 如果需要再二次生成或刷新
                _doGenerate();
              },
              child: Text('重新生成'),
            ),
          ],
        ),
      ),
    );
  }
}
