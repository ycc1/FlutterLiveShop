import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_providers.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meAsync = ref.watch(meProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: meAsync.when(
        data: (me) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              leading: CircleAvatar(backgroundImage: NetworkImage(me.avatar), radius: 28),
              title: Text(me.name), subtitle: Text(me.email),
            ),
            const Divider(),
            const ListTile(leading: Icon(Icons.location_on_outlined), title: Text('地址管理')),
            const ListTile(leading: Icon(Icons.receipt_long_outlined), title: Text('訂單記錄')),
            const ListTile(leading: Icon(Icons.settings_outlined), title: Text('設定')),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('載入失敗：$e')),
      ),
    );
  }
}