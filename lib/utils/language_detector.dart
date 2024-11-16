/// 语言选择器组件，用于源语言和目标语言的选择。
/// 提供支持的语言列表和切换功能。

class LanguageDetector {
  static (String sourceLang, String targetLang) detectLanguage(
    String text,
    String currentSourceLang,
  ) {
    if (text.trim().isEmpty) {
      return (currentSourceLang, currentSourceLang == '中文' ? '英语' : '中文');
    }

    bool hasChineseChars = RegExp(r'[\u4e00-\u9fa5]').hasMatch(text);
    bool hasEnglishChars = RegExp(r'[a-zA-Z]').hasMatch(text);

    if (hasChineseChars && currentSourceLang != '中文') {
      return ('中文', '英语');
    } else if (hasEnglishChars && currentSourceLang != '英语') {
      return ('英语', '中文');
    }

    return (currentSourceLang, currentSourceLang == '中文' ? '英语' : '中文');
  }
}
