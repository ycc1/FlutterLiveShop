import 'package:flutter/material.dart';
import 'widgets/live_video_player.dart';

class LivePage extends StatelessWidget {
  const LivePage({super.key});
  @override
  Widget build(BuildContext context) {
    // Demo 用公用串流；正式環境建議採 HLS/LL-HLS 或 WebRTC（如 LiveKit）
    const demoUrl = 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8';
    return Scaffold(
      appBar: AppBar(title: const Text('直播')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: const [
          LiveVideoPlayer(url: demoUrl),
          SizedBox(height: 12),
          Text('直播間介紹：這裡可展示商品、聊天室、點讚動畫等擴充組件。'),
        ],
      ),
    );
  }
}