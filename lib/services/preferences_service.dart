/// 首选项管理服务类，负责用户设置的持久化存储和读取。
/// 使用 SharedPreferences 实现设置的本地存储。

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/preferences_service.dart';
import '../models/translation_history.dart';
import '../utils/constants.dart';

class PreferencesService {
  static late SharedPreferences _prefs;
  static const String _settingsKey = 'translator_settings';
  static const String _historyKey = 'translation_history';
  static const String _customApiKey = 'custom_api_key';
  static const String _customEndpointKey = 'custom_endpoint';
  static const String _themeKey = 'app_theme';
  static const String _fontSizeKey = 'font_size';
  static const String _autoSaveKey = 'auto_save';
  static const String _defaultEngineKey = 'default_engine';

  // 初始化
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 加载设置
  static Future<TranslatorSettings> loadSettings() async {
    try {
      final String? settingsJson = _prefs.getString(_settingsKey);
      if (settingsJson != null) {
        return TranslatorSettings.fromJson(
          json.decode(settingsJson) as Map<String, dynamic>,
        );
      }
    } catch (e) {
      // 如果加载失败，返回默认设置
      print('加载设置失败: $e');
    }
    return TranslatorSettings(); // 返回默认设置
  }

  // 保存设置
  static Future<void> saveSettings(TranslatorSettings settings) async {
    try {
      await _prefs.setString(
        _settingsKey,
        json.encode(settings.toJson()),
      );
    } catch (e) {
      print('保存设置失败: $e');
      rethrow;
    }
  }

  // 保存翻译历史
  static Future<void> saveHistory(List<TranslationHistory> history) async {
    try {
      final List<Map<String, dynamic>> historyJson =
          history.map((h) => h.toJson()).toList();
      await _prefs.setString(_historyKey, json.encode(historyJson));
    } catch (e) {
      print('保存历史记录失败: $e');
      rethrow;
    }
  }

  // 加载翻译历史
  static Future<List<TranslationHistory>> loadHistory() async {
    try {
      final String? historyJson = _prefs.getString(_historyKey);
      if (historyJson != null) {
        final List<dynamic> decoded = json.decode(historyJson);
        return decoded
            .map((item) => TranslationHistory.fromJson(item))
            .toList();
      }
    } catch (e) {
      print('加载历史记录失败: $e');
    }
    return [];
  }

  // 清除历史记录
  static Future<void> clearHistory() async {
    await _prefs.remove(_historyKey);
  }

  // 获取自定义API密钥
  static String? getCustomApiKey() {
    return _prefs.getString(_customApiKey);
  }

  // 设置自定义API密钥
  static Future<void> setCustomApiKey(String apiKey) async {
    await _prefs.setString(_customApiKey, apiKey);
  }

  // 获取自定义API端点
  static String? getCustomEndpoint() {
    return _prefs.getString(_customEndpointKey);
  }

  // 设置自定义API端点
  static Future<void> setCustomEndpoint(String endpoint) async {
    await _prefs.setString(_customEndpointKey, endpoint);
  }

  // 获取主题模式
  static String getThemeMode() {
    return _prefs.getString(_themeKey) ?? ThemeMode.system.toString();
  }

  // 设置主题模式
  static Future<void> setThemeMode(String themeMode) async {
    await _prefs.setString(_themeKey, themeMode);
  }

  // 获取字体大小
  static double getFontSize() {
    return _prefs.getDouble(_fontSizeKey) ?? Constants.defaultFontSize;
  }

  // 设置字体大小
  static Future<void> setFontSize(double fontSize) async {
    await _prefs.setDouble(_fontSizeKey, fontSize);
  }

  // 获取自动保存设置
  static bool getAutoSave() {
    return _prefs.getBool(_autoSaveKey) ?? true;
  }

  // 设置自动保存
  static Future<void> setAutoSave(bool autoSave) async {
    await _prefs.setBool(_autoSaveKey, autoSave);
  }

  // 获取默认翻译引擎
  static String getDefaultEngine() {
    return _prefs.getString(_defaultEngineKey) ?? Constants.defaultEngine;
  }

  // 设置默认翻译引擎
  static Future<void> setDefaultEngine(String engine) async {
    await _prefs.setString(_defaultEngineKey, engine);
  }

  // 重置所有设置到默认值
  static Future<void> resetToDefaults() async {
    await _prefs.clear();
    // 保留一些不应该被清除的数据，比如历史记录
    final history = await loadHistory();
    await saveHistory(history);
  }

  // 导出设置
  static Future<String> exportSettings() async {
    final Map<String, dynamic> exportData = {
      'settings': (await loadSettings()).toJson(),
      'customApiKey': getCustomApiKey(),
      'customEndpoint': getCustomEndpoint(),
      'themeMode': getThemeMode(),
      'fontSize': getFontSize(),
      'autoSave': getAutoSave(),
      'defaultEngine': getDefaultEngine(),
    };
    return json.encode(exportData);
  }

  // 导入设置
  static Future<void> importSettings(String jsonString) async {
    try {
      final Map<String, dynamic> importData =
          json.decode(jsonString) as Map<String, dynamic>;

      if (importData.containsKey('settings')) {
        await saveSettings(
          TranslatorSettings.fromJson(importData['settings']),
        );
      }

      if (importData.containsKey('customApiKey')) {
        await setCustomApiKey(importData['customApiKey']);
      }

      if (importData.containsKey('customEndpoint')) {
        await setCustomEndpoint(importData['customEndpoint']);
      }

      if (importData.containsKey('themeMode')) {
        await setThemeMode(importData['themeMode']);
      }

      if (importData.containsKey('fontSize')) {
        await setFontSize(importData['fontSize']);
      }

      if (importData.containsKey('autoSave')) {
        await setAutoSave(importData['autoSave']);
      }

      if (importData.containsKey('defaultEngine')) {
        await setDefaultEngine(importData['defaultEngine']);
      }
    } catch (e) {
      print('导入设置失败: $e');
      rethrow;
    }
  }

  // 验证设置是否存在
  static bool hasSettings() {
    return _prefs.containsKey(_settingsKey);
  }
}
