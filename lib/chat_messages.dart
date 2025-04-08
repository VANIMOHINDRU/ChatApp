import 'package:flutter/material.dart';

import 'package:chat/main.dart';
import 'package:chat/messages_bubble.dart';

class ChatMessages extends StatefulWidget {
  const ChatMessages({super.key});

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  final userId = supabase.auth.currentUser!.id;

  List<Map<String, dynamic>> _userProfiles = [];
  late dynamic _subscription;

  final Stream<List<Map<String, dynamic>>> _messageStream = supabase
      .from('messages')
      .stream(primaryKey: ['id']).order('created_at', ascending: true);

  void _fetchUserProfiles() async {
    try {
      final profiles =
          await supabase.from('profiles').select('id, username, avatar_url');

      setState(() {
        _userProfiles = profiles;
      });
    } catch (e) {
      print('Error fetching user profiles: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserProfiles();
  }

  @override
  void dispose() {
    if (_subscription != null) {
      _subscription.unsubscribe();
    }
    super.dispose();
  }

  String? _getUserAvatarUrl(String userId) {
    try {
      final profile = _userProfiles.firstWhere(
        (profile) {
          return profile['id'] == userId;
        },
      );
      return profile['avatar_url'];
    } catch (e) {
      // If no profile is found, return null
      return null;
    }
  }

  String? _getUserName(String userId) {
    try {
      final profile = _userProfiles.firstWhere(
        (profile) {
          return profile['id'] == userId;
        },
      );
      return profile['username'];
    } catch (e) {
      // If no profile is found, return null
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _messageStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final messages = snapshot.data!;
        final rmessages = messages.reversed.toList();
        return _buildMess(rmessages);
      },
    );
  }

  Widget _buildMess(List<Map<String, dynamic>> rmessages) {
    return ListView.builder(
        padding: const EdgeInsets.only(bottom: 40, left: 30, right: 30),
        reverse: true, //list goes from bottom to up
        itemCount: rmessages.length,
        itemBuilder: (context, index) {
          // return ListTile(title: Text(rmessages[index]

          final chatMessage = rmessages[index];
          final nextChatMessage =
              index + 1 < rmessages.length ? rmessages[index + 1] : null;
          final currentMessageUserId = chatMessage['user_id'];
          final nextMessageUserId =
              nextChatMessage != null ? nextChatMessage['user_id'] : null;
          final nextUserIsSame = currentMessageUserId == nextMessageUserId;
          return !nextUserIsSame
              ? MessageBubble.first(
                  userImage: _getUserAvatarUrl(chatMessage['user_id']),
                  userName: _getUserName(chatMessage['user_id']),
                  message: chatMessage['message'],
                  isMe: chatMessage['user_id'] == userId,
                )
              : MessageBubble.next(
                  message: chatMessage['message'],
                  isMe: chatMessage['user_id'] == userId,
                );
        });
  }
}
