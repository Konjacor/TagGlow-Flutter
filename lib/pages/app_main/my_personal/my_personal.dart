import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; // 添加Google字体
import '../../../../provider/theme_store.p.dart';
import 'components/head_userbox.dart';

class MyPersonal extends StatelessWidget {
  const MyPersonal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeStore = Provider.of<ThemeStore>(context, listen: false);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // 粉色主题颜色
    final pinkPrimary = Colors.pink.shade300;
    final pinkBackground = Colors.pink.shade50;
    final pinkCardColor = Colors.white.withOpacity(0.9);

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
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // 美化用户头像区域
          Container(
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
            child: HeadUserBox(),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: [
                // 美化卡片容器
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: pinkCardColor,
                    borderRadius: BorderRadius.circular(16),
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
                      // 美化列表项
                      _buildPinkListTile(
                        context,
                        icon: Icons.brightness_6,
                        title: isDarkMode ? '切换至亮模式' : '切换至暗模式',
                        onTap: () {
                          themeStore.setTheme(
                            isDarkMode ? ThemeData.light() : ThemeData.dark(),
                          );
                        },
                      ),
                      Divider(
                        height: 1,
                        color: Colors.pink.shade100,
                        indent: 16,
                        endIndent: 16,
                      ),
                      _buildPinkListTile(
                        context,
                        icon: Icons.edit,
                        title: '修改信息',
                        onTap: () {
                          // TODO: 添加修改信息导航
                        },
                      ),
                      Divider(
                        height: 1,
                        color: Colors.pink.shade100,
                        indent: 16,
                        endIndent: 16,
                      ),
                      _buildPinkListTile(
                        context,
                        icon: Icons.info_outline,
                        title: '版本信息',
                        onTap: () {
                          showAboutDialog(
                            context: context,
                            applicationName: '你的App名称',
                            applicationVersion: 'v1.0.0',
                            applicationIcon: Icon(
                              Icons.favorite,
                              color: pinkPrimary,
                            ),
                            children: [
                              Text('感谢使用我们的应用！',
                                style: TextStyle(color: Colors.pink.shade800),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // 添加额外的设置项
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: pinkCardColor,
                    borderRadius: BorderRadius.circular(16),
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
                      _buildPinkListTile(
                        context,
                        icon: Icons.settings,
                        title: '设置',
                        onTap: () {},
                      ),
                      Divider(
                        height: 1,
                        color: Colors.pink.shade100,
                        indent: 16,
                        endIndent: 16,
                      ),
                      _buildPinkListTile(
                        context,
                        icon: Icons.exit_to_app,
                        title: '退出登录',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 自定义粉色风格列表项
  Widget _buildPinkListTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
      }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.pink.shade100.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.pink.shade800),
      ),
      title: Text(
        title,
        style: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.pink.shade900,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.pink.shade300,
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}