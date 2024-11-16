/// 日志服务模型类，用于定义日志记录的数据结构和相关操作。
/// 包含日志级别、时间戳、消息内容等信息的封装。

import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class LogService {
  static const String _logFileName = 'translator_log.txt';
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  static Future<void> log(String message, {String? type}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_logFileName');

      final timestamp = _dateFormat.format(DateTime.now());
      final logEntry = '[$timestamp] ${type ?? 'INFO'}: $message\n';

      await file.writeAsString(logEntry, mode: FileMode.append);
    } catch (e) {
      print('Error writing log: $e');
    }
  }

  static Future<String> getLogContents() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_logFileName');

      if (!await file.exists()) {
        return '没有日志记录';
      }

      return await file.readAsString();
    } catch (e) {
      return '读取日志失败: $e';
    }
  }

  static Future<void> clearLogs() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_logFileName');

      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error clearing logs: $e');
    }
  }
}