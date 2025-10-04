import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FacebookLivePlayer extends StatefulWidget {
  final String url; // Facebook plugins 形式的完整網址
  const FacebookLivePlayer({super.key, required this.url});

  @override
  State<FacebookLivePlayer> createState() => _FacebookLivePlayerState();
}

class _FacebookLivePlayerState extends State<FacebookLivePlayer> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) => AspectRatio(
        aspectRatio: 476/476, // 可依需求調整
        child: WebViewWidget(controller: _controller),
      );
}