import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class LiveVideoPlayer extends StatefulWidget {
  final String url; // HLS(.m3u8) 或 MP4 皆可
  const LiveVideoPlayer({super.key, required this.url});
  @override
  State<LiveVideoPlayer> createState() => _LiveVideoPlayerState();
}

class _LiveVideoPlayerState extends State<LiveVideoPlayer> {
  late final VideoPlayerController _ctrl;
  ChewieController? _chewie;
  @override
  void initState() {
    super.initState();
    _ctrl = widget.url.endsWith('.m3u8')
        ? VideoPlayerController.networkUrl(Uri.parse(widget.url), httpHeaders: const {})
        : VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _ctrl.initialize().then((_) {
      _chewie = ChewieController(videoPlayerController: _ctrl, autoPlay: true, looping: true);
      setState(() {});
    });
  }
  @override
  void dispose() { _chewie?.dispose(); _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    if (_chewie == null || !_ctrl.value.isInitialized) {
      return const AspectRatio(aspectRatio: 16/9, child: Center(child: CircularProgressIndicator()));
    }
    return AspectRatio(aspectRatio: _ctrl.value.aspectRatio, child: Chewie(controller: _chewie!));
  }
}