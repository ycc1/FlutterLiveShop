import 'package:flutter/material.dart';
import 'widgets/facebook_live_player.dart';
import '../chat/chat_page.dart';

class LivePage extends StatelessWidget {
  const LivePage({super.key});

  static const fbUrl = 'https://www.facebook.com/plugins/video.php?height=476&href=https%3A%2F%2Fwww.facebook.com%2Fgonelivegaming%2Fvideos%2F659033760590366%2F&show_text=false&width=476&t=0';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('直播')),
      body: Column(
        children: const [
          Expanded(flex: 3, child: FacebookLivePlayer(url: fbUrl)),
          Divider(height: 1),
          Expanded(flex: 2, child: ChatPage()),
        ],
      ),
    );
  }
}