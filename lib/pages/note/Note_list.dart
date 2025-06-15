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
    final selectedNotes =
        _notes.where((n) => _selectedIds.contains(n.id)).toList();
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => BatchGeneratePage(notes: selectedNotes)),
    );
  }

  void _toggleSelectionMode() {
    setState(() => _selectionMode = !_selectionMode);
    if (!_selectionMode) _selectedIds.clear();
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
          builder: (_) =>
              NotePage(params: {'id': note.id, 'content': note.content}),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectionMode ? '${_selectedIds.length} 已选' : '我的笔记'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_selectionMode ? Icons.close : Icons.select_all),
            onPressed: _toggleSelectionMode,
          ),
          if (_selectionMode)
            IconButton(
              icon: const Icon(Icons.border_color),
              onPressed: _openBatchExport,
            ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF6DEC8), Color(0xFFFAD5A5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notes.length + 1,
                  itemBuilder: (context, idx) {
                    if (idx == _notes.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF6DEC8), Color(0xFFFAD5A5)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.brown.withOpacity(0.08),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _openNewNote,
                            icon: const Icon(Icons.add, color: Colors.brown),
                            label: const Text(
                              '新建笔记',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.brown,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                            ).copyWith(
                              elevation: MaterialStateProperty.all(0),
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.transparent),
                              shadowColor:
                                  MaterialStateProperty.all(Colors.transparent),
                            ),
                          ),
                        ),
                      );
                    }
                    final note = _notes[idx];
                    final selected = _selectedIds.contains(note.id);
                    final dateStr =
                        '${note.updatedAt.year}-${note.updatedAt.month.toString().padLeft(2, '0')}-${note.updatedAt.day.toString().padLeft(2, '0')}';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        splashColor: const Color(0xFFB0C4DE).withOpacity(0.3),
                        onTap: () => _onItemTap(note),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFFB0C4DE).withOpacity(0.15)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: selected
                                ? Border.all(
                                    color: const Color(0xFF87CEEB), width: 2)
                                : null,
                          ),
                          child: Row(
                            children: [
                              if (_selectionMode)
                                Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: selected
                                          ? const Color(0xFF87CEEB)
                                          : Colors.grey.shade300,
                                      border: Border.all(
                                        color: selected
                                            ? const Color(0xFF87CEEB)
                                            : Colors.grey.shade400,
                                        width: 2,
                                      ),
                                    ),
                                    child: selected
                                        ? const Icon(Icons.check,
                                            size: 18, color: Colors.white)
                                        : null,
                                  ),
                                ),
                              Icon(
                                Icons.note,
                                size: 32,
                                color: Colors.brown.shade400,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      note.title,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      note.content.length > 30
                                          ? '${note.content.substring(0, 30)}...'
                                          : note.content,
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                dateStr,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
