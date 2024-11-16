/// 语言选择器组件，用于源语言和目标语言的选择。
/// 提供支持的语言列表和切换功能。

import 'package:flutter/material.dart';

class LanguageSelector extends StatelessWidget {
  final String sourceLang;
  final String targetLang;
  final VoidCallback onSwap;

  const LanguageSelector({
    super.key,
    required this.sourceLang,
    required this.targetLang,
    required this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      child: Row(
        children: [
          Text(sourceLang),
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: onSwap,
          ),
          Text(targetLang),
        ],
      ),
    );
  }
}
