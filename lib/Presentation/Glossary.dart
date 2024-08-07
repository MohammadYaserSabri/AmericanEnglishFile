import 'dart:async';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_application_caht/Screens/Login.dart';
import 'package:internet_connectivity_checker/internet_connectivity_checker.dart';

class Welcome extends StatefulWidget {
  const Welcome({Key? key}) : super(key: key);

  static const String id = 'Welcome';

  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  String selectedLanguage = 'en'; // Default language is English
  bool isConnected = false;

  // Define the language codes, names, and icons
  final Map<String, Map<String, String>> languages = {
    'en': {'name': 'English', 'icon': 'images/en.png'},
    'fa': {'name': 'Farsi', 'icon': 'images/fa.png'},
    'hi': {'name': 'Hindi', 'icon': 'images/hi.png'},
    'ur': {'name': 'Urdu', 'icon': 'images/ur.png'},
    'ar': {'name': 'Arabic', 'icon': 'images/ar.png'},
    'fr': {'name': 'French', 'icon': 'images/fr.png'},
    'es': {'name': 'Spanish', 'icon': 'images/es.png'},
    'de': {'name': 'German', 'icon': 'images/de.png'},
    'ru': {'name': 'Russian', 'icon': 'images/ru.png'},
    'zh': {'name': 'Chinese', 'icon': 'images/zh.png'},
  };

  @override
  void initState() {
    super.initState();
   // cheakConnection();
    
  }

 /*  StreamSubscription<bool>? netConnection;
  void cheakConnection() async {
    netConnection = ConnectivityChecker().stream.listen(
      (event) {
        print("net connect is :${event}");
      },
    );
  } */

  Future<void> downloadLanguageData() async {
    if (!isConnected) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('No Internet Connection'),
          content:
              Text('Please connect to the internet to download language data.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Dummy URL for language data, replace with actual URL
    final url = Uri.parse('https://example.com/language_data.json');

    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        // Save language data locally
        // In a real scenario, save the data in local storage or a database
        print('Language data downloaded successfully');
      } else {
        throw Exception('Failed to load language data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 33, 37, 41),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'images/Glossary.png',
                  height: MediaQuery.of(context).size.width * 0.7,
                  width: MediaQuery.of(context).size.width * 0.9,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 20),
                Text(
                  'Welcome to American English File',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  'Enhance your English skills with us',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                DropdownButton<String>(
                  value: selectedLanguage,
                  items: languages.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Row(
                        children: [
                          Image.asset(
                            entry.value['icon']!,
                            width: 24,
                            height: 24,
                          ),
                          SizedBox(width: 10),
                          Text(entry.value['name']!),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedLanguage = value!;
                    });
                  },
                  dropdownColor: Colors.white,
                  icon: Icon(Icons.arrow_downward, color: Colors.black),
                  iconSize: 24,
                  underline: Container(
                    height: 2,
                    color: Colors.teal,
                  ),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: downloadLanguageData,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.teal,
                  ),
                  child: Text(
                    'Download Language Data',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, Login.id);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.teal,
                  ),
                  child: Text(
                    'Get Started',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
