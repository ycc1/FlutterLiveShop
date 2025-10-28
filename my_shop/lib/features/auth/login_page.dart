import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_providers.dart';
import '../../providers/user_providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  final String? from; // 登入後回跳
  const LoginPage({Key? key, this.from}) : super(key: key);

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _account = TextEditingController(); // 手機/帳號/Email
  final _pwdOrCode = TextEditingController(); // 密碼/驗證碼
  bool _obscure = true;

  String _countryCode = '63';
  final List<String> _codes = const ['63', '886', '852', '65', '60', '62'];

  Timer? _otpTimer;
  int _cooldown = 0;

  @override
  void dispose() {
    _otpTimer?.cancel();
    _account.dispose();
    _pwdOrCode.dispose();
    super.dispose();
  }

  void _startCooldown([int seconds = 60]) {
    setState(() => _cooldown = seconds);
    _otpTimer?.cancel();
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _cooldown--;
        if (_cooldown <= 0) t.cancel();
      });
    });
  }

  String _composeMobile(String raw, String cc) {
    var digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith(cc)) return digits;
    if (digits.startsWith('0')) digits = digits.substring(1);
    return '$cc$digits';
  }

  bool _looksLikePhone(String input) {
    final s = input.trim();
    return RegExp(r'^[\d\+\-\s]+$').hasMatch(s) && !s.contains('@');
  }

  Future<void> _doLogin(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    String account = _account.text.trim();
    final pwdOrCode = _pwdOrCode.text;
    if (_looksLikePhone(account)) {
      account = _composeMobile(account, _countryCode);
    }

    await ref.read(authProvider.notifier).signIn(account, pwdOrCode);

    // ✅ await 之后，先判断
    if (!mounted) return;

    final ok = ref.read(authProvider).isSignedIn; // 现在用 ref 安全了
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('登入成功')),
      );
      final dest = widget.from ?? '/';
      context.go(dest);
    } else {
      final err = ref.read(authProvider).error ?? '未知錯誤';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('登入失敗：$err')),
      );
    }
  }

  Future<void> _getOtp(WidgetRef ref, BuildContext context) async {
    final raw = _account.text.trim();
    if (raw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請先輸入手機號')),
      );
      return;
    }
    if (_cooldown > 0) return;

    final mobile = _composeMobile(raw, _countryCode);
    final err = await ref.read(authProvider.notifier).sendOtp(mobile);
    if (!mounted) return;
    if (err == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('驗證碼已發送至 +$mobile')),
      );
      _startCooldown(60);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('發送失敗：$err')),
      );
    }
  }

  /// 統一的返回行為：能 pop 就 pop；否則回到 from 或首頁
  void _handleBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go(widget.from ?? '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    return WillPopScope(
      onWillPop: () async {
        if (Navigator.of(context).canPop()) return true;
        // 沒有可回退的頁面 → 導向 from 或首頁，並攔截系統返回
        context.go(widget.from ?? '/');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('登入'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _handleBack(context),
            tooltip: '返回',
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextFormField(
                    controller: _account,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: '手機 / 帳號 / Email',
                      prefixIcon: SizedBox(
                        width: 90,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 8),
                            const Text('+'),
                            DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _countryCode,
                                items: _codes
                                    .map((c) => DropdownMenuItem(
                                          value: c,
                                          child: Text(c),
                                        ))
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) {
                                    setState(() => _countryCode = v);
                                  }
                                },
                              ),
                            ),
                            const VerticalDivider(width: 1, thickness: 1),
                          ],
                        ),
                      ),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? '請輸入手機/帳號/Email' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _pwdOrCode,
                    decoration: InputDecoration(
                      labelText: '密碼 / 驗證碼',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: (_cooldown == 0 && !auth.loading)
                                ? () => _getOtp(ref, context)
                                : null,
                            child: Text(
                                _cooldown == 0 ? '取得驗證碼' : '${_cooldown}s'),
                          ),
                          IconButton(
                            icon: Icon(_obscure
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ],
                      ),
                    ),
                    obscureText: _obscure,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? '請輸入密碼或驗證碼' : null,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: auth.loading ? null : () => _doLogin(context),
                      child: auth.loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('登入'),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
    ;
  }
}
