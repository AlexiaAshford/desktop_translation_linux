/// 翻译历史记录的模型类，定义单条翻译记录的数据结构。
/// 包含原文、译文、翻译时间、使用的翻译引擎等信息。
class TranslationHistory {
  final String sourceText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final String engine;
  final DateTime timestamp;
  final String? phonetic;
  final Map<String, dynamic>? extraInfo;

  TranslationHistory({
    required this.sourceText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.engine,
    DateTime? timestamp,
    this.phonetic,
    this.extraInfo,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'sourceText': sourceText,
      'translatedText': translatedText,
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
      'engine': engine,
      'timestamp': timestamp.toIso8601String(),
      'phonetic': phonetic,
      'extraInfo': extraInfo,
    };
  }

  factory TranslationHistory.fromJson(Map<String, dynamic> json) {
    return TranslationHistory(
      sourceText: json['sourceText'] as String,
      translatedText: json['translatedText'] as String,
      sourceLanguage: json['sourceLanguage'] as String,
      targetLanguage: json['targetLanguage'] as String,
      engine: json['engine'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      phonetic: json['phonetic'] as String?,
      extraInfo: json['extraInfo'] as Map<String, dynamic>?,
    );
  }

  TranslationHistory copyWith({
    String? sourceText,
    String? translatedText,
    String? sourceLanguage,
    String? targetLanguage,
    String? engine,
    DateTime? timestamp,
    String? phonetic,
    Map<String, dynamic>? extraInfo,
  }) {
    return TranslationHistory(
      sourceText: sourceText ?? this.sourceText,
      translatedText: translatedText ?? this.translatedText,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      engine: engine ?? this.engine,
      timestamp: timestamp ?? this.timestamp,
      phonetic: phonetic ?? this.phonetic,
      extraInfo: extraInfo ?? this.extraInfo,
    );
  }

  @override
  String toString() {
    return 'TranslationHistory(sourceText: $sourceText, '
        'translatedText: $translatedText, '
        'sourceLanguage: $sourceLanguage, '
        'targetLanguage: $targetLanguage, '
        'engine: $engine, '
        'timestamp: $timestamp, '
        'phonetic: $phonetic, '
        'extraInfo: $extraInfo)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TranslationHistory &&
        other.sourceText == sourceText &&
        other.translatedText == translatedText &&
        other.sourceLanguage == sourceLanguage &&
        other.targetLanguage == targetLanguage &&
        other.engine == engine;
  }

  @override
  int get hashCode {
    return Object.hash(
      sourceText,
      translatedText,
      sourceLanguage,
      targetLanguage,
      engine,
    );
  }
}