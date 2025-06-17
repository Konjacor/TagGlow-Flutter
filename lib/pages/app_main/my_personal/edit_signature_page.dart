import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/login_service.dart';

class EditSignaturePage extends StatefulWidget {
  final String userId;
  final String currentSignature;
  const EditSignaturePage({Key? key, required this.userId, required this.currentSignature}) : super(key: key);

  @override
  _EditSignaturePageState createState() => _EditSignaturePageState();
}

class _EditSignaturePageState extends State<EditSignaturePage> {
  late TextEditingController _signatureCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _signatureCtrl = TextEditingController(text: widget.currentSignature);
  }

  @override
  void dispose() {
    _signatureCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pinkPrimary = Colors.pink.shade300;
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        title: Text('修改签名', style: GoogleFonts.robotoSlab()),
        backgroundColor: pinkPrimary,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _signatureCtrl,
              decoration: InputDecoration(
                labelText: '个性签名',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
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
                    : Text('保存签名', style: GoogleFonts.robotoSlab(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onSave() async {
    setState(() => _saving = true);
    final ok = await LoginService.updateSignature(widget.userId, _signatureCtrl.text.trim());
    if (ok) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('signature', _signatureCtrl.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('签名更新成功'))
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('签名更新失败'))
      );
    }
    setState(() => _saving = false);
  }
}