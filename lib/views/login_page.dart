import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:window_size/window_size.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../services/user_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _loading = false;
  static const _fixedSize = Size(800, 600);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        setWindowTitle("登录");
        setWindowMinSize(_fixedSize);
        setWindowMaxSize(_fixedSize);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() async {
    final info = await getWindowInfo();
    final frame = info.frame;
    if (frame != null &&
        (frame.width != _fixedSize.width || frame.height != _fixedSize.height)) {
      setWindowFrame(Rect.fromLTWH(
        frame.left,
        frame.top,
        _fixedSize.width,
        _fixedSize.height,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A90E2), Color(0xFF007AFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "欢迎登录",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                FormBuilder(
                  key: _formKey,
                  child: Column(
                    children: [
                      FormBuilderTextField(
                        name: 'username',
                        decoration: const InputDecoration(
                          labelText: '用户名',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.minLength(3),
                        ]),
                      ),
                      const SizedBox(height: 16),
                      FormBuilderTextField(
                        name: 'password',
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: '密码',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.minLength(6),
                        ]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _handleLogin,
                    icon: _loading
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : const Icon(Icons.login),
                    label: Text(_loading ? "登录中..." : "登录"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.saveAndValidate()) return;

    final username = _formKey.currentState!.value['username'];
    final password = _formKey.currentState!.value['password'];

    setState(() => _loading = true);
    try {
      await UserService.loginAndSave(username: username, password: password);

      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        setWindowMinSize(const Size(600, 400));
        setWindowMaxSize(Size.infinite);
      }

      Get.offAllNamed('/home');
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showErrorDialog(String message) {
    final cleanMessage = message.replaceFirst("Exception: ", "");
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("登录失败"),
        content: Text(cleanMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("确定"),
          )
        ],
      ),
    );
  }
}
