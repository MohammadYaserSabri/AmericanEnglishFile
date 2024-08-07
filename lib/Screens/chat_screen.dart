import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_caht/DatabaseHelper.dart';
import 'package:flutter_application_caht/Screens/AppService.dart';
import 'package:flutter_application_caht/Screens/MessageBubble.dart';
import 'package:flutter_application_caht/Screens/UserModel.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_application_caht/Screens/UsersScreen.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class ChatScreen extends StatefulWidget {
  static const String id = "ChatScreen";
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String message = "";
  String name = "";
  String replyToUserName = '';
  String replyToUserId = '';
  String replyToThisMessage = '';
  bool isReplying = false;
  bool autofocusToMessageSend = false;
  TextEditingController sendTextContoller = TextEditingController();
  AppService appService = AppService();
  ChatPlace? chatPlace;
  final myUserModel = AppService().getMyUserModel();
  UserModel targetUserModel = AppService().getTargetUserModel();
  

  bool isUserExistInPrivateUsersList = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    chatPlace = AppService().getChatPlace();
    setStream();

    configue();
  }

  bool _isUpdating = false;
  Queue<List<Message>> _updateQueue = Queue<List<Message>>();
  bool _isProcessingQueue = false;

  void handleMessagesRead(List<Message> messages) {
    if (messages.isEmpty) return;
    _updateQueue.add(messages);

    if (!_isProcessingQueue) {
      _processQueue();
    }
  }
   String generateChatId(String userId1, String userId2) {
    List<String> userIds = [userId1, userId2];
    userIds.sort(); // Sort alphabetically
    return userIds.join('_'); // Join with an underscore or any separator
  }


  Future<void> markMessagesAsRead(List<Message> messages) async {
    if (_isUpdating) return;

    _isUpdating = true;
    try {
      for (var message in messages) {
        if (!message.read) {
          await FirebaseFirestore.instance
              .collection("ChatCollection")
              .doc(generateChatId(myUserModel.id, targetUserModel.id))
              .collection("Messages")
              .doc(message.uniqueId)
              .update({'read': true});
        }
      }
    } finally {
      _isUpdating = false;
    }
  }

  void _processQueue() async {
    if (_updateQueue.isEmpty) return;

    _isProcessingQueue = true;

    var messages = _updateQueue.removeFirst();
    await markMessagesAsRead(messages);

    _isProcessingQueue = false;

    // Process next in queue
    _processQueue();
  }

  Future<void> configue() async {
    if (chatPlace != ChatPlace.PR) return;

    print("in confique");

    isUserExistInPrivateUsersList = await DatabaseHelper()
        .isUserExistsInPrivateUsersChat(targetUserModel.id);

    print(isUserExistInPrivateUsersList);
  }

  Future<void> addUserToPrivateList() async {
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(targetUserModel.id)
        .update({
      "privateUsersId": FieldValue.arrayUnion([myUserModel.id])
    });
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(myUserModel.id)
        .update({
      "privateUsersId": FieldValue.arrayUnion([targetUserModel.id])
    });

    await DatabaseHelper()
        .addUserToPrivateUsersChat(myUserModel.id, targetUserModel.id);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? stream;

  setStream() {
    final chatPlace = appService.getChatPlace();

    // Map of ChatPlace to collection identifiers
    const roomMap = {
      ChatPlace.PR: 'ChatCollection',
      ChatPlace.Room1: 'Room1',
      ChatPlace.Room2: 'Room2',
      ChatPlace.Room3: 'Room3',
      ChatPlace.Room4: 'Room4',
    };

    if (chatPlace == ChatPlace.PR) {
      stream = FirebaseFirestore.instance
          .collection(roomMap[chatPlace]!)
          .doc(generateChatId(myUserModel.id, targetUserModel.id))
          .collection('Messages')
          .orderBy('date', descending: true)
          .limit(20)
          .snapshots();
    } else if (roomMap.containsKey(chatPlace)) {
      stream = FirebaseFirestore.instance
          .collection(roomMap[chatPlace]!)
          .orderBy('date', descending: true)
          .limit(30)
          .snapshots();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            '⚡️Chat',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.deepPurple.shade700,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade700, Colors.blue.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () {
                // Implement logout functionality
              },
            ),
          ],
        ),
        body: SafeArea(
            child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple.shade100, Colors.blue.shade200],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: stream == null
                      ? Container()
                      : StreamBuilder(
                          stream: stream,
                          builder: (context, snapshot) {
                            print('StreamBuilder triggered');
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              print('Waiting for data...');
                              return Center(child: CircularProgressIndicator());
                            }

                            if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            }

                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return Center(child: Text("No messages yet."));
                            }

                            List<QueryDocumentSnapshot<Map<String, dynamic>>>
                                documentSnapshots = snapshot.data!.docs;

                            List<Message> allMessages = documentSnapshots
                                .map((doc) => Message.from().toModel(doc))
                                .toList();

                            List<Message> messagetargetSend = allMessages.where(
                              (element) {
                                return element.senderId != myUserModel.id &&
                                    element.read == false;
                              },
                            ).toList();

                            handleMessagesRead(messagetargetSend);

                            List<MessageBubble> messageWidgets =
                                allMessages.map((message) {
                              bool isMe = message.senderId == myUserModel.id;
                              return MessageBubble(
                                replyToUserName:
                                    message.messageReplyedToUserName,
                                isRead: message.read,
                                replyToUserId: message.messageReplyedToUserID,
                                messageSenderName: message.senderName,
                                dateTime: message.date!,
                                messageSenderImage: message.senderImage,
                                textColor: isMe ? Colors.white : Colors.black,
                                bubbleColor: isMe
                                    ? Color.fromARGB(255, 7, 127, 226)
                                    : Color.fromARGB(255, 118, 228, 255),
                                messageText: message.content,
                                messageSenderID: message.senderId,
                                isMe: isMe,
                                onSwipeToReply:
                                    (Id, name, reply, message, autoFocus) {
                                  isReplying = reply;
                                  replyToUserId = Id;
                                  replyToUserName = name;
                                  replyToThisMessage = message;
                                  autofocusToMessageSend = autoFocus;

                                  setState(() {});
                                },
                              );
                            }).toList();

                            return ListView(
                              reverse: true,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              children: messageWidgets,
                            );
                          },
                        ),
                ),
                if (isReplying)
                  Container(
                    color: Colors.grey.shade300,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Replying to:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '$replyToUserName: $replyToThisMessage',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              isReplying = false;
                              replyToUserName = '';
                              replyToUserId = '';
                              replyToThisMessage = '';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            autofocus: autofocusToMessageSend,
                            controller: sendTextContoller,
                            onChanged: (value) {
                              message = value;
                            },
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.send, color: Colors.blue),
                          onPressed: () async {
                            Message? newMessage;
                            if (message.isNotEmpty) {
                              if (appService.getChatPlace() == ChatPlace.PR) {
                                newMessage = Message(
                                  senderName: myUserModel.name,
                                  messageReplyedToUserID: replyToUserId,
                                  messageReplyedToUserName: replyToUserName,
                                  senderId: myUserModel.id,
                                  receiverId: targetUserModel.id,
                                  content: message,
                                  senderImage: myUserModel.image,
                                  uniqueId: Uuid().v4(),
                                  date: DateTime.now(),
                                  read: false,
                                );
                              } else {
                                newMessage = Message(
                                  senderName: myUserModel.name,
                                  messageReplyedToUserID: replyToUserId,
                                  messageReplyedToUserName: replyToUserName,
                                  senderId: myUserModel.id,
                                  receiverId: "",
                                  senderImage: myUserModel.image,
                                  content: message,
                                  uniqueId: Uuid().v4(),
                                  date: DateTime.now(),
                                  read: true,
                                );
                              }

                              sendTextContoller.clear();
                              message = "";

                              if (chatPlace == ChatPlace.PR) {
                                await FirebaseFirestore.instance
                                    .collection("ChatCollection")
                                    .doc(generateChatId(
                                        myUserModel.id, targetUserModel.id))
                                    .collection("Messages")
                                    .doc(newMessage.uniqueId)
                                    .set(newMessage.toMap());
                              } else {
                                await FirebaseFirestore.instance
                                    .collection(chatPlace!.collectionName)
                                    .doc(newMessage.uniqueId)
                                    .set(newMessage.toMap());
                              }

                              if (isReplying) {
                                setState(() {
                                  isReplying = false;
                                  replyToUserName = '';
                                  replyToUserId = '';
                                  replyToThisMessage = '';
                                });
                              }

                              if (!isUserExistInPrivateUsersList) {
                                await FirebaseFirestore.instance
                                    .collection("Users")
                                    .doc(targetUserModel.id)
                                    .update({'numberOfNewMessages':1});
                                await addUserToPrivateList();
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
        )));
  }
}

