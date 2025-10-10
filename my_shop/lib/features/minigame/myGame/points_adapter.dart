// lib/features/minigame/gacha_puzzle/points_adapter.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 你项目里已有的 meProvider：
///   await ref.read(meProvider.notifier).addPoints(delta);
/// 如果你已经有，就把下面两行替换为你的真实 import & provider 引用：
// import '../../providers/user_providers.dart' show meProvider;

final pointsServiceProvider = Provider<PointsService>((ref) {
  return PointsService(ref);
});

class PointsService {
  final Ref ref;
  PointsService(this.ref);

  Future<void> add(int delta) async {
    try {
      // ✅ 如果你有真实的 meProvider，放开这行并注释掉下面的 mock
      // await ref.read(meProvider.notifier).addPoints(delta);

      // --- mock（无真实接口时可先看到 UI 效果） ---
      await Future<void>.delayed(const Duration(milliseconds: 300));
    } catch (_) {
      // 安静失败：积分加不上不影响过关弹窗
    }
  }
}
