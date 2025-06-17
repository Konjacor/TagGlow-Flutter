// lib/pages/register_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/login_service.dart';
import '../../models/user_model.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl  = TextEditingController();
  final _passwordCtrl  = TextEditingController();
  final _avatarCtrl    = TextEditingController();
  final _signatureCtrl = TextEditingController();

  bool _loading = false;
  String? _errorMsg;

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

    setState(() { _loading = true; _errorMsg = null; });
    try {
      User user = await AuthService.register(
        username: _usernameCtrl.text.trim(),
        password: _passwordCtrl.text,
        avatar: _avatarCtrl.text.trim(),
        signature: _signatureCtrl.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('欢迎 ${user.username} 注册成功！'))
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() { _errorMsg = e.toString(); });
    } finally {
      setState(() { _loading = false; });
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
