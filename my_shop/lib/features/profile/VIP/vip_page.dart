import 'package:flutter/material.dart';

class VipPage extends StatelessWidget {
  const VipPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('VIP 等级说明')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('您的当前等级：VIP 3',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text('等级说明：',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Text('VIP 1：新用户注册\nVIP 2：累计积分 5000\nVIP 3：累计积分 20000\nVIP 4：累计积分 50000'),
            SizedBox(height: 20),
            Text('福利：享受专属折扣、积分加成、优先客服等权益。'),
          ],
        ),
      ),
    );
  }
}
