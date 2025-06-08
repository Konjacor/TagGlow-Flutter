import 'package:flutter/material.dart';
import '../../models/note_item.dart';
import 'Note.dart';
import 'batch_edit.dart';

class NoteListPage extends StatefulWidget {
  const NoteListPage({Key? key}) : super(key: key);

  @override
  _NoteListPageState createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
  final List<NoteItem> _notes = [];
  final Set<String> _selectedIds = {};
  bool _loading = true;
  bool _selectionMode = false;

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _notes.clear();
      _notes.addAll(List.generate(
        5,
            (i) => NoteItem(
          id: 'note_$i',
          title: '笔记标题 #\$i',
          content: '这是笔记示例内容 #\$i...更多细节',
          updatedAt: DateTime.now().subtract(Duration(days: i)),
        ),
      ));
      _loading = false;
      _selectedIds.clear();
      _selectionMode = false;
    });
  }

  void _openNewNote() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotePage()),
    ).then((_) => _fetchNotes());
  }

  void _openBatchExport() {
    // 进入批量整理页面
    final selectedNotes = _notes.where((n) => _selectedIds.contains(n.id)).toList();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BatchGeneratePage(notes: selectedNotes)),
    );
  }

  void _toggleSelectionMode() {
    setState(() => _selectionMode = !_selectionMode);
    if (!_selectionMode) {
      _selectedIds.clear();
    }
  }

  void _onItemTap(NoteItem note) {
    if (_selectionMode) {
      setState(() {
        if (_selectedIds.contains(note.id))
          _selectedIds.remove(note.id);
        else
          _selectedIds.add(note.id);
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NotePage(
            params: {'id': note.id, 'content': note.content, 'tags': note.tags},
          ),
        ),
      ).then((_) => _fetchNotes());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectionMode
            ? '已选 ${_selectedIds.length} 篇'
            : '笔记列表'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_selectionMode ? Icons.cancel : Icons.check_box),
            tooltip: _selectionMode ? '取消多选' : '多选',
            onPressed: _toggleSelectionMode,
          ),
          if (_selectionMode && _selectedIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.auto_awesome),
              tooltip: '批量整理',
              onPressed: _openBatchExport,
            ),
          if (!_selectionMode)
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: '新建笔记',
              onPressed: _openNewNote,
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty
          ? const Center(child: Text('暂无笔记，点击 + 新建'))
          : ListView.separated(
        itemCount: _notes.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final note = _notes[index];
          final selected = _selectedIds.contains(note.id);
          final date = note.updatedAt;
          final dateStr =
              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          return ListTile(
            leading: _selectionMode
                ? Checkbox(
              value: selected,
              onChanged: (_) => _onItemTap(note),
            )
                : null,
            title: Text(note.title),
            subtitle: Text(
              note.content.length > 30
                  ? '${note.content.substring(0, 30)}...'
                  : note.content,
            ),
            trailing: Text(dateStr,
                style:
                const TextStyle(fontSize: 12, color: Colors.grey)),
            onTap: () => _onItemTap(note),
          );
        },
      ),
    );
  }
}
