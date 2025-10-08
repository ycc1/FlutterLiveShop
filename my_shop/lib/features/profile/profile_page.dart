import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/user_providers.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meAsync = ref.watch(meProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: meAsync.when(
        data: (me) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              leading: me.avatarImage != null && me.avatarImage.isNotEmpty
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(me.avatarImage), radius: 28)
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
              // ✅ 昵称与 VIP 同行，VIP 可点击跳转
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      me.nickName?.toString() ?? '未命名',
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // ✅ VIP 可点：点击跳转到 /vip 或外部说明页
                  InkWell(
                    onTap: () => context.push('/vip'), // 🔗 GoRouter 跳转内部页面
                    // 若要打开外部网址用：
                    // onTap: () async {
                    //   final url = Uri.parse('https://yourdomain.com/vip');
                    //   if (await canLaunchUrl(url)) await launchUrl(url);
                    // },
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
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.amber[900],
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Text(me.email),
            ),
            const Divider(),
            const ListTile(
                leading: Icon(Icons.location_on_outlined), title: Text('地址管理')),
            const ListTile(
                leading: Icon(Icons.receipt_long_outlined),
                title: Text('訂單記錄')),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('設定'),
              onTap: () => context.push('/settings'),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('載入失敗：$e')),
      ),
    );
  }
}
