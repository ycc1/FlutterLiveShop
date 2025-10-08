/// Web 平台的 iframe 封装
/// 需要在 web 下使用 HtmlElementView 注册（不支持在移动端）
/// 注意：若你已有旧的 FacebookLivePlayerWeb，可以直接用它。
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HtmlIframe extends StatefulWidget {
  final String embedUrl;
  const HtmlIframe({super.key, required this.embedUrl});

  @override
  State<HtmlIframe> createState() => _HtmlIframeState();
}

class _HtmlIframeState extends State<HtmlIframe> {
  final _viewType = 'html-iframe-${UniqueKey()}';

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      // ignore: undefined_prefixed_name
      ui.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
        final element = IFrameElement()
          ..src = widget.embedUrl
          ..style.border = '0'
          ..allow = 'autoplay; encrypted-media; picture-in-picture;'
          ..allowFullscreen = true;
        return element;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return const SizedBox.shrink();
    // ignore: undefined_prefixed_name
    return HtmlElementView(viewType: _viewType);
  }
}
