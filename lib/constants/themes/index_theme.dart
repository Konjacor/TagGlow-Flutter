import 'package:flutter/material.dart';
// 以下你配置的全局主题颜色参数
part 'theme_bluegrey.dart';
part 'theme_lightblue.dart';
part 'theme_pink.dart';

// 新增：标签墙冷色调暗色主题
final ThemeData themeTagGlowDark = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFF232946),
  scaffoldBackgroundColor: const Color(0xFF181C2A),
  cardColor: const Color(0xFF232946),
  dividerColor: const Color(0xFF3A506B),
  appBarTheme: const AppBarTheme(
    color: Color(0xFF232946),
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
        color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    elevation: 0,
  ),
  colorScheme: ColorScheme.dark(
    primary: Color(0xFFB0C4DE),
    secondary: Color(0xFF87CEEB),
    background: Color(0xFF232946),
    surface: Color(0xFF232946),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: Colors.white,
    onSurface: Colors.white,
    error: Color(0xffd32f2f),
    onError: Colors.white,
    brightness: Brightness.dark,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white70),
    titleLarge: TextStyle(color: Color(0xFFB0C4DE)),
    titleMedium: TextStyle(color: Color(0xFFB0C4DE)),
    labelLarge: TextStyle(color: Color(0xFFB0C4DE)),
  ),
  iconTheme: const IconThemeData(color: Color(0xFFB0C4DE)),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF3A506B),
    foregroundColor: Colors.white,
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFF232946),
    border: OutlineInputBorder(),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFF3A506B)),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFB0C4DE)),
    ),
    labelStyle: TextStyle(color: Color(0xFFB0C4DE)),
    hintStyle: TextStyle(color: Colors.white54),
  ),
  bottomAppBarTheme: const BottomAppBarTheme(color: Color(0xFF232946)),
  tabBarTheme: const TabBarThemeData(
    labelColor: Color(0xFFB0C4DE),
    unselectedLabelColor: Colors.white54,
    indicatorSize: TabBarIndicatorSize.tab,
  ),
  dialogBackgroundColor: const Color(0xFF232946),
);
