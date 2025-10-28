import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/auth_providers.dart';

/// 提供给 GoRouter 的 refreshListenable；当 authProvider 变化时，触发路由重算。
final routerRefreshListenableProvider = Provider<Listenable>((ref) {
  final notifier = _RouterListenable();
  // 监听 authProvider 的变化，触发路由刷新（用于重跑 redirect）
  ref.listen<AuthState>(authProvider, (_, __) {
    notifier.notify();
  });
  ref.onDispose(() => notifier.dispose());
  return notifier;
});

class _RouterListenable extends ChangeNotifier {
  void notify() => notifyListeners();
}
