/// 翻译服务类，提供核心翻译功能的实现。
/// 包含与各翻译API的交互、翻译结果的处理等功能。

import 'package:dart_openai/openai.dart';
import '../models/preferences_service.dart';
import '../models/log_service.dart';

class TranslatorService {
  static Future<String> translate({
    required String text,
    required String sourceLang,
    required String targetLang,
    required TranslatorSettings settings,
  }) async {
    if (text.trim().isEmpty) return '';

    try {
      OpenAI.apiKey = settings.apiKey;
      OpenAI.baseUrl = settings.apiHost;

      await LogService.log(
          '开始翻译请求\n'
          '源语言: $sourceLang\n'
          '目标语言: $targetLang\n'
          '源文本: $text\n'
          'API地址: ${settings.apiHost}\n'
          '模型: ${settings.model}',
          type: 'REQUEST');

      final userMessage = OpenAIChatCompletionChoiceMessageModel(
        content: text,
        role: "user",
      );

      final systemMessage = OpenAIChatCompletionChoiceMessageModel(
        content: settings.getPrompt(sourceLang, targetLang),
        role: "system",
      );

      final chatCompletion = await OpenAI.instance.chat.create(
        model: settings.model,
        messages: [systemMessage, userMessage],
        temperature: 0.7,
      );

      final translation = chatCompletion.choices.first.message.content;

      await LogService.log(
          '翻译成功\n'
          '翻译结果: $translation',
          type: 'SUCCESS');

      return translation;
    } catch (e) {
      await LogService.log('翻译失败: ${e.toString()}', type: 'ERROR');
      throw e;
    }
  }
}
