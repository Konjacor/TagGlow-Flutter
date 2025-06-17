import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/login_service.dart';
import '../../../models/user_model.dart';
import 'edit_avatar_page.dart';
import 'edit_signature_page.dart';
import '../../../provider/theme_store.p.dart';

class MyPersonal extends StatefulWidget {
  const MyPersonal({Key? key}) : super(key: key);

  @override
  _MyPersonalState createState() => _MyPersonalState();
}

class _MyPersonalState extends State<MyPersonal> {
  late Future<User?> _userFuture;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    _userFuture = LoginService.getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    final themeStore = Provider.of<ThemeStore>(context, listen: false);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final pinkPrimary = Colors.pink.shade300;
    final pinkBackground = Colors.pink.shade50;

    return Scaffold(
      backgroundColor: pinkBackground,
      appBar: AppBar(
        title: Text(
          '我的个人中心',
          style: GoogleFonts.robotoSlab(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: pinkPrimary,
      ),
      body: FutureBuilder<User?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = snapshot.data;
          if (user == null) {
            return const Center(child: Text('无法获取用户信息'));
          }
          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [pinkPrimary, Colors.pink.shade200],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.shade100,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: user.avatar.isNotEmpty
                          ? NetworkImage(user.avatar)
                          : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.username,
                      style: GoogleFonts.robotoSlab(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.signature,
                      style: GoogleFonts.robotoSlab(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildListTile(
                      icon: Icons.brightness_6,
                      title: isDarkMode ? '切换至亮模式' : '切换至暗模式',
                      onTap: () => themeStore.setTheme(
                        isDarkMode ? ThemeData.light() : ThemeData.dark(),
                      ),
                    ),
                    const Divider(color: Colors.pinkAccent),
                    _buildListTile(
                      icon: Icons.image,
                      title: '修改头像',
                      onTap: () async {
                        final updated = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditAvatarPage(
                              userId: user.id,
                              currentAvatar: user.avatar,
                            ),
                          ),
                        );
                        if (updated == true && mounted) {
                          setState(_loadUser);
                        }
                      },
                    ),
                    const Divider(color: Colors.pinkAccent),
                    _buildListTile(
                      icon: Icons.edit,
                      title: '修改签名',
                      onTap: () async {
                        final updated = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditSignaturePage(
                              userId: user.id,
                              currentSignature: user.signature,
                            ),
                          ),
                        );
                        if (updated == true && mounted) {
                          setState(_loadUser);
                        }
                      },
                    ),
                    const Divider(color: Colors.pinkAccent),
                    _buildListTile(
                      icon: Icons.info_outline,
                      title: '版本信息',
                      onTap: () {
                        // TODO: 版本信息
                      },
                    ),
                    const Divider(color: Colors.pinkAccent),
                    _buildListTile(
                      icon: Icons.logout,
                      title: '退出登录',
                      onTap: () async {
                        await LoginService.logout();
                        if (!mounted) return;
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                              (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.pink),
      title: Text(
        title,
        style: GoogleFonts.robotoSlab(color: Colors.black87),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
