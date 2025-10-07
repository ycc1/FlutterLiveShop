import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/chat/chat_service.dart';
import '../features/chat/chat_service_mock.dart';
// import '../features/chat/socketio_chat_service.dart';
// import '../features/chat/signalr_chat_service.dart';

final chatServiceProvider = Provider<ChatService>((ref){
  // 切換到任一實作即可：SocketIoChatService / SignalRChatService
  return MockChatService();
});
