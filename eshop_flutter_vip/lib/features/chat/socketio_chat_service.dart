import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'chat_service.dart';

class SocketIoChatService implements ChatService {
  io.Socket? _s;
  final _ctrl = StreamController<ChatEvent>.broadcast();
  @override
  Future<void> connect({required String token, required String room}) async {
    _s = io.io('https://your-socket-host',
      io.OptionBuilder()
        .setTransports(['websocket'])
        .setExtraHeaders({'Authorization':'Bearer $token'})
        .disableAutoConnect()
        .build()
    );
    _s!.connect();
    _s!.onConnect((_) { _s!.emit('join', {'room': room}); _ctrl.add(const ChatEvent('system', content:'Socket.IO 連線成功')); });
    _s!.on('message', (data)=> _ctrl.add(ChatEvent('message', from: data['from']?.toString(), content: data['text']?.toString())));
    _s!.on('like',    (_)   => _ctrl.add(const ChatEvent('like')));
    _s!.onDisconnect((_)    => _ctrl.add(const ChatEvent('system', content:'已斷線')));
  }
  @override Future<void> disconnect() async { _s?.dispose(); await _ctrl.close(); }
  @override Stream<ChatEvent> events() => _ctrl.stream;
  @override Future<void> sendText(String text, {String? to}) async => _s?.emit('send', {'text':text, 'to':to});
  @override Future<void> sendLike() async => _s?.emit('like', {});
}
