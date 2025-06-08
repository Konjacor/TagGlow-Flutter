import 'package:flutter/material.dart';
import '../../models/note_item.dart';

class NotePage extends StatefulWidget {
  const NotePage({Key? key, this.params}) : super(key: key);
  final Map<String, dynamic>? params;

  @override
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final TextEditingController _contentController = TextEditingController();
  final List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    if (widget.params != null) {
      final p = widget.params!;
      if (p['content'] is String) {
        _contentController.text = p['content'];
      }
      if (p['tags'] is List<String>) {
        _tags.addAll(p['tags']);
      }
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _addTag() async {
    final tag = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('添加标签'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(hintText: '输入标签名称'),
          onSubmitted: (val) => Navigator.pop(context, val.trim()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('确认')),
        ],
      ),
    );
    if (tag != null && tag.isNotEmpty) {
      setState(() => _tags.insert(0, tag));
    }
  }

  void _generateContent() {
    final buf = StringBuffer('—— AI 生成内容 ——\n');
    for (var t in _tags) buf.writeln('- [$t] 笔记概要示例');
    buf.writeln('以上内容基于标签生成。');
    setState(() => _contentController.text = buf.toString());
  }

  void _saveNote() {
    final content = _contentController.text;
    final reply = '已保存：${content.length} 字，标签: ${_tags.join(', ')}';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(reply)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑笔记'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _generateContent,
            child: const Text('自动生成', style: TextStyle(color: Colors.white)),
          ),
          IconButton(icon: const Icon(Icons.save), onPressed: _saveNote),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var tag in _tags)
                  Chip(label: Text(tag), onDeleted: () => setState(() => _tags.remove(tag))),
                ActionChip(avatar: const Icon(Icons.add), label: const Text('添加标签'), onPressed: _addTag),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                expands: true,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: '在此编辑或查看内容',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
