/// 应用程序首选项设置的模型类，定义用户偏好设置的数据结构。
/// 包括主题设置、语言选择、字体大小等用户配置项。
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'log_service.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class PreferencesService {
  // 保存设置
  static Future<void> saveSettings(TranslatorSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = jsonEncode({
        'apiHost': settings.apiHost,
        'apiKey': settings.apiKey,
        'model': settings.model,
        'enterToTranslate': settings.enterToTranslate,
      });

      await LogService.log(
          '正在保存设置\n'
          'API Host 长度: ${settings.apiHost.length}\n'
          'API Key 长度: ${settings.apiKey.length}\n'
          'Model: ${settings.model}',
          type: 'SAVE_SETTINGS');

      final success = await prefs.setString('settings', settingsJson);

      await LogService.log('设置保存结果: ${success ? "成功" : "失败"}',
          type: 'SAVE_SETTINGS');
    } catch (e) {
      await LogService.log('保存设置时出错: $e', type: 'ERROR');
      rethrow;
    }
  }

  // 读取设置

  static Future<TranslatorSettings> loadSettings() async {
    try {
      // settings 是读取json文件

      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString('settings');

      await LogService.log(
          '正在读取设置\n'
          '是否存在设置: ${settingsJson != null}',
          type: 'LOAD_SETTINGS');

      if (settingsJson != null) {
        final Map<String, dynamic> settings = jsonDecode(settingsJson);
        final loadedSettings = TranslatorSettings(
          apiHost: settings['apiHost'] ?? '',
          apiKey: settings['apiKey'] ?? '',
          model: settings['model'] ?? '',
          enterToTranslate: settings['enterToTranslate'] ?? false,
        );

        await LogService.log(
            '成功读取设置\n'
            'API Host 长度: ${loadedSettings.apiHost.length}\n'
            'API Key 长度: ${loadedSettings.apiKey.length}\n'
            'Model: ${loadedSettings.model}',
            type: 'LOAD_SETTINGS');

        return loadedSettings;
      }
    } catch (e) {
      await LogService.log('读取设置时出错: $e', type: 'ERROR');
    }

    return TranslatorSettings(
      apiHost: 'https://api.siliconflow.cn',
      apiKey: '',
      model: 'deepseek-ai/DeepSeek-V2.5',
      enterToTranslate: false,
    );
  }
}

class TranslatorSettings {
  String apiHost;
  String apiKey;
  String model;
  bool enterToTranslate;

  TranslatorSettings({
    this.apiHost = "https://api.siliconflow.cn",
    this.apiKey = '',
    this.model = "deepseek-ai/DeepSeek-V2.5",
    this.enterToTranslate = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'apiHost': apiHost,
      'apiKey': apiKey,
      'model': model,
      'enterToTranslate': enterToTranslate,
    };
  }

  factory TranslatorSettings.fromJson(Map<String, dynamic> json) {
    return TranslatorSettings(
      apiHost:
          json['apiHost'] ?? "https://api.siliconflow.cn",
      apiKey: json['apiKey'] ?? '',
      model: json['model'] ?? "deepseek-ai/DeepSeek-V2.5",
      enterToTranslate: json['enterToTranslate'] ?? false,
    );
  }

  // 添加提示词配置引用
  String getPrompt(String sourceLang, String targetLang) {
    return getTranslationPrompt(sourceLang, targetLang);
  }

  static String getTranslationPrompt(String sourceLang, String targetLang) {
    return '''你是一个专业的翻译助手。请将文本从$sourceLang翻译成$targetLang，并遵循以下要求：

1. 首先给出最贴切的翻译
2. 如果是单词或短语：
   - 列出词性（名词、动词、形容词等）
   - 提供其他可能的含义
   - 给出常见用法或例句
3. 如果是句子：
   - 提供直译和意译两种版本
   - 解释特殊用语或习语（如果有）
4. 使用以下格式：

翻译：[主要翻译]

词性：[适用时列出]
其他含义：[适用时列出]
例句：[适用时提供]
补充说明：[如有特殊用法或文化差异]''';
  }
}
