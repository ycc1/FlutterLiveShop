import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pwd = TextEditingController();
  bool _obscure = true;
  @override
  void dispose() {
    _email.dispose();
    _pwd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('登入')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextFormField(
                  controller: _email,
                  decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined)),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? '請輸入 Email' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _pwd,
                  decoration: InputDecoration(
                    labelText: '密碼',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                        icon: Icon(
                            _obscure ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscure = !_obscure)),
                  ),
                  obscureText: _obscure,
                  validator: (v) => (v == null || v.isEmpty) ? '請輸入密碼' : null,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: auth.loading
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) return;
                            await ref
                                .read(authProvider.notifier)
                                .signIn(_email.text.trim(), _pwd.text);
                            final ok = ref.read(authProvider).isSignedIn;
                            if (ok && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('登入成功')));
                              context.go('/'); // ✅ 直接回首页（/shop 用 /shop）
                              Navigator.of(context).pop();
                            } else if (context.mounted && auth.error != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('登入失敗：${auth.error}')));
                            }
                          },
                    child: auth.loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('登入'),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
