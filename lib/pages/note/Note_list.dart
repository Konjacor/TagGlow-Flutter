import 'dart:convert';
import 'package:flutter/material.dart';
import '../../routes/route_name.dart'; // 使用路由常量
import '../../services/login_service.dart';
import '../../services/note_service.dart';
import 'batch_edit.dart'; // 整理结果页
import '../../models/note.dart';
import 'package:http/http.dart' as http;

import 'note_detail_page.dart';

class NoteListPage extends StatefulWidget {
  const NoteListPage({Key? key}) : super(key: key);

  @override
  _NoteListPageState createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
  final String _baseUrl = 'http://10.22.66.126:8001/service/note';
  List<Note> _notes = [];
  Set<String> _selectedIds = {};
  bool _selectionMode = false;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final user = await LoginService.getCurrentUser();
    if (user == null) {
      Navigator.pushReplacementNamed(context, RouteName.login);
      return;
    }

    final uri = Uri.parse('$_baseUrl/getNotesByUserId/${user.id}');
    try {
      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        // 使用 UTF-8 解码，避免中文乱码
        final bodyStr = utf8.decode(resp.bodyBytes);
        final body = jsonDecode(bodyStr);
        final list = body['data']['items'] as List<dynamic>;
        setState(() {
          _notes = list
              .map((e) => Note.fromJson(e as Map<String, dynamic>))
              .toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('获取笔记失败：状态码 ${resp.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('获取笔记异常：$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('笔记列表'),
        actions: [
          IconButton(
            icon: Icon(_selectionMode ? Icons.close : Icons.check_box),
            tooltip: _selectionMode ? '退出选择' : '批量选择',
            onPressed: () {
              setState(() {
                _selectionMode = !_selectionMode;
                if (!_selectionMode) _selectedIds.clear();
              });
            },
          ),
          if (_selectionMode)
            IconButton(
              icon: const Icon(Icons.send),
              tooltip: '一键生成整理',
              onPressed: _selectedIds.isEmpty
                  ? null
                  : () async {
                      final user = await LoginService.getCurrentUser();
                      if (user == null) {
                        Navigator.pushReplacementNamed(
                            context, RouteName.login);
                        return;
                      }
                      final userId = user.id;

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) =>
                            const Center(child: CircularProgressIndicator()),
                      );

                      try {
                        final response = await http.post(
                          Uri.parse('$_baseUrl/generateTravelGuide')
                              .replace(queryParameters: {'userId': userId}),
                          headers: {'Content-Type': 'application/json'},
                          body: jsonEncode(_selectedIds.toList()),
                        );
                        Navigator.pop(context);

                        if (!mounted) return;
                        if (response.statusCode == 200) {
                          // 同样使用 UTF-8 解码
                          final respStr = utf8.decode(response.bodyBytes);
                          final respBody = jsonDecode(respStr);
                          final guide =
                              respBody['data']['travelGuide'] as String;
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  BatchGeneratePage(travelGuide: guide),
                            ),
                          );
                        } else {
                          throw Exception('接口返回状态码：${response.statusCode}');
                        }
                      } catch (e) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('调用生成接口失败：$e')),
                        );
                      }
                    },
            ),
        ],
      ),
      body: ListView.builder(
        itemCount: _notes.length,
        itemBuilder: (context, index) {
          final note = _notes[index];
          return Dismissible(
            key: Key(note.id),
            direction: DismissDirection.startToEnd,
            background: Container(
              color: Colors.redAccent,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (_) => showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('确认删除？'),
                content: const Text('是否删除此条笔记？'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('取消'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('删除'),
                  ),
                ],
              ),
            ),
            onDismissed: (_) async {
              final user = await LoginService.getCurrentUser();
              if (user == null) {
                Navigator.pushReplacementNamed(context, RouteName.login);
                return;
              }
              final userId = user.id;
              // 增加 userId 作为删除请求参数
              final success = await NoteService.deleteNote(userId, note.id);
              if (success) {
                setState(() {
                  _notes.removeAt(index);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('删除成功')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('删除失败，请重试')),
                );
              }
            },
            child: ListTile(
              title: Text(note.content),
              subtitle: Text(note.position ?? ''),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => NoteDetailPage(noteId: note.id),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
