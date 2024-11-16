/// 主翻译界面的页面实现。
/// 包含输入框、翻译结果显示、语言选择等主要翻译功能的UI实现。
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/language_selector.dart';
import '../widgets/source_input.dart';
import '../widgets/translation_output.dart';
import '../services/translator_service.dart';
import '../utils/language_detector.dart';
import '../models/settings_screen.dart';
import '../services/file_service.dart';
import '../models/preferences_service.dart';

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  bool _isLoading = false;
  String _sourceLang = '中文';
  String _targetLang = '英语';
  TranslatorSettings _settings = TranslatorSettings();
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final settings = await PreferencesService.loadSettings();
    setState(() {
      _settings = settings;
    });
  }

  void _swapLanguages() {
    setState(() {
      final tempLang = _sourceLang;
      _sourceLang = _targetLang;
      _targetLang = tempLang;

      final tempText = _sourceController.text;
      _sourceController.text = _targetController.text;
      _targetController.text = tempText;
    });
  }

  Future<void> _translate() async {
    if (_sourceController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final translation = await TranslatorService.translate(
        text: _sourceController.text,
        sourceLang: _sourceLang,
        targetLang: _targetLang,
        settings: _settings,
      );

      setState(() {
        _targetController.text = translation;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('错误: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _handleFileDrop(String filePath) async {
    try {
      final content = await FileService.readFile(filePath);
      setState(() {
        _sourceController.text = content;
      });
      _detectAndSwitchLanguage(content);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('读取文件失败: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      final filePath = await FileService.pickTextFile();
      if (filePath != null) {
        await _handleFileDrop(filePath);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择文件失败: ${e.toString()}')),
        );
      }
    }
  }

  void _detectAndSwitchLanguage(String text) {
    final (sourceLang, targetLang) = LanguageDetector.detectLanguage(
      text,
      _sourceLang,
    );

    if (sourceLang != _sourceLang) {
      setState(() {
        _sourceLang = sourceLang;
        _targetLang = targetLang;
      });
    }
  }

  void _clearText() {
    setState(() {
      _sourceController.clear();
      _targetController.clear();
    });
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已复制到剪贴板')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('翻译助手'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload),
            onPressed: _pickFile,
            tooltip: '选择文件',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ).then((_) => _loadSettings()),
          ),
        ],
      ),
      body: Column(
        children: [
          LanguageSelector(
            sourceLang: _sourceLang,
            targetLang: _targetLang,
            onSwap: _swapLanguages,
          ),
          Expanded(
            child: SourceInput(
              controller: _sourceController,
              isLoading: _isLoading,
              isDragging: _isDragging,
              enterToTranslate: _settings.enterToTranslate,
              onTextChanged: _detectAndSwitchLanguage,
              onSubmitted: _translate,
              onDragDone: (detail) async {
                if (detail.files.isEmpty) return;
                final file = detail.files.first;
                if (file.path.toLowerCase().endsWith('.txt')) {
                  await _handleFileDrop(file.path);
                }
              },
              onDragEntered: (_) => setState(() => _isDragging = true),
              onDragExited: (_) => setState(() => _isDragging = false),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 50,
            child: Row(
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.clear),
                  label: const Text('清空'),
                  onPressed: _clearText,
                ),
                const Spacer(),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton.icon(
                    icon: const Icon(Icons.translate),
                    label: const Text('翻译'),
                    onPressed: _translate,
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: TranslationOutput(
              controller: _targetController,
              onCopy: _copyToClipboard,
            ),
          ),
        ],
      ),
    );
  }
}
