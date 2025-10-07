import 'dart:async';
import 'chat_service.dart';

class MockChatService implements ChatService {
  final _ctrl = StreamController<ChatEvent>.broadcast();
  @override Future<void> connect({required String token, required String room}) async {
    _ctrl.add(const ChatEvent('system', content:'已連線 (Mock)'));
  }
  @override Future<void> disconnect() async { await _ctrl.close(); }
  @override Stream<ChatEvent> events() => _ctrl.stream;
  @override Future<void> sendLike() async { _ctrl.add(const ChatEvent('like')); }
  @override Future<void> sendText(String text, {String? to}) async {
    _ctrl.add(ChatEvent('message', from: 'me', content: text));
  }
}
