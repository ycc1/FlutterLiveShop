import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

// 条件导入：Web 才会导入带 dart:html 的实现；其他平台导入 stub
import 'facebook_live_player_web_stub.dart'
  if (dart.library.html) 'facebook_live_player_web.dart' as web;

/// 把原始链接转换为可嵌入的 embed URL（支持 FB / YouTube）
String toEmbedUrl(String url) {
  final u = Uri.tryParse(url.trim());
  if (u == null) return url;
  final host = u.host.toLowerCase();

  // YouTube
  if (host.contains('youtu.be') || host.contains('youtube.com')) {
    if (host.contains('youtu.be')) {
      final id = u.pathSegments.isNotEmpty ? u.pathSegments.first : '';
      return 'https://www.youtube.com/embed/$id?autoplay=1&playsinline=1';
    }
    final v = u.queryParameters['v'];
    if (v != null && v.isNotEmpty) {
      return 'https://www.youtube.com/embed/$v?autoplay=1&playsinline=1';
    }
    if (u.pathSegments.isNotEmpty && u.pathSegments.first == 'shorts') {
      final id = u.pathSegments.length > 1 ? u.pathSegments[1] : '';
      return 'https://www.youtube.com/embed/$id?autoplay=1&playsinline=1';
    }
    if (u.pathSegments.isNotEmpty && u.pathSegments.first == 'live') {
      final id = u.pathSegments.length > 1 ? u.pathSegments[1] : '';
      return 'https://www.youtube.com/embed/$id?autoplay=1&playsinline=1';
    }
    return url;
  }

  // Facebook：若不是 plugins/video.php，自动包一层
  if (host.contains('facebook.com')) {
    if (u.path.contains('plugins/video.php')) return url;
    final encoded = Uri.encodeComponent(url);
    return 'https://www.facebook.com/plugins/video.php?href=$encoded&show_text=false&autoplay=true';
  }

  return url;
}

class UniversalLivePlayer extends StatefulWidget {
  final String url;
  const UniversalLivePlayer({super.key, required this.url});

  @override
  State<UniversalLivePlayer> createState() => _UniversalLivePlayerState();
}

class _UniversalLivePlayerState extends State<UniversalLivePlayer> {
  WebViewController? _controller;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      final embed = toEmbedUrl(widget.url);
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.black)
        // 注：4.9.0 没有 setMediaPlaybackRequiresUserGesture；如需自动播可升级到 5.x 用 setWebViewSettings
        ..loadRequest(Uri.parse(embed));
    }
  }

  @override
  Widget build(BuildContext context) {
    final embed = toEmbedUrl(widget.url);
    if (kIsWeb) {
      return web.FacebookLivePlayerWeb(url: embed); // 复用你的 Web 版 iframe
    }
    return _controller == null
        ? const SizedBox.shrink()
        : WebViewWidget(controller: _controller!);
  }
}
