import 'dart:convert';
import 'package:flutter/material.dart';
import '../../routes/route_name.dart'; // 使用路由常量
import '../../services/login_service.dart';
import '../../services/note_service.dart';
import 'batch_edit.dart'; // 整理结果页
import '../../models/note.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // 引入日期格式化包

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
  bool _isLoading = true; // 新增加载状态

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    // 下拉刷新时不清空，以提供更好的用户体验
    if (_notes.isEmpty) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final user = await LoginService.getCurrentUser();
      if (user == null) {
        if (mounted) Navigator.pushReplacementNamed(context, RouteName.login);
        return;
      }
      final notes = await NoteService.getNotesByUserId(user.id);
      setState(() {
        _notes = notes;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('获取笔记异常：$e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadNotes,
              child: ListView.builder(
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  final note = _notes[index];
                  final isSelected = _selectedIds.contains(note.id);

                  return Dismissible(
                    key: Key(note.id),
                    direction: DismissDirection.startToEnd,
                    background: Container(
                      color: Colors.red.withOpacity(0.8),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete,
                          color: Colors.white, size: 30),
                    ),
                    confirmDismiss: (_) => showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('确认删除？'),
                        content: const Text('笔记删除后无法恢复哦！'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('手滑了')),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.red),
                            child: const Text('确认删除'),
                          ),
                        ],
                      ),
                    ),
                    onDismissed: (_) async {
                      final user = await LoginService.getCurrentUser();
                      if (user == null) {
                        Navigator.pushReplacementNamed(
                            context, RouteName.login);
                        return;
                      }
                      final userId = user.id;
                      // 增加 userId 作为删除请求参数
                      final success =
                          await NoteService.deleteNote(userId, note.id);
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
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: isSelected
                            ? BorderSide(
                                color: Theme.of(context).primaryColor, width: 2)
                            : BorderSide.none,
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () {
                          if (_selectionMode) {
                            setState(() {
                              if (isSelected) {
                                _selectedIds.remove(note.id);
                              } else {
                                _selectedIds.add(note.id);
                              }
                            });
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => NoteDetailPage(noteId: note.id),
                              ),
                            );
                          }
                        },
                        onLongPress: () {
                          if (!_selectionMode) {
                            setState(() {
                              _selectionMode = true;
                              _selectedIds.add(note.id);
                            });
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                note.content,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 4.0,
                                children: (note.tags ?? [])
                                    .map((tag) => Chip(
                                          label: Text(tag,
                                              style: const TextStyle(
                                                  fontSize: 12)),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4),
                                          backgroundColor: Colors.grey.shade200,
                                        ))
                                    .toList(),
                              ),
                              const Divider(height: 24),
                              Row(
                                children: [
                                  Icon(Icons.location_on,
                                      size: 14, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      note.position ?? '未知地点',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    DateFormat('yyyy-MM-dd HH:mm')
                                        .format(note.time),
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
