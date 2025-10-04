// lib/features/chat/signalr_chat_service.dart
import 'package:signalr_netcore/signalr_client.dart';
import 'chat_service.dart';

class SignalRChatService implements ChatService {
  HubConnection? _hub;
  final _ctrl = StreamController<ChatEvent>.broadcast();
  @override
  Future<void> connect({required String token, required String room}) async {
    _hub = HubConnectionBuilder()
      .withUrl('https://your-api/hubs/chat', options: HttpConnectionOptions(accessTokenFactory: () async => token))
      .withAutomaticReconnect()
      .build();
    _hub!.on('Message', (args){ _ctrl.add(ChatEvent('message', from: args?[0]?.toString(), content: args?[1]?.toString())); });
    _hub!.on('System',  (args){ _ctrl.add(ChatEvent('system', content: args?.first.toString())); });
    _hub!.on('Like',    (args){ _ctrl.add(const ChatEvent('like')); });
    await _hub!.start();
    await _hub!.invoke('JoinRoom', args: [room]);
  }
  @override
  Future<void> disconnect() async { await _hub?.stop(); await _ctrl.close(); }
  @override
  Stream<ChatEvent> events() => _ctrl.stream;
  @override
  Future<void> sendText(String text, {String? toUser}) async => _hub?.invoke('SendToRoom', args: ['room-1', text, 'text']);
  @override
  Future<void> sendLike() async => _hub?.invoke('SendLike', args: ['room-1']);
}