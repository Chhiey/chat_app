import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewChatMessages extends StatefulWidget {
  const NewChatMessages({super.key});

  @override
  State<StatefulWidget> createState() {
    return _newChatMessagesState();
  }
}

class _newChatMessagesState extends State<NewChatMessages> {
  var _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _submittedMessage() async {
    final enteredMessage = _messageController.text;

    if (enteredMessage.isEmpty) {
      return;
    }

    FocusScope.of(context).unfocus();
    _messageController.clear();

    final user = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    FirebaseFirestore.instance.collection('chat').add({
      'text': enteredMessage,
      'created_at': Timestamp.now(),
      'userID': user.uid,
      'userName': userData.data()!['username'],
      'userImage': userData.data()!['image_url']
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(
        children: [
          Expanded(
              child: TextFormField(
            controller: _messageController,
            textCapitalization: TextCapitalization.sentences,
            autocorrect: true,
            enableSuggestions: true,
            decoration: const InputDecoration(labelText: 'Message'),
          )),
          IconButton(
              color: Theme.of(context).colorScheme.primary,
              onPressed: _submittedMessage,
              icon: const Icon(Icons.send))
        ],
      ),
    );
  }
}
