import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/user_providers.dart';
import '../../providers/auth_providers.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final meAsync = ref.watch(meProvider);

    // ✅ 若尚未登入，立即導向登入頁
    if (!auth.isSignedIn) {
      // 使用 WidgetsBinding 確保 context 已初始化後再跳轉
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/login');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: meAsync.when(
        data: (me) {
          if (me == null) {
            // ✅ 若 me 為 null，也導向登入頁
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) context.go('/login');
            });
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                leading: me.avatarImage != null && me.avatarImage.isNotEmpty
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(me.avatarImage),
                        radius: 28,
                      )
                    : CircleAvatar(
                        radius: 28,
                        child: Text(
                          (me.nickName?.isNotEmpty == true
                                  ? me.nickName!.substring(0, 1)
                                  : (me.userName.isNotEmpty
                                      ? me.userName.substring(0, 1)
                                      : '?'))
                              .toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        me.nickName?.toString() ?? '未命名',
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: () => context.push('/vip'),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber[100],
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.amber),
                        ),
                        child: Text(
                          'VIP ${me.vipLevel}',
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: Colors.amber[900],
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Text(me.email),
              ),
              const Divider(),
              const ListTile(
                leading: Icon(Icons.location_on_outlined),
                title: Text('地址管理'),
              ),
              ListTile(
                leading: Icon(Icons.receipt_long_outlined),
                title: Text('訂單記錄'),
                onTap: () => context.push('/orderpage'),
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('設定'),
                onTap: () => context.push('/settings'),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) {
          // ✅ 若 API 錯誤 (可能 token 無效) → 回登入頁
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.go('/login');
          });
          return Center(child: Text('請重新登入...'));
        },
      ),
    );
  }
}
