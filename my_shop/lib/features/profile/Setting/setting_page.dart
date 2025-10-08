import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/user_providers.dart';

class SettingPage extends ConsumerWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meAsync = ref.watch(meProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: meAsync.when(
        data: (me) => ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            ListTile(leading: Icon(Icons.location_on_outlined), title: Text('Profile')),
            ListTile(leading: Icon(Icons.location_on_outlined), title: Text('Password')),
            ListTile(leading: Icon(Icons.receipt_long_outlined), title: Text('Address management')),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('載入失敗：$e')),
      ),
    );
  }
}