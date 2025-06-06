import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../routes/route_name.dart';
import '../../../config/app_env.dart' show appEnv;
import 'provider/counterStore.p.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late CounterStore _counter;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _counter = Provider.of<CounterStore>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '首页',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20.h),
              _button(
                '跳转到测试页',
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    RouteName.testDemo,
                    arguments: {'data': '别名路由传参666'},
                  );
                },
              ),
              _button(
                '跳转到笔记页',
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    RouteName.notePage,
                    arguments: {'info': '跳转到笔记页面'},
                  );
                },
              ),
              _button(
                '跳转到标签墙',
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    RouteName.tagPage,
                    arguments: {'userId': '123'},
                  );
                },
              ),
              SizedBox(height: 20.h),
              Text(
                '状态管理值：${_counter.value}',
                style: TextStyle(
                  fontSize: 20.sp,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  _button(
                    '加+',
                    onPressed: () {
                      _counter.increment();
                    },
                  ),
                  _button(
                    '减-',
                    onPressed: () {
                      _counter.decrement();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _button(String text, {VoidCallback? onPressed}) {
    return Container(
      margin: EdgeInsets.only(top: 10.h),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.w),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18.sp,
            color: Colors.blueAccent,
          ),
        ),
      ),
    );
  }
}