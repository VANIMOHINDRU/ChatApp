import 'package:flutter/material.dart';
import 'package:chat/chat_messages.dart';
import 'package:chat/new_message.dart';
import 'package:chat/main.dart';

class Chat extends StatelessWidget {
  const Chat({super.key});

  void _logout(BuildContext context) async {
    await supabase.auth.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat Screen'), actions: [
        IconButton(
            onPressed: () {
              _logout(context);
            },
            icon: const Icon(Icons.logout))
      ]),
      body: Container(
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
        child: const Column(
          children: [Expanded(child: ChatMessages()), NewMessage()],
        ),  
      ),
    );
  }
}
