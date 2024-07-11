import 'package:hive/hive.dart';

part 'chat_session.g.dart';

@HiveType(typeId: 1)
class ChatSession {
  @HiveField(0)
  List<String> message;

  ChatSession({required this.message});
}
