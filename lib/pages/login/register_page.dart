// lib/pages/register_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/login_service.dart';
import '../../models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _avatarCtrl = TextEditingController();
  final _signatureCtrl = TextEditingController();

  bool _loading = false;
  String? _errorMsg;
  bool _hasPopped = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('注册', style: GoogleFonts.robotoSlab()),
        backgroundColor: Colors.pink.shade300,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_errorMsg != null)
                  Text(_errorMsg!, style: TextStyle(color: Colors.red)),
                TextFormField(
                  controller: _usernameCtrl,
                  decoration: InputDecoration(labelText: '用户名'),
                  validator: (v) => v!.isEmpty ? '必填' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordCtrl,
                  decoration: InputDecoration(labelText: '密码'),
                  obscureText: true,
                  validator: (v) => v!.length < 6 ? '至少6位' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _avatarCtrl,
                  decoration: InputDecoration(labelText: '头像 URL'),
                  validator: (v) => v!.isEmpty ? '必填' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _signatureCtrl,
                  decoration: InputDecoration(labelText: '个性签名'),
                  validator: (v) => v!.isEmpty ? '必填' : null,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _onRegisterPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      elevation: 5,
                      shadowColor: Colors.pink.shade100,
                    ),
                    child: _loading
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            '注册',
                            style: GoogleFonts.robotoSlab(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
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

  Future<void> _onRegisterPressed() async {
    if (!_formKey.currentState!.validate()) return;
    if (!mounted || _hasPopped) return;
    setState(() {
      _loading = true;
      _errorMsg = null;
    });
    try {
      print(
          '开始注册: username=${_usernameCtrl.text.trim()}, avatar=${_avatarCtrl.text.trim()}');
      User user = await AuthService.register(
        username: _usernameCtrl.text.trim(),
        password: _passwordCtrl.text,
        avatar: _avatarCtrl.text.trim(),
        signature: _signatureCtrl.text.trim(),
      );
      print('注册成功: $user');
      // 注册成功后自动保存用户信息到本地
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', user.id);
      await prefs.setString('username', user.username);
      await prefs.setString('avatar', user.avatar);
      await prefs.setString('signature', user.signature);
      await prefs.setString('gmt_create', user.gmtCreate);
      await prefs.setString('gmt_modified', user.gmtModified);
      await prefs.setInt('is_deleted', user.isDeleted);
      await prefs.setBool('is_logged_in', true);
      if (!mounted || _hasPopped) return;
      _hasPopped = true;
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/appMain', (route) => false);
      return;
    } catch (e) {
      print('注册异常: $e');
      if (!mounted || _hasPopped) return;
      setState(() {
        _errorMsg = e.toString();
      });
    } finally {
      if (mounted && !_hasPopped) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _avatarCtrl.dispose();
    _signatureCtrl.dispose();
    super.dispose();
  }
}
