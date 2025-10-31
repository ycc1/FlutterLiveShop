// lib/features/settings/setting_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/user_providers.dart';
import '../../../providers/api_providers.dart';
import 'user_account_service.dart';

class SettingPage extends ConsumerWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meAsync = ref.watch(meProvider);

    Future<void> _openChangePwdDialog() async {
      final api = ref.read(apiClientProvider);
      final svc = UserAccountService(api);
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => _ChangePwdDialog(onSubmit: (oldPwd, newPwd, otp) async {
          await svc.updatePassword(oldPwd: oldPwd, newPwd: newPwd, otpCode: otp);
        }),
      );
      if (ok == true && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('密码已更新')),
        );
      }
    }

    Future<void> _openChangeEmailDialog() async {
      final api = ref.read(apiClientProvider);
      final svc = UserAccountService(api);
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => _ChangeEmailDialog(onSubmit: (email) async {
          await svc.updateEmail(email: email);
          // 同步 meProvider（若你的 UserProfile 有 email 字段）
          final me = ref.read(meProvider).valueOrNull;
          if (me != null) {
            ref.read(meProvider.notifier).setUser(me.copyWith(email: email));
          }
        }),
      );
      if (ok == true && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('邮箱已更新')),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: meAsync.when(
        data: (me) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              subtitle: Text(me.nickName ?? me.userName ?? ''),
            ),
            ListTile(
              leading: const Icon(Icons.lock_clock),
              title: const Text('Password'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _openChangePwdDialog,
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email'),
              subtitle: Text(me.email ?? '未设定'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _openChangeEmailDialog,
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('载入失败：$e')),
      ),
    );
  }
}

class _ChangePwdDialog extends StatefulWidget {
  const _ChangePwdDialog({required this.onSubmit});
  final Future<void> Function(String oldPwd, String newPwd, String otp) onSubmit;

  @override
  State<_ChangePwdDialog> createState() => _ChangePwdDialogState();
}

class _ChangePwdDialogState extends State<_ChangePwdDialog> {
  final _form = GlobalKey<FormState>();
  final _old = TextEditingController();
  final _pwd = TextEditingController();
  final _pwd2 = TextEditingController();
  final _otp = TextEditingController();
  bool _loading = false;
  bool _ob1 = true, _ob2 = true, _ob3 = true;

  @override
  void dispose() {
    _old.dispose(); _pwd.dispose(); _pwd2.dispose(); _otp.dispose();
    super.dispose();
  }

  String? _validateOldPwd(String? v) {
    // “旧密码 & OTP 至少填一个”
    if ((v == null || v.isEmpty) && (_otp.text.trim().isEmpty)) {
      return '旧密码与 OTP 需至少填一项';
    }
    return null; // 有填或另一项有填即通过
  }

  String? _validateOtp(String? v) {
    if ((v == null || v.isEmpty) && (_old.text.trim().isEmpty)) {
      return '旧密码与 OTP 需至少填一项';
    }
    return null;
  }



  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    if (_pwd.text != _pwd2.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('两次新密码不一致')));
      return;
    }

    final oldPwd = _old.text.trim();
    final otp = _otp.text.trim();
    if (oldPwd.isEmpty && otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请填写旧密码或 OTP 任一项')));
      return;
    }

    setState(() => _loading = true);
    try {
      await widget.onSubmit(oldPwd, _pwd.text.trim(), otp);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('修改失败：$e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('修改密码'),
      content: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 旧密码
              TextFormField(
                controller: _old,
                decoration: InputDecoration(
                  labelText: '旧密码（或填下方 OTP）',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_ob1 ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _ob1 = !_ob1),
                  ),
                ),
                obscureText: _ob1,
                validator: _validateOldPwd,
              ),
              const SizedBox(height: 8),

              // 新密码
              TextFormField(
                controller: _pwd,
                decoration: InputDecoration(
                  labelText: '新密码',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_ob2 ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _ob2 = !_ob2),
                  ),
                ),
                obscureText: _ob2,
                validator: (v) => (v == null || v.length < 6) ? '至少 6 位' : null,
              ),
              const SizedBox(height: 8),

              // 确认新密码
              TextFormField(
                controller: _pwd2,
                decoration: InputDecoration(
                  labelText: '确认新密码',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_ob3 ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _ob3 = !_ob3),
                  ),
                ),
                obscureText: _ob3,
                validator: (v) => (v == null || v.isEmpty) ? '请再输入一次新密码' : null,
              ),
              const SizedBox(height: 8),

              // OTP
              TextFormField(
                controller: _otp,
                decoration: const InputDecoration(
                  labelText: 'OTP 验证码（或填上方旧密码）',
                  prefixIcon: Icon(Icons.verified_user_outlined),
                ),
                keyboardType: TextInputType.number,
                validator: _validateOtp,
              ),

              const SizedBox(height: 6),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('提示：旧密码 与 OTP 任选其一填写即可。', style: TextStyle(fontSize: 12, color: Colors.black54)),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _loading ? null : () => Navigator.pop(context), child: const Text('取消')),
        FilledButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('确定'),
        ),
      ],
    );
  }
}

class _ChangeEmailDialog extends StatefulWidget {
  const _ChangeEmailDialog({required this.onSubmit});
  final Future<void> Function(String email) onSubmit;

  @override
  State<_ChangeEmailDialog> createState() => _ChangeEmailDialogState();
}

class _ChangeEmailDialogState extends State<_ChangeEmailDialog> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await widget.onSubmit(_email.text.trim());
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('修改失败：$e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('修改邮箱'),
      content: Form(
        key: _form,
        child: TextFormField(
          controller: _email,
          decoration: const InputDecoration(
            labelText: '新邮箱',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (v) {
            if (v == null || v.isEmpty) return '请输入邮箱';
            final ok = RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w+$').hasMatch(v);
            return ok ? null : '邮箱格式不正确';
          },
        ),
      ),
      actions: [
        TextButton(onPressed: _loading ? null : () => Navigator.pop(context), child: const Text('取消')),
        FilledButton(onPressed: _loading ? null : _submit, child: _loading ? const SizedBox(width:16,height:16,child:CircularProgressIndicator(strokeWidth:2)) : const Text('确定')),
      ],
    );
  }
}
