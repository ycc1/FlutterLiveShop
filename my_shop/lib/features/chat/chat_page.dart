import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/chat_providers.dart';
import 'chat_service.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({Key? key}) : super(key: key);
  @override ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final List<ChatEvent> logs = [];
  final controller = TextEditingController();
  @override void initState() {
    super.initState();
    final svc = ref.read(chatServiceProvider);
    svc.connect(token: 'mock', room: 'room-1');
    svc.events().listen((e){ if(mounted) setState(()=> logs.add(e)); });
  }
  @override void dispose(){ controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final svc = ref.read(chatServiceProvider);
    return Column(
      children: [
        Expanded(child: ListView.builder(
          itemCount: logs.length,
          itemBuilder: (_, i){
            final e = logs[i];
            if(e.type=='like'){ return const ListTile(leading: Icon(Icons.favorite, color: Colors.pink), title: Text('點讚')); }
            if(e.type=='system'){ return ListTile(leading: const Icon(Icons.info), title: Text(e.content??'')); }
            return ListTile(leading: const Icon(Icons.chat_bubble_outline), title: Text('${e.from??''}: ${e.content??''}'));
          },
        )),
        Row(children: [
          Expanded(child: TextField(controller: controller, decoration: const InputDecoration(hintText: '說點什麼...', border: OutlineInputBorder()))),
          const SizedBox(width: 8),
          IconButton(icon: const Icon(Icons.favorite), onPressed: ()=> svc.sendLike()),
          IconButton(icon: const Icon(Icons.send), onPressed: (){ final t = controller.text.trim(); if(t.isNotEmpty){ svc.sendText(t); controller.clear(); } }),
        ])
      ],
    );
  }
}
