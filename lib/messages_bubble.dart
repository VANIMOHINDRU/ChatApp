import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble.first({
    super.key,
    required this.userImage,
    required this.userName,
    required this.message,
    required this.isMe,
  }) : isFirstInSequence = true;

  const MessageBubble.next({
    super.key,
    required this.message,
    required this.isMe,
  })  : isFirstInSequence = false,
        userImage = null,
        userName = null;

  final bool isFirstInSequence;
  final String? userImage;
  final String? userName;
  final bool isMe;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (userName != null)
          Positioned(
            top: 15,
            right: isMe ? 0 : null,
            child: CircleAvatar(
              backgroundImage: NetworkImage(userImage!), //image
              radius: 23,
            ),
          ),
        Container(
            margin: const EdgeInsets.symmetric(horizontal: 46),
            child: Row(
              mainAxisAlignment:
                  isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment:
                      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    if (isFirstInSequence)
                      const SizedBox(
                        height: 18,
                      ),
                    if (userName != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 13, right: 13),
                        child: Text(
                          userName!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black38,
                          ),
                        ),
                      ),
                    Container(
                      decoration: BoxDecoration(
                          color: isMe
                              ? Colors.grey
                              : const Color.fromARGB(255, 179, 118, 189),
                          borderRadius: BorderRadius.only(
                            topLeft: !isMe && isFirstInSequence
                                ? Radius.zero
                                : const Radius.circular(12),
                            topRight: isMe && isFirstInSequence
                                ? Radius.zero
                                : const Radius.circular(12),
                            bottomLeft: const Radius.circular(12),
                            bottomRight: const Radius.circular(12),
                          )),
                      constraints: const BoxConstraints(maxWidth: 200),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 14,
                      ),
                      margin: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 12,
                      ),
                      child: Text(
                        message,
                        style: TextStyle(
                            height: 1.3,
                            color: isMe
                                ? Colors.black
                                : const Color.fromARGB(255, 235, 234, 234)),
                        softWrap: true,
                      ),
                    )
                  ],
                )
              ],
            ))
      ],
    );
  }
}
