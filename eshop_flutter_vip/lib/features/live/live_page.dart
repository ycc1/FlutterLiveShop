import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'widgets/facebook_live_player.dart';
import '../chat/chat_page.dart';

class LivePage extends StatelessWidget {
  const LivePage({Key? key}) : super(key: key);
  static const fbUrl = 'https://www.facebook.com/plugins/video.php?height=476&href=https%3A%2F%2Fwww.facebook.com%2Fgonelivegaming%2Fvideos%2F659033760590366%2F&show_text=false&width=476&t=0';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(ignoring: true, child: FacebookLivePlayer(url: fbUrl)),
          ),
          Positioned.fill(
            child: PointerInterceptor(
              child: DraggableScrollableSheet(
                initialChildSize: 0.4, minChildSize: 0.25, maxChildSize: 0.9,
                builder: (context, controller){
                  return SafeArea(
                    top: false,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                        border: Border.all(color: Colors.white24, width: 0.5),
                      ),
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                      child: const ChatPage(),
                    ),
                  );
                },
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(children: const [
                Icon(Icons.live_tv, color: Colors.white), SizedBox(width: 8),
                Text('直播間', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
