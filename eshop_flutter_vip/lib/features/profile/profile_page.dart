import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_providers.dart';
import '../../providers/auth_providers.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({Key? key}) : super(key: key);
  Color _vipColor(String vip){
    switch(vip){
      case 'Platinum': return Colors.blueGrey.shade200;
      case 'Gold': return const Color(0xFFFFD700);
      case 'Silver': return const Color(0xFFC0C0C0);
      default: return const Color(0xFFCD7F32); // Bronze
    }
  }
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(meProvider);
    final authed = ref.watch(authProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: me.when(
        data: (u)=> ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(children: [
              CircleAvatar(backgroundImage: NetworkImage(u.avatar), radius: 32),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(u.name, style: Theme.of(context).textTheme.titleMedium),
                Text(u.email, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 6),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _vipColor(u.vipLevel), borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('VIP ${u.vipLevel}', style: const TextStyle(color: Colors.black)),
                  ),
                  const SizedBox(width: 8),
                  Text('Points: ${u.points}'),
                ]),
              ])),
            ]),
            const Divider(height: 24),
            if(!authed.isSignedIn)
              FilledButton(onPressed: ()=> Navigator.pushNamed(context, '/login'), child: const Text('登入')),
            if(authed.isSignedIn)
              FilledButton(onPressed: ()=> ref.read(authProvider.notifier).signOut(), child: const Text('登出')),
          ],
        ),
        loading: ()=> const Center(child: CircularProgressIndicator()),
        error: (e, _)=> Center(child: Text('載入失敗：$e')),
      ),
    );
  }
}
