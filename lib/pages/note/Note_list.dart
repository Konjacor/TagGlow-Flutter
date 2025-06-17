import 'dart:convert';
import 'package:flutter/material.dart';
import '../../routes/route_name.dart';       // 使用路由常量
import '../../services/login_service.dart';
import 'batch_edit.dart';  // 整理结果页
import '../../models/note.dart';
import 'package:http/http.dart' as http;

class NoteListPage extends StatefulWidget {
  const NoteListPage({Key? key}) : super(key: key);

  @override
  _NoteListPageState createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
  final String _baseUrl = 'http://10.0.2.2:8001/service/note';
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

    // GET 接口使用 path 参数
    final uri = Uri.parse('$_baseUrl/getNotesByUserId/${user.id}');
    try {
      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        final list = body['data']['items'] as List<dynamic>;
        setState(() {
          _notes = list.map((e) => Note.fromJson(e as Map<String, dynamic>)).toList();
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
                  Navigator.pushReplacementNamed(context, RouteName.login);
                  return;
                }
                final userId = user.id;

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Center(child: CircularProgressIndicator()),
                );

                try {
                  // POST 接口使用 query 参数
                  final response = await http.post(
                    Uri.parse('$_baseUrl/generateTravelGuide')
                        .replace(queryParameters: {'userId': userId}),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode(_selectedIds.toList()),
                  );

                  Navigator.pop(context);

                  if (!mounted) return;
                  if (response.statusCode == 200) {
                    final body = jsonDecode(response.body);
                    final guide = body['data']['travelGuide'] as String;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => BatchGeneratePage(travelGuide: guide),
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
          final selected = _selectedIds.contains(note.id);
          return ListTile(
            title: Text(note.content),
            subtitle: Text(note.position ?? ''),
            trailing: _selectionMode
                ? Checkbox(
              value: selected,
              onChanged: (checked) {
                setState(() {
                  if (checked == true)
                    _selectedIds.add(note.id);
                  else
                    _selectedIds.remove(note.id);
                });
              },
            )
                : null,
            onTap: _selectionMode
                ? () {
              setState(() {
                if (selected)
                  _selectedIds.remove(note.id);
                else
                  _selectedIds.add(note.id);
              });
            }
                : null,
          );
        },

      ),
    );
  }
}