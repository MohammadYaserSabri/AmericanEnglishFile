import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';

class UserModel {
  late String id = "";
  late String name;
  late String password;
  late String email;
  late bool isBlocked;
  late String image =
      "https://firebasestorage.googleapis.com/v0/b/fir-74e71.appspot.com/o/8380015.jpg?alt=media&token=df1bdaa1-f7c5-4783-8c36-ab7e370f59fa";
  late int numberOfNewMessages;
  late List<BlackListUserModel> blackList = [];
  late List<String> privateUsersId = [];

  UserModel({
    required this.id,
    required this.name,
    required this.password,
    required this.email,
    required this.isBlocked,
    required this.image,
    required this.numberOfNewMessages,
    required this.blackList,
    required this.privateUsersId,
  });

  Map<String, dynamic> toMap() {
    List<Map<String, dynamic>> blackList = [];

    for (var o in this.blackList) {
      blackList.add(o.toMap());
    }

    return {
      'id': id,
      'name': name,
      'password': password,
      'email': email,
      'isBlocked': isBlocked,
      'image': image,
      'numberOfNewMessages': numberOfNewMessages,
      'blackList': blackList,
      'privateUsersId': privateUsersId,
    };
  }

  UserModel.from();
  UserModel toModel(DocumentSnapshot doc) {
    return UserModel(
      id: doc['id'],
      name: doc['name'],
      password: doc['password'],
      email: doc['email'],
      isBlocked: doc['isBlocked'],
      image: doc['image'],
      numberOfNewMessages: doc['numberOfNewMessages'],
      blackList: (doc['blackList'] as List<dynamic>)
          .map((e) => BlackListUserModel.from().toModel(e))
          .toList(),
      privateUsersId: (doc['privateUsersId'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }
}

class OnlineModel {
  late String id;
  late bool state;
  late DateTime lastOnlineTime;

  OnlineModel.from();

  OnlineModel(
      {required this.id, required this.state, required this.lastOnlineTime});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'state': state,
      'lastOnlineTime': ServerValue.timestamp,
    };
  }

  OnlineModel toModel(DataSnapshot snapshot) {
    Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
    int timestampMillis = data['lastOnlineTime'] ?? 0;
    DateTime date =
        DateTime.fromMillisecondsSinceEpoch(timestampMillis).toLocal();
    return OnlineModel(
        id: data['id'], state: data['state'], lastOnlineTime: date);
  }
}

class Message {
  late String content = 'hee';
  late String senderId = 'eee';
  late String receiverId = 'ee';
  late String senderName = "";
  late DateTime? date = DateTime.now();
  late String uniqueId = const Uuid().v4();
  late bool read = false;
  late String senderImage = '';
  late String messageReplyedToUserID = '';
  late String messageReplyedToUserName = '';
  Message.from();

  Message(
      {required this.senderId,
      required this.receiverId,
      required this.content,
      required this.date,
      required this.senderName,
      required this.messageReplyedToUserName,
      required this.read,
      required this.uniqueId,
      required this.senderImage,
      required this.messageReplyedToUserID});

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'date': FieldValue.serverTimestamp(),
      'read': read,
      'senderName': senderName,
      'uniqueId': uniqueId,
      'senderImage': senderImage,
      'messageReplyedToUserID': messageReplyedToUserID,
      'messageReplyedToUserName': messageReplyedToUserName
    };
  }

  Message toModel(DocumentSnapshot doc) {
    print(" message is read ${doc['read']}");
    return Message(
        content: doc['content'],
        date: doc['date'] != null
            ? (doc['date'] as Timestamp).toDate().toLocal()
            : Timestamp.now().toDate().toLocal(),
        read: doc['read'],
        senderId: doc['senderId'],
        senderName: doc['senderName'],
        uniqueId: doc['uniqueId'],
        senderImage: doc['senderImage'],
        messageReplyedToUserName: doc['messageReplyedToUserName'],
        messageReplyedToUserID: doc['messageReplyedToUserID'],
        receiverId: doc['receiverId']);
  }
}

class BlackListUserModel {
  String name = '';
  String userId = '';
  String image = '';

  BlackListUserModel.from();

  BlackListUserModel(
      {required this.name, required this.userId, required this.image});

  Map<String, dynamic> toMap() {
    return {'name': name, 'userId': userId, 'image': image};
  }

  BlackListUserModel toModel(Map<String, dynamic> doc) {
    return BlackListUserModel(
      name: doc['name'],
      userId: doc['userId'],
      image: doc['image'],
    );
  }
}
