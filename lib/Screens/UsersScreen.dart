// ignore_for_file: must_be_immutable

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_caht/Presentation/DatabaseHelper.dart';
import 'package:flutter_application_caht/Presentation/Widgets/CustomAvatar/DynamicCircleAvatar/DynamicCircleAvatar.dart';
import 'package:flutter_application_caht/Screens/AppService.dart';
import 'package:flutter_application_caht/Presentation/Screens/HomeDashBoard.dart';
import 'package:flutter_application_caht/Screens/UserModel.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_application_caht/Screens/chat_screen.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  static const String id = "UserScreen";
  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  bool _isChatPage = false;
  bool _isBlacklistPage = false;
  int newMessagesCount = 0;
  late StreamSubscription<DocumentSnapshot> documentSubscription;

  @override
  void initState() {
    super.initState();
    listenToDocumentChanges();
  }

  void listenToDocumentChanges() async {
    documentSubscription = FirebaseFirestore.instance
        .collection('Users')
        .doc(AppService().user!.uid)
        .snapshots()
        .listen((snapshot) async {
      AppService().setMyUserModel(UserModel.from().toModel(snapshot));
      newMessagesCount = snapshot['numberOfNewMessages'];
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chat',
          style: TextStyle(color: Colors.deepPurple.shade50),
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
          badges.Badge(
            position: badges.BadgePosition.topEnd(top: 0, end: 3),
            showBadge: newMessagesCount > 0,
            badgeContent: const Text(
              "",
              style: TextStyle(color: Colors.white),
            ),
            child: IconButton(
              icon: Icon(
                Icons.chat_bubble_outline,
                color: Colors.deepPurple.shade50,
              ),
              onPressed: () async {
                if (newMessagesCount > 0) {
                  await FirebaseFirestore.instance
                      .collection("Users")
                      .doc(AppService().getMyUserModel().id)
                      .update({"numberOfNewMessages": 0});

                  newMessagesCount = 0;
                }
                setState(() {
                  _isChatPage = true;
                  _isBlacklistPage = false;
                });
              },
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.supervised_user_circle,
              color: Colors.deepPurple.shade50,
            ),
            onPressed: () {
              setState(() {
                _isChatPage = false;
                _isBlacklistPage = false;
              });
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: Colors.deepPurple.shade50,
            ),
            onSelected: (String value) {
              if (value == 'Blacklist') {
                setState(() {
                  _isBlacklistPage = true;
                  _isChatPage = false;
                });
              } else if (value == 'Chat') {
                setState(() {
                  _isChatPage = true;
                  _isBlacklistPage = false;
                });
              }
            },
            itemBuilder: (BuildContext context) {
              return {'Blacklist', 'Chat'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: _getPage(),
      backgroundColor: Colors.blue.shade50,
    );
  }

  Widget _getPage() {
    if (_isBlacklistPage) {
      return const BlackListPage();
    } else if (_isChatPage) {
      return ChatPage();
    } else {
      return const ChatMainPage();
    }
  }
}

class ChatPage extends StatefulWidget {
  ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<UserModel> privateUsersModel = [];
  List<OnlineModel> onlinePrivateUsersModel = [];
  bool isLoading = true;
  bool hasError = false;
  bool first = true;
  int privateUsers = 0;
  bool invokeSetPrivateUsersModel = false;
  List<String> usersID = [];
  List<StreamSubscription<QuerySnapshot>> subscriptions = [];
  UserModel myUserModel = AppService().getMyUserModel();
  Map<String, int> newMessagesCount = {};
  String generateChatId(String userId1, String userId2) {
    List<String> userIds = [userId1, userId2];
    userIds.sort(); // Sort alphabetically
    return userIds.join('_'); // Join with an underscore or any separator
  }

  @override
  void initState() {
    super.initState();
    setPrivateUsersModel();
    if (first) {
      updateListeners();
      first = false;
    }
    fetchAndListenToNewMessages();
  }

  @override
  void dispose() {
    cancelAllSubscriptions();
    super.dispose();
  }

  void fetchAndListenToNewMessages() async {
    // Fetch new user IDs (this is just an example, replace with actual logic)
    List<String> newUsersID = fetchPrivateUserIds();

    if (newUsersID.isEmpty) {
      return;
    }

    // If the user list has changed, update the listeners
    if (!_areListsEqual(usersID, newUsersID)) {
      setState(() {
        usersID = newUsersID;
      });

      print(newUsersID.length);
      updateListeners();
    }
  }

  List<String> fetchPrivateUserIds() {
    // Replace with your logic to get the list of user IDs
    return AppService().getPrivateUsersID();
  }

  void updateListeners() {
    cancelAllSubscriptions();

    if (usersID.isEmpty) {
      return;
    }

    for (String userId in usersID) {
      var subscription = FirebaseFirestore.instance
          .collection("ChatCollection")
          .doc(generateChatId(myUserModel.id, userId))
          .collection('Messages')
          .limit(8)
          .orderBy("date", descending: true)
          .snapshots()
          .listen((QuerySnapshot snapshot) {
        setState(() {
          countNewMessages(userId, snapshot);
        });
      });
      subscriptions.add(subscription);
    }
  }

  void countNewMessages(String userId, QuerySnapshot doc) {
    List<Message> messages =
        doc.docs.map((e) => Message.from().toModel(e)).toList();
    print("all message ");
    print(messages.length);
    List<Message> unreadMessage = messages.where(
      (element) {
        return element.read == false && element.senderId != myUserModel.id;
      },
    ).toList();

    for (var m in messages) {
      print("message is : ${m.content} and is read : ${m.read}");
    }
    print("inread messages");
    print(unreadMessage.length);

    newMessagesCount[userId] = unreadMessage.length;
  }

  void cancelAllSubscriptions() {
    for (var subscription in subscriptions) {
      subscription.cancel();
    }
    subscriptions.clear();
  }

  // Helper method to compare two lists
  bool _areListsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) {
      print("false");
      return false;
    }
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) {
        print("false");
        return false;
      }
    }
    print('ture');
    return true;
  }

  void setPrivateUsersModel() async {
    var i = AppService().countPrivateUsers();

    privateUsers = i;
    if (i <= 0) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    try {
      usersID.clear();
      usersID = AppService().getPrivateUsersID();

      for (var users in usersID) {
        DocumentSnapshot privateDoc = await FirebaseFirestore.instance
            .collection("Users")
            .doc(users)
            .get();

        DatabaseReference onlineDoc = await FirebaseDatabase.instance
            .ref()
            .child("OnlineUsers")
            .child(users);

        DataSnapshot data = await onlineDoc.get();

        UserModel userModel = UserModel.from().toModel(privateDoc);
        OnlineModel onlineModel = OnlineModel.from().toModel(data);

        privateUsersModel.add(userModel);
        onlinePrivateUsersModel.add(onlineModel);
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print("invokde :$invokeSetPrivateUsersModel");
    if (invokeSetPrivateUsersModel) {
      if (privateUsers != AppService().countPrivateUsers()) {
        setPrivateUsersModel();
      }

      invokeSetPrivateUsersModel = false;
    }
    invokeSetPrivateUsersModel = true;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : hasError
                ? const Center(
                    child: Text("Failed to load data."),
                  )
                : privateUsersModel.isEmpty || onlinePrivateUsersModel.isEmpty
                    ? const Center(
                        child: Text("No friends available to chat."),
                      )
                    : ListView.builder(
                        itemCount: privateUsersModel.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: ChatBubble(
                              unreadMessage: newMessagesCount[usersID[index]],
                              privateModel: privateUsersModel[index],
                              onlineModel: onlinePrivateUsersModel[index],
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}

class ChatBubble extends StatefulWidget {
  ChatBubble({
    Key? key,
    required this.privateModel,
    required this.unreadMessage,
    required this.onlineModel,
  }) : super(key: key);

  final UserModel privateModel;
  final OnlineModel onlineModel;
  int? unreadMessage = 0;
  bool isDeleting = false;
  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  Color buttonColor = Colors.white;

  String generateChatId(String userId1, String userId2) {
    List<String> userIds = [userId1, userId2];
    userIds.sort(); // Sort alphabetically
    return userIds.join('_'); // Join with an underscore or any separator
  }

  @override
  Widget build(BuildContext context) {
    return badges.Badge(
      position: badges.BadgePosition.topEnd(top: 0, end: 3),
      showBadge:
          widget.unreadMessage != null ? (widget.unreadMessage! > 0) : false,
      badgeContent: Text(
        widget.unreadMessage.toString(),
        style: const TextStyle(color: Colors.white),
      ),
      child: GestureDetector(
        onTap: () async {
          // await markMessagesAsReadIFNew();
          AppService().setTargetUserModel(widget.privateModel);
          AppService().setChatPlace(ChatPlace.PR);
          Navigator.pushNamed(context, ChatScreen.id);
        },
        onTapDown: (details) {
          setState(() {
            buttonColor = Colors.grey.shade400;
          });
        },
        onTapUp: (details) {
          setState(() {
            buttonColor = Colors.white;
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 1.0),
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple.shade300, Colors.deepPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: ClipOval(
                  child: Image.network(
                    widget.privateModel.image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.privateModel.name,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (widget.isDeleting)
                          Center(
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.blue,
                              color: Colors.blue.shade50,
                            ),
                          ),
                        Text(
                          widget.onlineModel.state == true
                              ? "Online"
                              : "Offline",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          widget.onlineModel.state == true
                              ? Icons.online_prediction_rounded
                              : Icons.offline_pin_rounded,
                          color: widget.onlineModel.state == true
                              ? Colors.green
                              : Colors.red,
                          size: 16,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (String value) async {
                  if (value == 'Delete') {
                    String idloc = generateChatId(
                        AppService().getMyUserModel().id,
                        widget.privateModel.id);

                    print(idloc);
                    // Reference to the parent document in 'ChatCollection'
                    DocumentReference chatDocRef = FirebaseFirestore.instance
                        .collection('ChatCollection')
                        .doc("EWtrmoaKqPQhgnli2VZmuIbdnRZ2_TOre5tqUsnNphZyFCNgVIk2zcG03");

                    await chatDocRef.delete();

                    print(
                        'Chat document and sub-collections deleted successfully.');

                    print("delted");
                  /*   List<String> MyprivateUsers = [];

                    MyprivateUsers =
                        AppService().getMyUserModel().privateUsersId;

                    MyprivateUsers.removeWhere(
                        (element) => element == widget.privateModel.id);

                    await FirebaseFirestore.instance
                        .collection("Users")
                        .doc(AppService().getMyUserModel().id)
                        .update({'privateUsersId': MyprivateUsers});

                    DocumentSnapshot targetDoc = await FirebaseFirestore
                        .instance
                        .collection("Users")
                        .doc(widget.privateModel.id)
                        .get();

                    List<String> targetUsers =
                        UserModel.from().toModel(targetDoc).privateUsersId;

                    targetUsers.removeWhere((element) =>
                        element == AppService().getMyUserModel().id);

                    await FirebaseFirestore.instance
                        .collection("Users")
                        .doc(widget.privateModel.id)
                        .update({'privateUsersId': targetUsers});

                    setState(() {
                      widget.isDeleting = false;
                    }); */
                  } else if (value == 'Blacklist') {
                    await DatabaseHelper().addUserToBlackList(
                        BlackListUserModel(
                            name: widget.privateModel.name,
                            userId: widget.privateModel.id,
                            image: widget.privateModel.image),
                        AppService().getMyUserModel().id);
                  }
                },
                itemBuilder: (BuildContext context) {
                  return {'Delete', 'Blacklist'}.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child:
                          Text(choice, style: const TextStyle(color: Colors.black)),
                    );
                  }).toList();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Replace with actual import
class RoomCard extends StatelessWidget {
  final String roomName;
  final IconData roomIcon;
  final VoidCallback onTap;

  RoomCard({
    Key? key,
    required this.roomName,
    required this.roomIcon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 1.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade700, Colors.blue.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: Colors.deepPurple.shade400, width: 2.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              roomIcon,
              color: Colors.white,
              size: 24.0,
            ),
            const SizedBox(width: 10.0),
            Text(
              roomName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 2.0,
                    color: Colors.black45,
                    offset: Offset(1.0, 1.0),
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

class ChatMainPage extends StatefulWidget {
  const ChatMainPage({super.key});

  @override
  State<ChatMainPage> createState() => _ChatMainPageState();
}

class _ChatMainPageState extends State<ChatMainPage> {
  final AppService appService = AppService();
  List<UserBubble> userBubbles = [];
  bool isLoading = false;
  late DatabaseReference _onlineUsersRef;

  @override
  void initState() {
    super.initState();
    _onlineUsersRef = FirebaseDatabase.instance.ref().child("OnlineUsers");
    _listenToOnlineUsers();
  }

  void _listenToOnlineUsers() {
    // Listen for new online users
    _onlineUsersRef.onChildAdded.listen((event) async {
      print("child added");
      var onlineData = event.snapshot.value as Map<dynamic, dynamic>;
      print("online is: ${onlineData['state']}");
      if (onlineData['state'] == true &&
          event.snapshot.key != appService.user!.uid) {
        setState(() {
          isLoading = true;
        });

        var userDoc = await FirebaseFirestore.instance
            .collection("Users")
            .doc(event.snapshot.key)
            .get();
        print(event.snapshot.key);

        if (userDoc.exists) {
          print("yes it is");
          userBubbles.add(
            UserBubble(
              onlineModel: OnlineModel.from().toModel(event.snapshot),
              userModel: UserModel.from().toModel(userDoc),
            ),
          );
          print("User bubbles length: ${userBubbles.length}");
          setState(() {
            isLoading = false;
          });
        }
      }
    });

    // Listen for updates to online users
    _onlineUsersRef.onChildChanged.listen((event) async {
      print("child changed");
      var onlineData = event.snapshot.value as Map<dynamic, dynamic>;
      if (event.snapshot.key != appService.user!.uid) {
        setState(() {
          isLoading = true;
        });
        var userDoc = await FirebaseFirestore.instance
            .collection("Users")
            .doc(event.snapshot.key)
            .get();

        if (userDoc.exists) {
          setState(() {
            int index = userBubbles.indexWhere(
                (bubble) => bubble.userModel.id == event.snapshot.key);
            if (index != -1 && onlineData['state'] == true) {
              userBubbles[index] = UserBubble(
                onlineModel: OnlineModel.from().toModel(event.snapshot),
                userModel: UserModel.from().toModel(userDoc),
              );
              print("Updated user: ${userDoc['name']}");
            } else if (index != -1 && onlineData['state'] == false) {
              userBubbles.removeAt(index);
              print("Removed user: ${userDoc['name']}");
            }
            isLoading = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("build is called");
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade900, Colors.blue.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Available Rooms',
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              RoomCard(
                roomName: "Room 1",
                roomIcon: Icons.chat_bubble_outline_outlined,
                onTap: () {
                  AppService().setChatPlace(ChatPlace.Room1);
                  Navigator.pushNamed(context, ChatScreen.id);
                },
              ),
              RoomCard(
                roomName: "Room 2",
                roomIcon: Icons.chat_bubble_outline_outlined,
                onTap: () {
                  AppService().setChatPlace(ChatPlace.Room2);
                  Navigator.pushNamed(context, ChatScreen.id);
                },
              ),
              RoomCard(
                roomName: "Room 3",
                roomIcon: Icons.chat_bubble_outline_outlined,
                onTap: () {
                  AppService().setChatPlace(ChatPlace.Room3);
                  Navigator.pushNamed(context, ChatScreen.id);
                },
              ),
              RoomCard(
                roomName: "Room 4",
                roomIcon: Icons.chat_bubble_outline_outlined,
                onTap: () {
                  AppService().setChatPlace(ChatPlace.Room4);
                  Navigator.pushNamed(context, ChatScreen.id);
                },
              ),
              const SizedBox(height: 16.0),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Online Users',
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Stack(
                    children: [
                      // The ListView displays the current list of user bubbles
                      ListView.builder(
                        itemCount: userBubbles.length,
                        itemBuilder: (context, index) {
                          print("Building item: $index");
                          return userBubbles[index];
                        },
                      ),
                      if (isLoading)
                        Center(
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      if (userBubbles.length <= 0)
                        const Center(
                          child: Text("no user is online right now"),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserBubble extends StatefulWidget {
  final UserModel userModel;
  final OnlineModel onlineModel;

  UserBubble({
    Key? key,
    required this.userModel,
    required this.onlineModel,
  }) : super(key: key);

  @override
  State<UserBubble> createState() => _UserBubbleState();
}

class _UserBubbleState extends State<UserBubble> {
  bool isTapped = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 1.0),
      child: Material(
        elevation: isTapped ? 8.0 : 4.0,
        borderRadius: BorderRadius.circular(16.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: () {
            AppService().setTargetUserModel(widget.userModel);
            AppService().setChatPlace(ChatPlace.PR);
            Navigator.pushNamed(context, ChatScreen.id);
            setState(() {
              isTapped = true;
            });
            Future.delayed(const Duration(milliseconds: 150), () {
              setState(() {
                isTapped = false;
              });
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isTapped
                    ? [Colors.deepPurple.shade500, Colors.blue.shade700]
                    : [Colors.deepPurple.shade700, Colors.blue.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(widget.userModel.image),
                  radius: 24.0,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.userModel.name,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 2.0,
                              color: Colors.black45,
                              offset: Offset(1.0, 1.0),
                            ),
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4.0),
                      Row(
                        children: [
                          Icon(
                            widget.onlineModel.state
                                ? Icons.circle
                                : Icons.circle_outlined,
                            color: widget.onlineModel.state
                                ? Colors.green
                                : Colors.red,
                            size: 12.0,
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            widget.onlineModel.state ? 'Online' : 'Offline',
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white54,
                  size: 16.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BlackListPage extends StatefulWidget {
  const BlackListPage({super.key});

  @override
  State<BlackListPage> createState() => _BlackListPageState();
}

class _BlackListPageState extends State<BlackListPage> {
  List<BlackListUserModel> blackListUsers = [];
  @override
  void initState() {
    super.initState();

    loadBlackListUsers();
  }

  void loadBlackListUsers() async {
    blackListUsers = await DatabaseHelper().loadBlackListUsers();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: blackListUsers.length <= 0
            ? const Center(
                child: Text("Black List is empty"),
              )
            : ListView(
                children: List.generate(
                blackListUsers.length,
                (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        DynamicCircleAvatar(
                            imagePath: blackListUsers[index].image),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Text(
                            blackListUsers[index].name,
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (String value) {
                            if (value == 'Remove from Blacklist') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Removed Blacklisted User ${index + 1}')),
                              );
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return {'Remove from Blacklist'}
                                .map((String choice) {
                              return PopupMenuItem<String>(
                                value: choice,
                                child: Text(choice),
                              );
                            }).toList();
                          },
                        ),
                      ],
                    ),
                  );
                },
              )));
  }
}
