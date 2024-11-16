class AppConfig {
  static const String appName = '翻译助手';
  static const String version = '1.0.0';

  // API配置
  static const String apiBaseUrl = 'https://api.example.com';
  static const int apiTimeout = 10000; // 毫秒

  // 缓存配置
  static const int maxCacheSize = 100;
  static const Duration cacheTimeout = Duration(days: 7);

// 其他配置项...
}