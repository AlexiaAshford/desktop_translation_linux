/// 源文本输入组件，处理用户输入的待翻译文本。
/// 包含文本输入框、清空、复制等基本功能。

import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';

class SourceInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final bool isDragging;
  final bool enterToTranslate;
  final Function(String) onTextChanged;
  final VoidCallback? onSubmitted;
  final Function(DropDoneDetails) onDragDone;
  final Function(DropEventDetails) onDragEntered;
  final Function(DropEventDetails) onDragExited;

  const SourceInput({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.isDragging,
    required this.enterToTranslate,
    required this.onTextChanged,
    required this.onDragDone,
    required this.onDragEntered,
    required this.onDragExited,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragDone: onDragDone,
      onDragEntered: onDragEntered,
      onDragExited: onDragExited,
      child: Container(
        decoration: BoxDecoration(
          color:
              isDragging ? Colors.blue.withOpacity(0.1) : Colors.grey.shade100,
          border: isDragging ? Border.all(color: Colors.blue, width: 2) : null,
        ),
        child: Stack(
          children: [
            TextField(
              controller: controller,
              maxLines: null,
              enabled: !isLoading,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                hintText: '输入文字或拖放TXT文件至此',
                hintStyle: TextStyle(color: Colors.grey.shade400),
              ),
              onChanged: onTextChanged,
              keyboardType: TextInputType.multiline,
              textInputAction: enterToTranslate
                  ? TextInputAction.send
                  : TextInputAction.newline,
              onSubmitted: enterToTranslate ? (_) => onSubmitted?.call() : null,
            ),
            if (isDragging)
              Center(
                child: Text(
                  '释放以导入文件',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
