// ignore_for_file: unnecessary_null_comparison

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_caht/Presentation/DatabaseHelper.dart';
import 'package:flutter_application_caht/Screens/Settings.dart' as app;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_application_caht/Screens/Login.dart';
import 'package:flutter_application_caht/Screens/UserModel.dart';
import 'package:gallery_picker/gallery_picker.dart';

// these abbreviation are : private room , first room, second ................. AmericanEnglishFile1Room and so on
enum ChatPlace { PR, Room1, Room2, Room3, Room4 }

extension ChatPlaceExtension on ChatPlace {
  String get collectionName {
    return this.toString().split('.').last;
  }
}

class AppService {
  static final AppService _instance = AppService._internal();

  AppService._internal();

  factory AppService() {
    return _instance;
  }

  ChatPlace _chatPlace = ChatPlace.PR;

  ChatPlace getChatPlace() {
    return _chatPlace;
  }

  void setChatPlace(ChatPlace place) {
    _chatPlace = place;
  }

  late UserModel _targetUser = UserModel.from();
  late UserModel _myUserModel;

  UserModel getMyUserModel() {
    return _myUserModel;
  }

  List<String> getPrivateUsersID() {
    List<String> temp = [];

    for (var id in _myUserModel.privateUsersId) {
      if (id != null && id.isNotEmpty) {
        temp.add(id);
      }
    }
    return temp;
  }

  int countPrivateUsers() {
    List<String> privateUsers = _myUserModel.privateUsersId;

    int count = 0;
    if (privateUsers.length <= 0) {
      return 0;
    }

    for (var user in privateUsers) {
      print("user is $user");
      if (user != null && user.isNotEmpty) {
        count++;
      }
    }
    print("private users are $count");
    return count;
  }

  void setMyUserModel(UserModel myUserModel) {
    _myUserModel = myUserModel;
  }

  UserModel getTargetUserModel() {
    return _targetUser;
  }

  void setTargetUserModel(UserModel targetUserModel) {
    _targetUser = targetUserModel;
  }

  User? user;

  String myPhoto = "images/file1.jpg";

  late FirebaseFirestore _firebaseFirestore;

  late FirebaseAuth _auth;

  int _allNumberOfOnlineUsers = 0;

  int getAllNumberOfOnlineUsers() {
    return _allNumberOfOnlineUsers;
  }

  List<UserModel> onlineUsers = [];

 

  void setOnline() async {
    if (user == null) {
      print("can not set user online while user does not exists");
      return;
    }
    DocumentReference dRef =
        _firebaseFirestore.collection("OnlineUsers").doc(user!.uid);

    try {
      await dRef.update({'state': true, 'date': FieldValue.serverTimestamp()});
    } on FirebaseException catch (e) {
      print(" error while set online ${e.code}");
    }
  }

  void setOffline() async {
    if (user == null) {
      print("can not set user offline while user does not exists");
      return;
    }
    DocumentReference dRef =
        _firebaseFirestore.collection("OnlineUsers").doc(user!.uid);

    try {
      await dRef.update({'state': false, 'date': FieldValue.serverTimestamp()});
    } on FirebaseException catch (e) {
      print(" error while set offline ${e.code}");
    }
  }

  Future<bool> cheakUserSignIn(BuildContext context) async {
    if (user == null) {
      _showAlertDialog(
          "Not sign in yet",
          " You must Log  in before continue",
          [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("no, Thanks")),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, Login.id);
                },
                child: Text(" sign in "))
          ],
          context);
      return false;
    } else {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("Users")
          .doc(user!.uid)
          .get();

      try {
        await _auth.signInWithEmailAndPassword(
            email: doc['email'], password: doc['password']);

        FirebaseDatabase _database = FirebaseDatabase.instance;

        DatabaseReference userRef =
            _database.ref().child("OnlineUsers").child(user!.uid);

        AppService().user = _auth.currentUser;
        AppService().setMyUserModel(UserModel.from().toModel(doc));

        await userRef
            .set({ 'state': true, 'lastOnlineTime': ServerValue.timestamp , 'id':user!.uid});

        userRef
            .onDisconnect()
            .set({'state': false, 'lastOnlineTime': ServerValue.timestamp, 'id': user!.uid});

        

        return true;
      } on FirebaseAuthException catch (e) {
        _showAlertDialog(
            e.code,
            "problem : ${e.code}",
            [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("ok"))
            ],
            context);
        return false;
      }
    }
  }

  Future<void> saveImage(BuildContext context) async {
    bool isSign = await cheakUserSignIn(context);

    if (!isSign) {
      return;
    }

    List<MediaFile>? Singlemedia =
        await GalleryPicker.pickMedia(context: context, singleMedia: true);

    File? file = await Singlemedia?.first.getFile();

    if (file == null) {
      return;
    }

    bool success = await isImageSavedToStorage(file!);
    if (success) {
      print("success");

      Map<String, dynamic> map =
          await DatabaseHelper().retriveProfileLocallyFromDatabase();
      String name = map['name'];
      String image = map['image'];

      if (image.isNotEmpty) {
        File file = File(image);
        await file.delete();
      }

      String imagePath = await DatabaseHelper().saveImageLocally(file);

      DatabaseHelper().updateProfileLocallyFromDatabase(name, name, imagePath);
    }
  }

  Future<bool> isImageSavedToStorage(File file) async {
    try {
      final userId = _auth.currentUser?.uid;
      final fileName = file.path.split("/").last;
      final storageRef = FirebaseStorage.instance.ref();

      final uploadRef = storageRef.child(
          "$userId/uploads/${DateTime.now().microsecondsSinceEpoch}==${fileName}");

      TaskSnapshot snapshot = await uploadRef.putFile(file);

      // Wait for the upload to complete

      // Get the download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();

      print('Image uploaded successfully: $downloadUrl');

      _firebaseFirestore
          .collection("Users")
          .doc(user!.uid)
          .update({'image': downloadUrl});

      return true;
    } on FirebaseException catch (e) {
      print(e.code);
      return false;
    }
  }

  void _showAlertDialog(String title, String content, List<Widget> actions,
      BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: actions,
        );
      },
    );
  }

  void start() {
    _firebaseFirestore = FirebaseFirestore.instance;
    _auth = FirebaseAuth.instance;

    user = _auth.currentUser;
  }

  Future<void> sendPasswordReset(String _email, BuildContext context) async {
    try {
      await _auth.sendPasswordResetEmail(email: _email!);

      _showAlertDialog(
          "Message sent",
          " cheak your email box to reset your password",
          [Text("Ok")],
          context);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "invalid-email":
          _showAlertDialog(
              "invalid email",
              " the email that you have provided at rejestratin was fake so your can not access to that account for more information send a message to admin",
              [Text('Ok')],
              context);
          break;

        default:
          _showAlertDialog(
              "Error occured",
              " an error occured please try again later",
              [Text("ok")],
              context);
          break;
      }
    }
  }
}











// these codes will load online users for main page.

// List<String> onlineUsersPhotoForMainPage = [];
  /* Future<void> loadOnlineUsersForMainPage() async {
    CollectionReference _cRef = _firebaseFirestore.collection("Users");

    await _cRef
        .limit(app.Settings.onlineUsersAtMainPage)
        .where("state", isEqualTo: true)
        .get()
        .then(
      (snapShot) {
        var data = snapShot.docs;

        for (var a in data) {
          String imagePath = a['image'];

          if (imagePath == null || imagePath.isEmpty) {
            imagePath = 'images/file1.jpg';
          }
          // be aware for a user do not have image
          onlineUsersPhotoForMainPage.add(imagePath);

          _onlineUsersForMainPage++;
        }
      },
    );
    if (user == null) {
      return;
    }
    await _cRef.doc(user!.uid).get().then(
      (value) {
        myPhoto = value['image'];
      },
    );
  } */