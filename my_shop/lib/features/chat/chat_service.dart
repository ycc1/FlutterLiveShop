// lib/features/chat/chat_service.dart
abstract class ChatService {
  Future<void> connect({required String token, required String room});
  Future<void> disconnect();
  Stream<ChatEvent> events();
  Future<void> sendText(String text, {String? toUser});
  Future<void> sendLike();
}

class ChatEvent {
  final String type; // message/system/like/typing
  final String? from;
  final String? content;
  const ChatEvent(this.type, {this.from, this.content});
}