/// 文件操作服务类，提供文件读写、导入导出等功能。
/// 处理应用程序所需的所有文件相关操作。
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../models/log_service.dart';

class FileService {
  static Future<String> readFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        throw '文件不存在';
      }

      String content;
      try {
        content = await file.readAsString();
      } catch (e) {
        // 如果UTF-8解码失败，尝试使用GBK解码
        final bytes = await file.readAsBytes();
        try {
          // 注意：这里需要添加一个GBK解码的依赖
          // 你需要在pubspec.yaml中添加 gbk_codec: ^0.4.0
          content = await _decodeGBK(bytes);
        } catch (e) {
          throw '不支持的文件编码格式';
        }
      }

      await LogService.log(
        '成功读取文件\n文件路径: $filePath\n内容长度: ${content.length}',
        type: 'FILE',
      );

      return content;
    } catch (e) {
      await LogService.log('读取文件失败: $e', type: 'ERROR');
      rethrow;
    }
  }

  static Future<String?> pickTextFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      return result.files.first.path;
    } catch (e) {
      await LogService.log('选择文件失败: $e', type: 'ERROR');
      rethrow;
    }
  }

  // GBK解码方法
  static Future<String> _decodeGBK(List<int> bytes) async {
    // 这里需要实现GBK解码
    // 如果使用gbk_codec包，可以这样实现：
    // return GbkCodec().decode(bytes);

    // 临时返回UTF-8编码，你需要根据实际需求实现GBK解码
    return utf8.decode(bytes, allowMalformed: true);
  }
}
