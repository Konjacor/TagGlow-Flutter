import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/login_service.dart';

class EditAvatarPage extends StatefulWidget {
  final String userId;
  final String currentAvatar;
  const EditAvatarPage({
    Key? key,
    required this.userId,
    required this.currentAvatar,
  }) : super(key: key);

  @override
  _EditAvatarPageState createState() => _EditAvatarPageState();
}

class _EditAvatarPageState extends State<EditAvatarPage> {
  File? _image;
  bool _saving = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // 如果需要显示当前头像，可以在这里预加载
  }

  Future<void> _pickImage() async {
    try {
      final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() => _image = File(picked.path));
      }
    } catch (e) {
      print('pickImage 异常: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('无法选择图片'))
      );
    }
  }

  Future<void> _onSave() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('请先选择一张图片'))
      );
      return;
    }

    setState(() => _saving = true);
    final ok = await LoginService.updateAvatar(widget.userId, _image!);
    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      final prefs = await SharedPreferences.getInstance();
      // 后端通常会返回文件 URL，若返回可替换此处
      await prefs.setString('avatar', _image!.path);

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('头像更新成功'))
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('头像更新失败'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pinkPrimary = Colors.pink.shade300;
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        title: Text('修改头像', style: GoogleFonts.robotoSlab()),
        backgroundColor: pinkPrimary,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _image != null
                    ? FileImage(_image!)
                    : (widget.currentAvatar.isNotEmpty
                    ? NetworkImage(widget.currentAvatar)
                    : AssetImage('assets/images/default_avatar.png')
                ) as ImageProvider,
                child: _image == null && widget.currentAvatar.isEmpty
                    ? Icon(Icons.camera_alt, size: 40, color: Colors.white70)
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _pickImage,
              child: Text('选择图片', style: GoogleFonts.robotoSlab()),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: pinkPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('保存头像', style: GoogleFonts.robotoSlab(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
