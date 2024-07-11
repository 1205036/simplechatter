import 'package:bloc/bloc.dart';


class ChatState {
  final StringBuffer buffer;

  ChatState({required this.buffer});
}

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(ChatState(buffer: StringBuffer()));

  void sendMessage(String id, String text) {
    state.buffer.write(text);
    state.buffer.write('\n');
    // boxChats.put(id, ChatSession(message: [state.buffer.toString()]));
    emit(ChatState(buffer: state.buffer));
  }
  void refreshPage()=>emit(ChatState(buffer: state.buffer));

}