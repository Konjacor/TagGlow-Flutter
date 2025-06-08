import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../provider/theme_store.p.dart';
import 'components/head_userbox.dart';

class MyPersonal extends StatelessWidget {
  const MyPersonal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeStore = Provider.of<ThemeStore>(context, listen: false);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('我'),
        centerTitle: true,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          HeadUserBox(),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: [
                Container(
                  color: Theme.of(context).cardColor,
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.brightness_6,
                            color: Theme.of(context).iconTheme.color),
                        title: Text(
                          isDarkMode ? '切换至亮模式' : '切换至暗模式',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        onTap: () {
                          themeStore.setTheme(
                            isDarkMode ? ThemeData.light() : ThemeData.dark(),
                          );
                        },
                      ),
                      Divider(height: 1, color: Theme.of(context).dividerColor),
                      ListTile(
                        leading: Icon(Icons.edit,
                            color: Theme.of(context).iconTheme.color),
                        title: Text(
                          '修改信息',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        onTap: () {
                          // TODO: 添加修改信息导航
                        },
                      ),
                      Divider(height: 1, color: Theme.of(context).dividerColor),
                      ListTile(
                        leading: Icon(Icons.info_outline,
                            color: Theme.of(context).iconTheme.color),
                        title: Text(
                          '版本信息',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        onTap: () {
                          showAboutDialog(
                            context: context,
                            applicationName: '你的App名称',
                            applicationVersion: 'v1.0.0',
                          );
                        },
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
}