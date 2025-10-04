// lib/features/chat/chat_page.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'chat_service.dart';
import 'socketio_chat_service.dart';

final chatServiceProvider = Provider<ChatService>((_) => SocketIoChatService());

class ChatPage extends ConsumerStatefulWidget { const ChatPage({super.key});
  @override ConsumerState<ChatPage> createState() => _ChatPageState(); }
class _ChatPageState extends ConsumerState<ChatPage> with TickerProviderStateMixin {
  final List<ChatEvent> logs = [];
  late final AnimationController _likeCtrl;
  @override void initState(){ super.initState(); _likeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800)); }
  @override void dispose(){ _likeCtrl.dispose(); super.dispose(); }
  @override Widget build(BuildContext context){
    final svc = ref.read(chatServiceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('直播聊天室')),
      body: Column(children:[
        Expanded(child: ListView.builder(itemCount: logs.length, itemBuilder: (_, i){
          final e = logs[i];
          return ListTile(leading: e.type=='like'? const Icon(Icons.favorite, color: Colors.pink): const Icon(Icons.chat_bubble_outline),
            title: Text(e.type=='like'? '👏 點讚' : '${e.from??'??'}：${e.content??''}'));
        })),
        SizeTransition(sizeFactor: CurvedAnimation(parent: _likeCtrl, curve: Curves.easeOutBack), child: const Icon(Icons.favorite, color: Colors.pink, size: 48)),
        Padding(padding: const EdgeInsets.all(8), child: Row(children:[
          Expanded(child: TextField(onSubmitted: (t)=> svc.sendText(t), decoration: const InputDecoration(hintText: '說點什麼...', border: OutlineInputBorder()))),
          const SizedBox(width: 8),
          IconButton(icon: const Icon(Icons.favorite), onPressed: (){ svc.sendLike(); _likeCtrl.forward(from: 0); }),
        ]))
      ]),
    );
  }
}