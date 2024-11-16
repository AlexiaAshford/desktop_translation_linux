/// 翻译结果输出组件，展示翻译后的文本。
/// 包含结果显示、复制、收藏等功能。

import 'package:flutter/material.dart';

class TranslationOutput extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onCopy;

  const TranslationOutput({
    super.key,
    required this.controller,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
      ),
      child: Stack(
        children: [
          TextField(
            controller: controller,
            maxLines: null,
            readOnly: true,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
          Positioned(
            right: 8,
            bottom: 8,
            child: IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () => onCopy(controller.text),
            ),
          ),
        ],
      ),
    );
  }
}