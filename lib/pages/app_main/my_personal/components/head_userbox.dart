import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../routes/route_name.dart';

class HeadUserBox extends StatefulWidget {
  @override
  State<HeadUserBox> createState() => _HeadUserBoxState();
}

class _HeadUserBoxState extends State<HeadUserBox> {
  bool isLoggedIn = false;

  // 示例用户数据
  String avatarUrl = 'https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp';
  String username = '点击登录 / 注册';
  String signature = '未登录';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!isLoggedIn) {
          Navigator.pushNamed(context, RouteName.login);
        } else {
          // 可跳转到“个人资料页”
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        color: Theme.of(context).cardColor,
        child: Row(
          children: [
            // 头像
            CircleAvatar(
              radius: 35,
              backgroundImage: NetworkImage(avatarUrl),
            ),
            const SizedBox(width: 16),
            // 昵称和签名
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(username, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(signature, style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
