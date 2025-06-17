import 'package:TagGlowFlutter/pages/app_main/home/home.dart';
import 'package:TagGlowFlutter/pages/note/batch_edit.dart';
import 'package:flutter/material.dart';
import '../pages/login/login.dart';
import '../pages/map/map_page.dart';
import 'route_name.dart';
import '../pages/error_page/error_page.dart';
import '../pages/app_main/app_main.dart';
import '../pages/splash/splash.dart';
import '../pages/test_demo/test_demo.dart';
import '../pages/note/note.dart';
import '../pages/tag/tag.dart';
import '../pages/login/register_page.dart';




final String initialRoute = RouteName.splashPage; // 初始默认显示的路由

final Map<String,
        StatefulWidget Function(BuildContext context, {dynamic params})>
    routesData = {
  // 页面路由定义...
  RouteName.appMain: (context, {params}) => AppMain(params: params),
  RouteName.splashPage: (context, {params}) => SplashPage(),
  RouteName.error: (context, {params}) => ErrorPage(params: params),
  RouteName.testDemo: (context, {params}) => TestDemo(params: params),
  RouteName.login: (context, {params}) => Login(params: params),
  RouteName.notePage: (context, {params}) => NotePage(userId: '',),
  RouteName.tagPage:(context, {params}) => const TagWallPage(),
  RouteName.MapPage:(context, {params}) =>const MapPage(),
  RouteName.BatchGeneratePage: (context, {params}) {
    // 确保正确处理参数
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    return BatchGeneratePage(
      travelGuide: args['travelGuide'] ?? '',
    );
  },
  RouteName.registerPage: (context, {params}) => RegisterPage(),
  RouteName.DiaryHomePage: (context, {params}) => DiaryHomePage(),
};
