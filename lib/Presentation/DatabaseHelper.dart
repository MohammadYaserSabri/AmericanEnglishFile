// ignore_for_file: unnecessary_null_comparison

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_caht/Screens/Question.dart';
import 'package:flutter_application_caht/Presentation/CourseManager.dart';
import 'package:flutter_application_caht/Screens/UserModel.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart' as pathPro;
import 'dart:async';

import 'package:sqflite/sql.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  static sql.Database? _database;

  DatabaseHelper._internal();

  Future<sql.Database?> get database async {
    if (_database != null && _database!.isOpen) return _database;

    _database = await _initDatabase();

    return _database;
  }

  Future<sql.Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), "AmericanEnglishFile.db");
    print("Database path: $path");
    return openDatabase(path, version: 2, onCreate: _create);
  }

  Future<void> deleteDatabaseFiles() async {
    await deleteDatabase(
        join(await sql.getDatabasesPath(), "AmericanEnglishFile.db"));
  }

  Future<bool> isCurrentBookExists(String book) async {
    final db = await database;

    if (db == null) {
      // Handle case where database is null
      print("Database is null");
      return false;
    }

    if (!db.isOpen) {
      // Handle case where database is closed
      print("Database is closed");
      return false;
    }

    final List<Map<String, dynamic>> books = await db.query(
      'Book',
      where: 'id = ?',
      whereArgs: [book],
    );
    return books.isNotEmpty; // Simplified check for existence
  }

  Future<List<String>> getUnitsIdByBook(String bookId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(
      'Level',
      where: 'book_id = ?',
      whereArgs: [bookId],
    );

    return List.generate(maps.length, (i) {
      return maps[i]['id'] as String;
    });
  }

  Future<void> _create(sql.Database db, int version) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS Level(
      id TEXT PRIMARY KEY,
      book_id TEXT,
      unitProgress INTEGER,
      test1Progress INTEGER,
      test2Progress INTEGER,
      test3Progress INTEGER,
      test4Progress INTEGER,
      test5Progress INTEGER,
      FOREIGN KEY (book_id) REFERENCES Book(id)
    )
  ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS Book(
      id TEXT PRIMARY KEY
    )
  ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS BlackListUsers (
      name TEXT,
      userId TEXT,
      image TEXT
    )
  ''');
    await db.execute('''
    CREATE TABLE IF NOT EXISTS PrivateUsers (
      id TEXT,
      userId TEXT,
      usersName TEXT
    )
  ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS Vocabulary (
      bookName TEXT,
      unitName TEXT,
      word TEXT,
      meaning TEXT,
      type TEXT,
      synonym TEXT,
      description TEXT,
      ownDescription TEXT,
      FOREIGN KEY (bookName) REFERENCES Book(id),
      FOREIGN KEY (unitName) REFERENCES Unit(id)
    )
  ''');
    await db.execute('''
    CREATE TABLE IF NOT EXISTS Profile(
      id TEXT PRIMARY KEY,
      name TEXT ,
      image TEXT 
    )
  ''');
  }

  Future<void> createProfileLocallyToDatabase(String name, String id) async {
    sql.Database? db = await database;

    await db!.insert("Profile", {'id': id, 'name': name, 'image': ''},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateProfileLocallyFromDatabase(
      String Oldname, String newName, String image) async {
    sql.Database? db = await database;

    await db!.update(
        "Profile",
        where: "name = ?",
        whereArgs: [Oldname],
        {'name': newName, 'image': image});
  }

  Future<Map<String, dynamic>> retriveProfileLocallyFromDatabase() async {
    sql.Database? db = await database;
    List<Map<String, dynamic>> map = await db!.query("Profile");

    if (map != null && map.isNotEmpty) {
      return map[0];
    } else{
return {};
    }
      
  }

  Future<String> saveImageLocally(File image) async {
    final directory = await pathPro.getApplicationDocumentsDirectory();

    final fileName = basename(image.path);
    final localImagePath = join(directory.path, fileName);
    await image.copy(localImagePath);
    return localImagePath;
  }

  Future<bool> isUserExistsInPrivateUsersChat(String id) async {
    sql.Database? db = await database;

    print("in methods");
    List<Map<String, dynamic>> users =
        await db!.query("PrivateUsers", where: "userId = ? ", whereArgs: [id]);

    if (users.isEmpty) {
      print("empty");
    }

    if (users.isEmpty) {
      return false;
    }

    print("user not empty");

    List<String> privateUsers = [];
    String x = users[0]['usersName'];

    privateUsers = x.split(',').map(
      (e) {
        return e;
      },
    ).toList();

    for (var a in privateUsers) {
      print("user is : $a");
    }
    if (privateUsers.contains(id)) {
      print("it contsins");
      return true;
    } else {
      print("no");
      return false;
    }
  }

  Future<void> addUserToPrivateUsersChat(String myId, String targetId) async {
    sql.Database? db = await database;

    print("my i d: $myId");
    print("target i d: $targetId");

    List<Map<String, dynamic>> users =
        await db!.query("PrivateUsers", where: "id = ? ", whereArgs: [myId]);
    String x = '';
    if (!users.isEmpty) {
      x = users[0]['usersName'];
      print("tes empty");
    }

    if (x == null || x.isEmpty) {
      x = "$targetId,";
    } else {
      x += ",$targetId";
    }
    print(x);
    await db!.update(
        "PrivateUsers", where: "id = ?", whereArgs: [myId], {"usersName": x});
  }

  Future<int> updateTestProgress(int value) async {
    sql.Database? db = await database;

    return await db!.update("Level", {'test${_getTestLevel()}Progress': value},
        where: " id = ? ", whereArgs: [CourseManager().getCurrentUnit()]);
  }

  int _getTestLevel() {
    switch (CourseManager().getTestLevel()) {
      case TestLevel.First:
        return 1;
      case TestLevel.Second:
        return 2;
      case TestLevel.Third:
        return 3;
      case TestLevel.Fourth:
        return 4;
      case TestLevel.Fiveth:
        return 5;
      default:
        return 0;
    }
  }

  Future<int> updateUnitProgress(int value, String unit) async {
    sql.Database? db = await database;

    return await db!.update("Level", {'unitProgress': value},
        where: " id = ? ", whereArgs: [unit]);
  }

  Future<int> loadUnitProgress(String unit) async {
    sql.Database? db = await database;

    List<Map<String, dynamic>> maps =
        await db!.query('Level', where: " id = ? ", whereArgs: [unit]);
    return maps[0]['unitProgress'];
  }

  Future<List<BlackListUserModel>> loadBlackListUsers() async {
    sql.Database? db = await database;

    List<BlackListUserModel> temp = [];
    List<Map<String, dynamic>> maps = await db!.query('BlackListUsers');

    for (var map in maps) {
      BlackListUserModel blackListUserModel = BlackListUserModel(
          name: map['name'], userId: map['userId'], image: map['image']);

      temp.add(blackListUserModel);
    }

    return temp;
  }

  Future<bool> deleteUserFromBlackList(String targetUserId, String myId) async {
    sql.Database? db = await database;

    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection("Users").doc(myId).get();

      if (doc == null) {
        print("no doc found by this user id $myId");
        return false;
      }

      List<String> blackListUsers = (doc['blackListUsers'] as List<dynamic>)
          .map((e) => e as String)
          .toList();

      if (blackListUsers.contains(targetUserId)) {
        blackListUsers.remove(targetUserId);
      }

      await FirebaseFirestore.instance
          .collection("Users")
          .doc(myId)
          .set({'blackListUsers': blackListUsers});

      await db!.delete('BlackListUsers',
          where: " userId = ?", whereArgs: [targetUserId]);

      return true;
    } on FirebaseException catch (e) {
      print(e.code);
      return false;
    }
  }

  Future<bool> addUserToBlackList(
      BlackListUserModel targetUser, String myId) async {
    sql.Database? db = await database;

    try {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(myId)
          .update(targetUser.toMap());

      await db!.insert("BlackListUsers", targetUser.toMap());

      return true;
    } on FirebaseException catch (e) {
      print(e.code);
      return false;
    }
  }

  Future<List<int>> loadTestProgressOfUnit(String unit) async {
    //   print(" at first");
    sql.Database? db = await database;
    List<int> testProgress = [];
    List<Map<String, dynamic>> maps = await db!.query(
      'Level',
      where: "id = ?",
      whereArgs: [unit],
    );
    // print("at if ");
    if (maps.isNotEmpty) {
      var a = maps.first;
      for (int x = 1; x <= 5; x++) {
        testProgress.add(a['test${x}Progress']);
      }
    }
    print("after if ");
    print("in database helper for ${testProgress.length}");
    return testProgress;
  }

  Future<int> insert(Map<String, dynamic> row, String table) async {
    sql.Database? db = await database;

    return await db!
        .insert(table, row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> queryVocabularyByUnitAndBook(
      String table, String unit, String book) async {
    sql.Database? db = await database;
    return await db!.query(table,
        where: 'bookName = ? AND unitName = ?', whereArgs: [book, unit]);
  }

  Future<List<Map<String, dynamic>>> queryAllVocabularyOfTheBook(
      String table, String book) async {
    sql.Database? db = await database;
    return await db!.query(table, where: 'bookName = ? ', whereArgs: [book]);
  }

  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    sql.Database? db = await database;
    return await db!.query(table);
  }

  Future<int> deleteWord(String Word, String bookName, String unitName) async {
    sql.Database? db = await database;

    return await db!.delete('Vocabulary',
        where: 'word = ? AND bookName =?  AND  unitName = ?',
        whereArgs: [Word, bookName, unitName]);
  }

  Future<int> updateWord(String bookName, String unitName, String word,
      Map<String, dynamic> map) async {
    sql.Database? db = await database;

    // Update the word in the database
    return await db!.update(
      "Vocabulary",
      map,
      where: 'bookName = ? AND unitName = ? AND word = ?',
      whereArgs: [bookName, unitName, word],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Word not found
}
