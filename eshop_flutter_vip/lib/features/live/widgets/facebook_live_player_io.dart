import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class FacebookLivePlayer extends StatefulWidget {
  final String url;
  const FacebookLivePlayer({Key? key, required this.url}) : super(key: key);

  @override State<FacebookLivePlayer> createState() => _FacebookLivePlayerState();
}

class _FacebookLivePlayerState extends State<FacebookLivePlayer> {
  late final WebViewController _controller;
  @override
  void initState() {
    super.initState();
    if (defaultTargetPlatform == TargetPlatform.android) {
      final params = const AndroidWebViewControllerCreationParams();
      final androidCtrl = AndroidWebViewController(params)
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..loadRequest(Uri.parse(widget.url));
      _controller = androidCtrl;
    } else {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..loadRequest(Uri.parse(widget.url));
    }
  }
  @override
  Widget build(BuildContext context) => WebViewWidget(controller: _controller);
}
