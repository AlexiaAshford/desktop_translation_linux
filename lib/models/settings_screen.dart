/// 设置界面相关的模型类，定义设置页面所需的数据结构。
/// 用于管理和存储设置界面的各项配置选项。

import 'package:flutter/material.dart';
import 'preferences_service.dart';
import 'log_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _apiHostController;
  late TextEditingController _apiKeyController;
  late TextEditingController _modelController;
  bool _enterToTranslate = false;
  bool _isLoading = true;
  bool _obscureApiKey = true;

  @override
  void initState() {
    super.initState();
    _apiHostController = TextEditingController();
    _apiKeyController = TextEditingController();
    _modelController = TextEditingController();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await PreferencesService.loadSettings();
    setState(() {
      _apiHostController.text = settings.apiHost;
      _apiKeyController.text = settings.apiKey;
      _modelController.text = settings.model;
      _enterToTranslate = settings.enterToTranslate;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      final settings = TranslatorSettings(
        apiHost: _apiHostController.text,
        apiKey: _apiKeyController.text,
        model: _modelController.text,
        enterToTranslate: _enterToTranslate,
      );

      setState(() => _isLoading = true);

      await LogService.log(
          '保存设置\n'
              'API Host: ${settings.apiHost}\n'
              'Model: ${settings.model}\n'
              'Enter to Translate: ${settings.enterToTranslate}',
          type: 'SETTINGS'
      );

      await PreferencesService.saveSettings(settings);
      setState(() => _isLoading = false);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('设置已保存')),
      );
    }
  }

  Future<void> _viewLogs() async {
    final logs = await LogService.getLogContents();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('日志'),
        content: SingleChildScrollView(
          child: SelectableText(logs), // 使用 SelectableText 使日志内容可复制
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await LogService.clearLogs();
              if (!mounted) return;
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('日志已清除')),
              );
            },
            child: const Text('清除日志'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        actions: [
          IconButton(
            icon: const Icon(Icons.article),
            onPressed: _isLoading ? null : _viewLogs,
            tooltip: '查看日志',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveSettings,
            tooltip: '保存设置',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _apiHostController,
                decoration: const InputDecoration(
                  labelText: 'API Host',
                  hintText: 'https://api.openai.com/v1/chat/completions',
                  helperText: '请输入完整的API地址',
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'API Host不能为空';
                  }
                  try {
                    Uri.parse(value!);
                  } catch (e) {
                    return '请输入有效的URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _apiKeyController,
                obscureText: _obscureApiKey,
                decoration: InputDecoration(
                  labelText: 'API Key',
                  helperText: '请输入你的API密钥',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureApiKey
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureApiKey = !_obscureApiKey;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'API Key不能为空';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: '模型',
                  hintText: 'deepseek-ai/DeepSeek-V2.5',
                  helperText: '请输入要使用的AI模型名称',
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return '模型名称不能为空';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('回车键翻译'),
                subtitle: const Text('启用后，按回车键即可翻译文本'),
                value: _enterToTranslate,
                onChanged: (bool value) {
                  setState(() {
                    _enterToTranslate = value;
                  });
                },
              ),
              const SizedBox(height: 32),
              const Text(
                '提示：\n'
                    '1. 请确保API Host和API Key的正确性\n'
                    '2. 如遇到问题，可查看日志了解详情\n'
                    '3. API密钥请妥善保管，不要泄露给他人',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _apiHostController.dispose();
    _apiKeyController.dispose();
    _modelController.dispose();
    super.dispose();
  }
}