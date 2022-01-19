import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;
late User loggedInUser;

class ChatScreen extends StatefulWidget {
  static const id = 'chat_screen';
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final messageTextController = TextEditingController();
  late String messageText;
  late List messages;

  void getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: const Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (messageText != '') {
                        messageTextController.clear();
                        _firestore.collection('messages').add({
                          'text': messageText,
                          'sender': loggedInUser.email,
                        });
                      }
                      },
                    child: const Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class MessageStream extends StatelessWidget {
  const MessageStream({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages').snapshots(),
      builder: (context, snapshots) {
        if (!snapshots.hasData) {
          return const Center(
            child: Text(
              'Data not available',
            ),
          );
        }
        final messages = snapshots.data?.docs;
        List<MessageBubble> textWidgets = [];
        messages?.forEach((element) {
          final messageText = element['text'];
          final messageSender = element['sender'];

          if(messageText.toString() != '') {
            final textWidget = MessageBubble(
              text: messageText,
              sender: messageSender,
              isMe: loggedInUser.email == messageSender,
            );
            textWidgets.add(textWidget);
            textWidgets.reversed;
          }
        });
        return Expanded(
          child: ListView(
            reverse: true,
            children: textWidgets,
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({Key? key, required this.sender, required this.text, required this.isMe}) : super(key: key);

  final String sender;
  final String text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
              sender,
            style: const TextStyle(
              fontSize: 12.0,
              color: Colors.black54
            ),
          ),
          Material(
            borderRadius: BorderRadius.only(
              topLeft: isMe ? kRadius30 : kRadius0,
              topRight: isMe ? kRadius0 : kRadius30,
              bottomLeft: kRadius30,
              bottomRight: kRadius30,
            ),
            elevation: 5.0,
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20,),
              child: Text(
                text,
                style: TextStyle(
                  color: (isMe ? Colors.white : Colors.black),
                  fontSize: 15.0,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
