// lib/features/live/live_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'widgets/universal_live_player.dart';
import '../chat/chat_page.dart';

class LivePage extends StatefulWidget {
  const LivePage({super.key});

  // 两个示例链接：任选其一
  static const urlFB =
      'https://www.facebook.com/plugins/video.php?height=476&href=https%3A%2F%2Fwww.facebook.com%2Fgonelivegaming%2Fvideos%2F659033760590366%2F&show_text=false&width=476&t=0';
  static const urlYT =
      'https://youtu.be/0BkKC01jifg?si=3Kjl2yOE8acP_ke0';

  @override
  State<LivePage> createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> {
  bool _fullscreen = false;
  static const String _url = LivePage.urlYT; // 想播 FB 改成 LivePage.urlFB

  @override
  void dispose() {
    // 确保离开页面时退出全屏
    _exitFullscreenIfNeeded();
    super.dispose();
  }

  Future<void> _enterFullscreen() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // 横竖屏随你：若想强制横屏可放开下面两行
    // await SystemChrome.setPreferredOrientations(
    //     [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    setState(() => _fullscreen = true);
  }

  Future<void> _exitFullscreenIfNeeded() async {
    if (!_fullscreen) return;
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    setState(() => _fullscreen = false);
  }

  void _toggleFullscreen() {
    if (_fullscreen) {
      _exitFullscreenIfNeeded();
    } else {
      _enterFullscreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false, // 让内容延伸到状态栏区域
      backgroundColor: Colors.black,
      // 全屏模式下不显示原生 AppBar；非全屏可保留（也可统一用悬浮条）
      appBar: _fullscreen
          ? null
          : AppBar(
              title: const Text('直播'),
              backgroundColor: Colors.transparent,
              elevation: 0,
              foregroundColor: Colors.white,
            ),
      body: Stack(
        children: [
          // 背景满版播放器
          const Positioned.fill(child: UniversalLivePlayer(url: _url)),

          // 顶部悬浮控制条（返回 / 标题 / 全屏切换）
          SafeArea(
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(.6), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  // 返回
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () async {
                      await _exitFullscreenIfNeeded();
                      if (context.mounted) Navigator.of(context).maybePop();
                    },
                  ),
                  const SizedBox(width: 4),
                  const Expanded(
                    child: Text(
                      '直播',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // 切换播放源（可选：注释掉）
                  // IconButton(
                  //   icon: const Icon(Icons.switch_video, color: Colors.white),
                  //   onPressed: () { /* TODO: 打开选择器 / 设置页更换 URL */ },
                  // ),
                  // 全屏切换
                  IconButton(
                    icon: Icon(_fullscreen ? Icons.fullscreen_exit : Icons.fullscreen, color: Colors.white),
                    onPressed: _toggleFullscreen,
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),

          // 底部可拖动聊天室浮层
          DraggableScrollableSheet(
            initialChildSize: 0.35, // 初始高度占屏比
            minChildSize: 0.18,
            maxChildSize: 0.65,
            builder: (context, scrollCtrl) {
              return SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          children: [
                            // 顶部把手
                            Container(
                              height: 20,
                              alignment: Alignment.center,
                              child: Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            // 聊天室主体
                            Expanded(
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  iconTheme: const IconThemeData(color: Colors.white70),
                                  textTheme: Theme.of(context).textTheme.apply(bodyColor: Colors.white),
                                  inputDecorationTheme: const InputDecorationTheme(
                                    hintStyle: TextStyle(color: Colors.white70),
                                  ),
                                ),
                                child: const ChatPage(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
