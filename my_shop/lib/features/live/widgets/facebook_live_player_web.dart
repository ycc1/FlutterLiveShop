// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html';
// import 'dart:ui' as ui; // for platformViewRegistry
import 'dart:ui_web' as ui_web; // for platformViewRegistry
import 'package:flutter/material.dart';

class FacebookLivePlayer extends StatelessWidget {
  final String url; // Facebook plugins 形式的完整網址
  const FacebookLivePlayer({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    final viewType = 'fb-live-${url.hashCode}';
    // 註冊 iframe 工廠
    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final iframe = IFrameElement()
        ..src = url
        ..style.border = '0'
        ..allow = 'autoplay; encrypted-media; fullscreen; picture-in-picture'
        ..allowFullscreen = true;
      return iframe;
    });

    return AspectRatio(
      aspectRatio: 476/476,
      child: HtmlElementView(viewType: viewType),
    );
  }
}