// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html';
import 'package:flutter/material.dart';
import 'dart:ui_web' as ui_web;

class FacebookLivePlayer extends StatelessWidget {
  final String url;
  const FacebookLivePlayer({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewType = 'fb-live-${url.hashCode}';
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final iframe = IFrameElement()
        ..src = url
        ..style.border = '0'
        ..allow = 'autoplay; encrypted-media; fullscreen; picture-in-picture'
        ..allowFullscreen = true;
      return iframe;
    });
    return HtmlElementView(viewType: viewType);
  }
}
