// lib/features/chat/socketio_chat_service.dart
import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;
import 'chat_service.dart';

class SocketIoChatService implements ChatService {
  io.Socket? _s;
  final _ctrl = StreamController<ChatEvent>.broadcast();
  @override
  Future<void> connect({required String token, required String room}) async {
    _s = io.io(
      'https://your-chat-host',
      io.OptionBuilder().setTransports(['websocket']).setExtraHeaders({'Authorization':'Bearer $token'}).build()
    );
    _s!.onConnect((_) { _s!.emit('join', {'room': room}); });
    _s!.on('message', (data){ _ctrl.add(ChatEvent('message', from: data['from'], content: data['text'])); });
    _s!.on('like',    (data){ _ctrl.add(const ChatEvent('like')); });
    _s!.on('system',  (data){ _ctrl.add(ChatEvent('system', content: data.toString())); });
  }
  @override
  Future<void> disconnect() async {
    _s?.dispose();          // dispose 不需要 await
    await _ctrl.close();    // close 是 Future，可以 await
  }

  @override
  Stream<ChatEvent> events() => _ctrl.stream;
  @override
  Future<void> sendText(String text, {String? toUser}) async => _s?.emit('send', {'text': text, 'to': toUser});
  @override
  Future<void> sendLike() async => _s?.emit('like', {});
}