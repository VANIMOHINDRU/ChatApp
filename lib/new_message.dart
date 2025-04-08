import 'package:flutter/material.dart';
import 'package:chat/main.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() {
    return _NewMessage();
  }
}

class _NewMessage extends State<NewMessage> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void submitMessage() async {
    final enteredMessage = _messageController.text;

    if (enteredMessage.trim().isEmpty) {
      return;
    }

    final userId = supabase.auth.currentUser!.id;
    await supabase.from('messages').insert({
      'user_id': userId,
      'message': enteredMessage.toString(),
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: const InputDecoration(labelText: 'Send a message...'),
            ), //first letter of each sentence will be capitalized automatically
          ),
          IconButton(onPressed: submitMessage, icon: const Icon(Icons.send))
        ],
      ),
    );
  }
}
