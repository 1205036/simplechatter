import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simplechatter/hive/chats.dart';
import 'package:simplechatter/model/chat_session.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'cubit/chat_cubit.dart';

class Chatty extends StatefulWidget {
  final String title;
  final String id;

  const Chatty({
    super.key,
    required this.title,
    required this.id,
  });

  @override
  State<Chatty> createState() => _ChattyState();
}

class _ChattyState extends State<Chatty> {
  final TextEditingController _controller = TextEditingController();
  final buffer = StringBuffer();
  final _channel = WebSocketChannel.connect(
    Uri.parse('wss://echo.websocket.events'),
  );

  @override
  void initState() {
    if (boxChats.containsKey(widget.id)) {
      final messages = (boxChats.get(widget.id,
              defaultValue: ChatSession(message: [])) as ChatSession)
          .message;
      for (final text in messages) {
        buffer.write(text);
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = ChatCubit();

    return BlocBuilder<ChatCubit, ChatState>(
        bloc: bloc,
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.title),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SignOutButton(),
                      // const SizedBox(
                      //   width: 4,
                      // ),
                      // FloatingActionButton.small(
                      //     child: const Icon(Icons.delete),
                      //     onPressed: () async {
                      //       await boxChats.clear();
                      //       await boxChats.flush();
                      //       bloc.refreshPage();
                      //     }),
                    ],
                  ),
                ],
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Form(
                      child: TextFormField(
                        controller: _controller,
                        decoration:
                            const InputDecoration(labelText: 'Send a message'),
                        autofocus: true,
                        onFieldSubmitted: (_) => _sendMessage(bloc, state),
                      ),
                    ),
                    const SizedBox(height: 24),
                    StreamBuilder(
                      stream: _channel.stream,
                      builder: (context, snapshot) {
                        final data = snapshot.hasData ? buffer.toString() : '';
                        return Text(data);
                      },
                    )
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _sendMessage(bloc, state),
              tooltip: 'Send message',
              child: const Icon(Icons.send),
            ),
          );
        });
  }

  void _sendMessage(ChatCubit bloc, ChatState state) {
    if (_controller.text.isNotEmpty) {
      bloc.sendMessage(widget.id, _controller.text);
      buffer.write(_controller.text);
      buffer.write('\n');
      boxChats.put(widget.id, ChatSession(message: [buffer.toString()]));
    }
    _channel.sink.add(buffer.toString());
    _controller.clear();
  }

  @override
  void dispose() {
    _channel.sink.close();
    _controller.dispose();
    // boxChats.clear();
    super.dispose();
  }
}
