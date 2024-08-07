import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_caht/CourseManager.dart';
import 'package:flutter_application_caht/DatabaseHelper.dart';
import 'package:flutter_application_caht/Screens/Choose.dart';
import 'package:flutter_application_caht/Screens/UsersScreen.dart';
import 'package:flutter_application_caht/Screens/AppService.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

final dbHelper = DatabaseHelper();

class Course extends StatefulWidget {
  static const String id = "Course";
  const Course({super.key});

  @override
  State<Course> createState() => _CourseState();
}

class _CourseState extends State<Course> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String profileImage = 'images/file1.jpg';
  User? user;
  late AppService appService;
  @override
  void initState() {
    super.initState();
    appService = AppService();
    loadProfile();
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
  int _selectedIndex = 0;
  // Default image path

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

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

  void _onItemTapped(int index) async {
    if (index == 0) {
      Navigator.pushNamed(context, Course.id);
    } else if (index == 1) {
      var bookName = "AmericanEnglishFile1";

      bool isCurrentBookExists = await dbHelper.isCurrentBookExists(bookName);

      if (!isCurrentBookExists) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Course Not Supported'),
              content: const Text('This course is currently not supported.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        var wordLoader = CourseManager();

        wordLoader.setUnitsNamesOfTheBook(bookName);

        // wordLoader.printUnitsName();

        wordLoader.setCurrentBook(bookName);

        await wordLoader.setAllVocabularyOfTheCurrentBook(bookName);

        await CourseManager().setCourseProgress();
        // wordLoader.printVocabulary();
        // await CourseManager().loadUnitsProgress();
        Navigator.pushReplacementNamed(
          context,
          Choose.id,
        );
      }
    }
    setState(() {
      _selectedIndex = index;
    });
  }

 
  @override
  Widget build(BuildContext context) {
 

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: Column(
                children: [
                  if (isLoadingCamera)
                    Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.blue,
                        color: Colors.blue.shade100,
                      ),
                    ),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: DynamicCircleAvatar(imagePath: profileImage),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () async {
                            setState(() {
                              isLoadingCamera = true;
                            });

                            await _editUserImage(context);
                          },
                          child: const CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      _editUserName(context);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.deepPurple),
              title:
                  const Text('Settings', style: TextStyle(color: Colors.deepPurple)),
              onTap: () {
                // Add logic for settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.report, color: Colors.deepPurple),
              title: const Text('Report', style: TextStyle(color: Colors.deepPurple)),
              onTap: () {
                // Add logic for report
              },
            ),
            ListTile(
              leading: const Icon(Icons.more, color: Colors.deepPurple),
              title: const Text('More', style: TextStyle(color: Colors.deepPurple)),
              onTap: () {
                // Add logic for more
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.deepPurple),
              title: const Text('LogOut', style: TextStyle(color: Colors.deepPurple)),
              onTap: () async {
                await _auth.signOut();
                appService.user = _auth.currentUser;
                // Add logic for logout
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Courses", style: TextStyle(color: Colors.deepPurple.shade50),),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble, color: Colors.white),
            onPressed: () {
              // Add logic for chat
            },
          ),
          IconButton(
            icon: const Icon(Icons.language, color: Colors.white),
            onPressed: () {
              // Add logic for language
            },
          ),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        color: Colors.deepPurple,
        backgroundColor: Colors.deepPurple.shade50,
        items: [
          Icon(
            Icons.home,
            size: 28,
            color: Colors.deepPurple.shade50,
          ),
          Icon(Icons.book, size: 28, color: Colors.deepPurple.shade50),
          Icon(Icons.change_circle, size: 28, color: Colors.deepPurple.shade50),
        ],
        index: _selectedIndex,
        onTap: _onItemTapped,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back,',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Mr Yaser',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Chat with English Learner",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Login to chat",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  Material(
                    elevation: 5.0,
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30.0),
                    child: MaterialButton(
                      onPressed: () async {
                        setState(() {
                          loadingChatScreen = true;
                        });
                        bool isSignIn =
                            await AppService().cheakUserSignIn(context);

                        if (isSignIn) {
                          loadingChatScreen = false;
                          Navigator.pushNamed(context, UsersScreen.id);
                        }
                      },
                      hoverColor: Colors.deepPurpleAccent,
                      minWidth: 200.0,
                      height: 42.0,
                      child: const Text(
                        'Log In',
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (loadingChatScreen)
                    Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.blue,
                        color: Colors.blue.shade100,
                      ),
                    )
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        buildCourseCard('Course 1', 'images/file1.jpg'),
                        buildCourseCard('Course 2', 'images/file2.jpg'),
                        buildCourseCard('Course 3', 'images/file3.jpg'),
                        buildCourseCard('Course 4', 'images/file4.jpg'),
                        buildCourseCard('Course 5', 'images/file2.jpg'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 150,
                    margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade100,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Center(
                      child: Text(
                        'Banner Advertisement Here',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCourseCard(String courseName, String imagePath) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            width: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                imagePath,
                fit: BoxFit
                    .fill, // Ensures the image covers the entire container
              ),
            ),
          ),
          const SizedBox(height: 10), // Space between image and text
          Text(
            courseName,
            style: const TextStyle(
              color: Colors.deepPurple,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class DynamicCircleAvatar extends StatelessWidget {
  final String imagePath;
  final double radius;

  const DynamicCircleAvatar({super.key, required this.imagePath, this.radius = 36.0});

  @override
  Widget build(BuildContext context) {
    bool isNetworkImage =
        imagePath.startsWith('http') || imagePath.startsWith('https');
    bool isLocalImage = File(imagePath).existsSync();

    ImageProvider backgroundImage;

    if (isNetworkImage) {
      backgroundImage = NetworkImage(imagePath);
    } else if (isLocalImage) {
      backgroundImage = FileImage(File(imagePath));
    } else {
      backgroundImage = AssetImage(imagePath);
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color.fromARGB(255, 220, 228, 235),
      backgroundImage: backgroundImage,
    );
  }
}
