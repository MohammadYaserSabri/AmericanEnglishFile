import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:flutter_application_caht/Presentation/DatabaseHelper.dart';
import 'package:flutter_application_caht/Presentation/Glossary.dart';
import 'package:flutter_application_caht/Screens/AppService.dart';
import 'package:flutter_application_caht/Presentation/Screens/StudyDashBoard.dart';
import 'package:flutter_application_caht/Presentation/Screens/HomeDashBoard.dart';
import 'package:flutter_application_caht/Screens/Example.dart';
import 'package:flutter_application_caht/Screens/LevelPreview.dart';
import 'package:flutter_application_caht/Screens/Login.dart';
import 'package:flutter_application_caht/Screens/QuestionScreen.dart';
import 'package:flutter_application_caht/Screens/Rejester.dart';
import 'package:flutter_application_caht/Screens/Unit.dart';
import 'package:flutter_application_caht/Screens/UsersScreen.dart';
import 'package:flutter_application_caht/Screens/chat_screen.dart';
import 'package:flutter_application_caht/Presentation/Vocabulary.dart';
import 'package:flutter_application_caht/Presentation/CourseManager.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_application_caht/Presentation/WordPreview.dart';
import 'package:sqflite/sqflite.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:translator/translator.dart';
import 'package:internet_connectivity_checker/internet_connectivity_checker.dart';
/* void main() async {
  


  /* await Firebase.initializeApp(
      options:const  FirebaseOptions(
    apiKey: 'AIzaSyAcBuvvKNzaMkUxy3yb4aoNBbTJ1Qf4x8g',
    appId: '1:710378218728:android:e741017eea7e5c1a0e555d',
    messagingSenderId: 'sendid',
    projectId: 'fir-74e71',
    storageBucket: 'myapp-b9yt18.appspot.com',
  )); */
  runApp(H());
} */

Future<void> translateWords() async {
  GoogleTranslator t = GoogleTranslator();

  Translation tra = await t.translate("Hello", from: "auto", to: "fa");
}

Future<void> clearAllData() async {
  // Clear Hive data
  var hiveBox = await Hive.openBox("settings");
  await hiveBox.clear();

  // Clear sqflite data
  final dbHelper = DatabaseHelper();
  Database? db = await dbHelper.database;
  await db?.delete('Level');
  await db?.delete('Book');
  await db?.delete('Vocabulary');
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );

  service.startService();
}

bool onIosBackground(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  // Return true to keep the task running
  return true;
}

void onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  Timer.periodic(Duration(seconds: 1), (timer) async {
    // Your background task here
    debugPrint('Background task is running'); // Use debugPrint instead of print

    // For example, you might want to check a condition to stop the service:
    /*   if (/* condition to stop service */) {
      service.stopSelf();
    } */
  });

  debugPrint("running service"); // Use debugPrint for debug messages
}

Future<void> initializeDatabase() async {
  final wordService = CourseManager();
  DatabaseHelper dbHelper = DatabaseHelper();
  Database? db = await dbHelper.database;

  if (db != null) {
    List<String> jsonFiles = [
      'assets/AmericanEnglishFile1.json',
    ];

    for (String jsonFile in jsonFiles) {
      Map<String, dynamic> jsonData =
          await wordService.loadJsonFromAssets(jsonFile);
      await processBooks(db, jsonData);
    }

    await db.close();
  } else {
    print("Failed to open the database.");
  }
}

Future<void> processBooks(Database db, Map<String, dynamic> jsonData) async {
  for (var entry in jsonData.entries) {
    String bookName = entry.key;
    await insertBookIfNotExists(db, bookName);
    await processUnitsData(db, bookName, entry.value[0]);
    await processVocabularyBankData(db, bookName, entry.value[1]);
  }
}

Future<void> insertBookIfNotExists(Database db, String bookName) async {
  List<Map<String, dynamic>> books =
      await db.query('Book', where: 'id = ?', whereArgs: [bookName]);
  if (books.isEmpty) {
    await db.insert('Book', {'id': bookName});
  }
}

Future<void> processUnitsData(
    Database db, String bookName, dynamic unitsData) async {
  if (unitsData.containsKey("Units")) {
    for (var unitEntry in unitsData["Units"]) {
      for (var unitEn in unitEntry.keys) {
        await insertUnitIfNotExists(db, bookName, unitEn);
        await insertVocabulary(
            db, bookName, unitEn, unitEntry[unitEn]['Vocabulary']);
      }
    }
  }
}

Future<void> processVocabularyBankData(
    Database db, String bookName, dynamic vBankData) async {
  if (vBankData.containsKey("VocabularyBank")) {
    for (var unitEntry in vBankData["VocabularyBank"]) {
      for (var unitEn in unitEntry.keys) {
        await insertUnitIfNotExists(db, bookName, unitEn);
        await insertVocabulary(
            db, bookName, unitEn, unitEntry[unitEn]['Vocabulary']);
      }
    }
  }
}

Future<void> insertUnitIfNotExists(
    Database db, String bookName, String unitEn) async {
  List<Map<String, dynamic>> units =
      await db.query('Level', where: 'id = ?', whereArgs: [unitEn]);
  if (units.isEmpty) {
    await db.insert('Level', {
      'id': unitEn,
      'book_id': bookName,
      'test1Progress': 0,
      'test2Progress': 0,
      'test3Progress': 0,
      'test4Progress': 0,
      'test5Progress': 0,
      'UnitProgress': 0
    });
  }
}

Future<void> insertVocabulary(Database db, String bookName, String unitEn,
    List<dynamic> vocabularyList) async {
  for (var voc in vocabularyList) {
    var vocabulary = Vocabulary(
        bookName,
        unitEn,
        voc['word'],
        voc['meaning'],
        voc['type'],
        List<String>.from(voc['Synonym']),
        voc['Description'],
        voc['OwnDescription']);
    await db.insert('Vocabulary', vocabulary.toMap());
  }
}

Database? db;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  translateWords();

  await Hive.initFlutter();
  //await clearAllData();
  // await DatabaseHelper().deleteDatabaseFiles();
  final dbHelper = DatabaseHelper();
  db = await dbHelper.database;
  var hive = await Hive.openBox("settings");
  var isFirstTimeEnter = hive.get("FirstTimeEnter");

  if (isFirstTimeEnter != null) {
    print("I am not null");
  } else {
    print("I was null for the first time");
    hive.put("FirstTimeEnter", 'true');

    await initializeDatabase();
  }

  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: 'AIzaSyAcBuvvKNzaMkUxy3yb4aoNBbTJ1Qf4x8g',
          appId: '1:710378218728:android:e741017eea7e5c1a0e555d',
          messagingSenderId: '710378218728',
          projectId: 'fir-74e71',
          storageBucket: 'gs://fir-74e71.appspot.com',
          databaseURL: 'https://fir-74e71-default-rtdb.firebaseio.com'),
    );
    // AppService().start();
    try {
      // await initializeService();
    } catch (e) {
      print("service problem: $e");
    }
    AppService().start();
    runApp(FlashChat());
    print("success");
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
}

// end main

class FlashChat extends StatefulWidget {
  FlashChat({super.key});

  @override
  State<FlashChat> createState() => _FlashChatState();
}

class _FlashChatState extends State<FlashChat> with WidgetsBindingObserver {
  String _appStatus = 'Unknown';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _updateAppStatus('Initialized');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _updateAppStatus('Disposed');
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        _updateAppStatus('Inactive');
        break;
      case AppLifecycleState.paused:
        _updateAppStatus('Paused');
        break;
      case AppLifecycleState.resumed:
        _updateAppStatus('Resumed');
        break;
      case AppLifecycleState.detached:
        _updateAppStatus('Detached');
        break;
      case AppLifecycleState.hidden:
        _updateAppStatus("hidden");
    }
  }

  void _updateAppStatus(String status) {
    setState(() {
      _appStatus = status;
    });
    print('App status: $_appStatus');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: HomeDashBoard.id,
      routes: {
        UsersScreen.id: (context) => UsersScreen(),
        MyApp.id: (context) => MyApp(),
        StudyDashboard.id: (context) => const StudyDashboard(),
        UnitsPage.id: (context) => UnitsPage.from(),
        WordPreview.id: (context) => const WordPreview(),
        ChatScreen.id: (context) => ChatScreen(),
        LevelPrevieww.id: (context) => LevelPrevieww(),
        HomeDashBoard.id: (context) => const HomeDashBoard(),
        Rejester.id: (context) => Rejester(),
        Login.id: (context) => Login(),
        Welcome.id: (context) => const Welcome(),
        QuestionScreen.id: (context) => QuestionScreen.from(),
      },
    );
  }
}
