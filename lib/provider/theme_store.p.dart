import 'package:flutter/material.dart';
import '../constants/themes/index_theme.dart';

// Provider状态管理使用
class ThemeStore with ChangeNotifier {
  ThemeData _currentTheme = ThemeData.light();

  ThemeData get currentTheme => _currentTheme;

  void setTheme(ThemeData theme) {
    _currentTheme = theme;
    notifyListeners();
  }


}
