// 顶部多加：import 'dart:ui_web' as ui_web;
import 'dart:ui_web' as ui_web;
import 'dart:html' as html;
import 'package:flutter/material.dart';

class FacebookLivePlayerWeb extends StatelessWidget {
  final String url;
  const FacebookLivePlayerWeb({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    final viewType = 'iframe-${url.hashCode}';
    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final iframe = html.IFrameElement()
        ..src = url
        ..style.border = '0'
        ..allow = 'autoplay; encrypted-media; picture-in-picture;'
        ..allowFullscreen = true;
      return iframe;
    });
    return HtmlElementView(viewType: viewType);
  }
}
