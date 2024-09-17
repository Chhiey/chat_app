import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('created_at', descending: true)
          .snapshots(),
      builder: (ctx, chatSnapshots) {
        if (chatSnapshots.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
          return const Center(
            child: Text('No Messages'),
          );
        }

        if (chatSnapshots.hasError) {
          return const Center(
            child: Text('Something went wrong'),
          );
        }

        final loadMessages = chatSnapshots.data!.docs;

        // Return the ListView.builder here
        return ListView.builder(
            padding: const EdgeInsets.only(
              bottom: 40,
              left: 13,
              right: 13,
            ),
            reverse: true,
            itemCount: loadMessages.length,
            itemBuilder: (ctx, index) {
              final chatmessages = loadMessages[index].data();
              final nextChatMessages = index + 1 < chatmessages.length
                  ? loadMessages[index + 1].data()
                  : null;
              final currentMessageUserId = chatmessages['userID'];
              final nextMessagesUserId =
                  nextChatMessages != null ? nextChatMessages['userID'] : null;
              final nextUserIsSame = currentMessageUserId == nextMessagesUserId;

              if (nextUserIsSame) {
                return MessageBubble.next(
                    message: chatmessages['text'],
                    isMe: authenticatedUser!.uid == currentMessageUserId);
              } else {
                return MessageBubble.first(
                    userImage: chatmessages['userImage'],
                    username: chatmessages['userName'],
                    message: chatmessages['text'],
                    isMe: authenticatedUser!.uid == currentMessageUserId);
              }
            });
      },
    );
  }
}
