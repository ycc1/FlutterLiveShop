import 'dart:io';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

void setupWebViewPlatform() {
  try {
    if (Platform.isAndroid) {
      WebViewPlatform.instance = SurfaceAndroidWebView();
    }
  } catch (e) {
    // ignore on platforms where packages are unavailable
  }
}
