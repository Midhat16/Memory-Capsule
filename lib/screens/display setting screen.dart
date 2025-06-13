// lib/providers/display_settings_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DisplaySettingsProvider with ChangeNotifier {


  double _fontSize = 16.0;
  TextAlign _textAlign = TextAlign.start;
  bool _highContrast = false;
  String _fontFamily = 'Roboto';

  double get fontSize => _fontSize;
  TextAlign get textAlign => _textAlign;
  bool get highContrast => _highContrast;
  String get fontFamily => _fontFamily;

  DisplaySettingsProvider() {
    _loadSettings();
  }

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _fontSize = prefs.getDouble('fontSize') ?? 16.0;
    _textAlign = TextAlign.values[prefs.getInt('textAlign') ?? 0];
    _highContrast = prefs.getBool('highContrast') ?? false;
    _fontFamily = prefs.getString('fontFamily') ?? 'Roboto';
    notifyListeners();
  }

  void updateFontSize(double size) async {
    _fontSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', size);
    notifyListeners();
  }

  void updateTextAlign(TextAlign align) async {
    _textAlign = align;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('textAlign', align.index);
    notifyListeners();
  }


  void toggleHighContrast(bool value) async {
    _highContrast = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('highContrast', value);
    notifyListeners();
  }

  void updateFontFamily(String font) async {
    _fontFamily = font;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fontFamily', font);
    notifyListeners();
  }
}
