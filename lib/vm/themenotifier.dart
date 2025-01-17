import 'package:flutter/material.dart';
import 'package:hub/services/variables.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier with WidgetsBindingObserver {
  ThemeMode _themeMode;
  Color _iconColor;

  Brightness _platformBrightness;

  ThemeNotifier(this._themeMode, this._iconColor) : _platformBrightness = WidgetsBinding.instance.window.platformBrightness {
    WidgetsBinding.instance.addObserver(this);
  }

  ThemeMode get themeMode => _themeMode;
  Color get iconColor => _iconColor;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.dark) {
      return true;
    } else if (_themeMode == ThemeMode.light) {
      return false;
    } else {
      return _platformBrightness == Brightness.dark;
    }
  }

  bool get isIconColorDark => _iconColor.computeLuminance() > 0.3;

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(themeModeKey, _themeMode.toString().split('.').last.toLowerCase());
  }

  Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final modeString = prefs.getString(themeModeKey);
    switch (modeString) {
      case 'açık tema':
        _themeMode = ThemeMode.light;
        break;
      case 'koyu tema':
        _themeMode = ThemeMode.dark;
        break;
      case 'sistem teması':
        _themeMode = ThemeMode.system;
        break;
      default:
        _themeMode = ThemeMode.system;
        break;
    }
    notifyListeners();
    return _themeMode;
  }

  Future<void> setIconColor(Color color) async {
    _iconColor = color;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();

    String colorString = color.value.toRadixString(16).padLeft(8, '0');
    await prefs.setString(iconColorKey, colorString);
  }

  Future<Color> getIconColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorString = prefs.getString(iconColorKey);
    debugPrint('ColorString: $colorString');
    if (colorString != null && colorString.length == 8) {
      try {
        int colorInt = int.parse(colorString, radix: 16);
        _iconColor = Color(colorInt);
      } catch (e) {
        _iconColor = const Color(0xFFFD4F46);
      }
    } else {
      _iconColor = const Color(0xFFFD4F46);
    }
    notifyListeners();
    return _iconColor;
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(themeModeKey, _themeMode.toString().split('.').last.toLowerCase());

    String colorString = _iconColor.value.toRadixString(16).padLeft(8, '0');
    await prefs.setString(iconColorKey, colorString);
  }

  @override
  void didChangePlatformBrightness() {
    _platformBrightness = WidgetsBinding.instance.window.platformBrightness;
    if (_themeMode == ThemeMode.system) {
      notifyListeners();
    }
    super.didChangePlatformBrightness();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
