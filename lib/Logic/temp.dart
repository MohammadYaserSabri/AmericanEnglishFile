/* import 'package:flutter/material.dart';

void _editUserName(BuildContext context) async {
    bool isSignIn = await AppService().cheakUserSignIn(context);

    if (!isSignIn) {
      return;
    }

    TextEditingController _nameController =
        TextEditingController(text: userName);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit User Name"),
          content: TextField(
            controller: _nameController,
            decoration: const InputDecoration(hintText: "Enter your name"),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Map<String, dynamic> map =
                    await DatabaseHelper().retriveProfileLocallyFromDatabase();

                String imagePath = map['image'];
                String currentName = map['name'];
                await DatabaseHelper().updateProfileLocallyFromDatabase(
                    currentName, _nameController.text, imagePath);

                FirebaseFirestore.instance
                    .collection("Users")
                    .doc(_auth.currentUser!.uid)
                    .update({'name': _nameController.text});
                setState(() {
                  userName = _nameController.text;
                });
                Navigator.of(context).pop();
              },
              child: const Text("Save"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editUserImage(BuildContext context) async {
    await AppService().saveImage(context);
    isLoadingCamera = false;
    await loadProfile();
  }

    Future<void> loadProfile() async {
    Map<String, dynamic> map =
        await DatabaseHelper().retriveProfileLocallyFromDatabase();

    if (map.isEmpty) {
      return;
    }

    String image = map['image'];
    String name = map['name'];
    

    if (image.isNotEmpty) {
      profileImage = image;
    }

    userName = name;

    setState(() {});
  }

  String imageStoragePath = '';

  List<String> imagePath = [
    'file1.jpg',
    'file2.jpg',
    'file3.jpg',
    'file4.jpg',
    'file5.png'
  ];

  List<String> courseName = [
    'AmericanEnglishFile1',
    'AmericanEnglishFile2',
    'AmericanEnglishFile3',
    'AmericanEnglishFile4',
    'AmericanEnglishFile5'
  ];
  bool loadingChatScreen = false;
  bool isLoadingCamera = false;
  bool isLoggedIn = false;
  String userName = "User Name";
 */










//  choose method section  

/* void HandleWords() async {
    Navigator.pushNamed(context, UnitsPage.id);
    CourseManager().action = unit.Action.Words;
  }

  void HandleMyWords() {
    CourseManager().setCurrentUnit("MyWords");
    CourseManager().setAllVocabularyOfSelectedUnit("MyWords");
    Navigator.pushNamed(context, LevelPrevieww.id);
  }

  void HandleVocabularyBank() {
    CourseManager().action = unit.Action.VocabularyBank;
    Navigator.pushNamed(context, UnitsPage.id);
  }
  void setCourseProgress() async {
    await CourseManager().setCourseProgress();

    setState(() {});
  }

  void HandleTest() {
    Navigator.pushNamed(context, UnitsPage.id);
    CourseManager().action = unit.Action.Test;
  } */


  // end chooose