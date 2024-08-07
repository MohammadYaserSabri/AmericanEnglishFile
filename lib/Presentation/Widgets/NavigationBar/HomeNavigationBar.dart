// ignore_for_file: file_names

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';


      Widget homeNavigationBar(int selectedIndex , ValueChanged<int> onTappedItem ){


     return CurvedNavigationBar(
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
        index: selectedIndex,
        onTap: onTappedItem,
      );


      }







/* 
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
  } */
