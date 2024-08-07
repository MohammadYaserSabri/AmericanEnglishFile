// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_application_caht/Presentation/DatabaseHelper.dart';
import 'package:flutter_application_caht/Presentation/Styles/TextStyles/CustomTextStyles.dart';
import 'package:flutter_application_caht/Presentation/Widgets/AppBar/CourseAppBar.dart';
import 'package:flutter_application_caht/Presentation/Widgets/Button/CustomButtons.dart';
import 'package:flutter_application_caht/Presentation/Widgets/Card/CourseCard.dart';
import 'package:flutter_application_caht/Presentation/Widgets/Drawer/DrawerHeader.dart';
import 'package:flutter_application_caht/Presentation/Widgets/Drawer/DrawerItem.dart';
import 'package:flutter_application_caht/Presentation/Widgets/NavigationBar/HomeNavigationBar.dart';

final dbHelper = DatabaseHelper();

class HomeDashBoard extends StatefulWidget {
  static const String id = "Course";
  const HomeDashBoard({super.key});

  @override
  State<HomeDashBoard> createState() => _HomeDashBoardState();
}

class _HomeDashBoardState extends State<HomeDashBoard> {
  final int _selectedIndex = 0;
  bool loadingChatScreen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            buildDrawerHeader(),
            buildDrawerItem(Icons.settings, 'Settings', () {
              /* Add logic for settings */
            }),
            buildDrawerItem(Icons.report, 'Report', () {
              /* Add logic for report */
            }),
            buildDrawerItem(Icons.more, 'More', () {/* Add logic for more */}),
            buildDrawerItem(Icons.logout, 'LogOut', () async {
              /* Add logic for logout */
            }),
          ],
        ),
      ),
      appBar: courseAppBar("", () {}, () {}),
      bottomNavigationBar: homeNavigationBar(_selectedIndex, (value) {}),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome Back,', style: welcomeTextStyle()),
                Text(
                  'Mr Yaser',
                  style: userNameTextStyle(),
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
                  Text(
                    "Chat with English Learner",
                    style: defaultTextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Login to chat",
                    style: defaultTextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  customMaterialButton(
                    text: "Log in",
                    onPressed: () {},
                  ),
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
                    margin: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade100,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Text(
                        'Banner Advertisement Here',
                        style: bannerTextStyle(),
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
}
