/// 应用程序常量定义文件。
/// 存储应用中使用的所有静态常量值，如默认设置、配置项等。

class Constants {
  // 应用相关
  static const String appName = '翻译助手';
  static const String appVersion = '1.0.0';

  // 默认值
  static const double defaultFontSize = 16.0;
  static const String defaultEngine = 'google';

  // 翻译相关
  static const int maxInputLength = 5000;
  static const int maxHistoryItems = 100;

  // 时间相关
  static const int apiTimeoutSeconds = 10;
  static const Duration cacheExpiration = Duration(days: 7);

  // 其他常量
  static const int maxRetries = 3;
  static const int debounceMilliseconds = 300;
}
