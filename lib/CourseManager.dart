// ignore: file_names
import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_application_caht/DatabaseHelper.dart';
import 'package:flutter_application_caht/Screens/Question.dart';
import 'package:flutter_application_caht/Screens/Unit.dart';
import 'package:flutter_application_caht/Vocabulary.dart';
import 'package:flutter_application_caht/main.dart';

class CourseManager {
  static final CourseManager _instance = CourseManager._internal();

  factory CourseManager() {
    return _instance;
  }
  Action action = Action.Test;

  void setAction(Action action) {
    this.action = action;
  }

  Action getAction() {
    return action;
  }

  

  TestLevel _testLevel = TestLevel.First;

  void setTestLevel(TestLevel testLevel) {
    this._testLevel = testLevel;
  }

  TestLevel getTestLevel() {
    return this._testLevel;
  }

  String _currentUnitSelected = "A1";
  String _currentBookSelected = "AmericanEnglishFile1";

  List<String> _allUnitsNamesOfTheBook = [];
  List<Vocabulary> _allVocabularyOfCurrentBook = [];

  List<String> _allUnitsNamesOfTheWordsCardSection = [];
  List<String> _allUnitsNamesOfTheVocabularyBankCardSection = [];

  List<Vocabulary> _allVocabularyOfCurrentUnit = [];
  List<Vocabulary> _allMyOwnWords = [];
  CourseManager._internal();

// we will use this list while we want to take an exam with four asnwer.   3 answer come from this list
// in later updates we improve difficulties                currently :   unsupported
  int countAllUnitOfTheWordsCardSection() {
    return _allUnitsNamesOfTheWordsCardSection.length;
  }

  List<String> getAllUnitsNamesOFTheBook() {
    return _allUnitsNamesOfTheBook;
  }

  int countAllUnitOfTheVocabularyBankCardSection() {
    return _allUnitsNamesOfTheVocabularyBankCardSection.length;
  }
// #region

  double _wordsProgress = 0;
  double _allTestsProgress = 0;
  double _courseProgress = 0;
  double _vocabularyBankProgress = 0;

  double getWordsProgress() {
    print("i am get progress : $_wordsProgress");
    return double.parse(_wordsProgress.toStringAsFixed(0));
  }

  double getTotalOfAllTestsProgress() {
    print("test toatl : $_allTestsProgress");
    return double.parse(_allTestsProgress.toStringAsFixed(0));
  }

  double getCourseProgress() {
    return double.parse(_courseProgress.toStringAsFixed(0));
  }

  double getVocabularyBankProgress() {
    return _vocabularyBankProgress;
  }

// #endregion
  Future<void> setWordsProgress() async {
    DatabaseHelper dbHelper = DatabaseHelper();

    int totalProgress = 0;

    for (int x = 0; x < countAllUnitOfTheWordsCardSection(); x++) {
      totalProgress += await dbHelper
          .loadUnitProgress(_allUnitsNamesOfTheWordsCardSection[x]);
    }

    _wordsProgress =
        (totalProgress * 100) / (countAllUnitOfTheWordsCardSection() * 100);

    print(
        " in set : ${_wordsProgress} +  count all unit : ${countAllUnitOfTheWordsCardSection()} and total progress : $totalProgress");
  }

  Future<void> setTotalOfAllTestsProgress() async {
    DatabaseHelper dbHelper = DatabaseHelper();

    double totalProgress = 0;

    for (int x = 0; x < _allUnitsNamesOfTheBook.length; x++) {
      List<int> tests =
          await dbHelper.loadTestProgressOfUnit(_allUnitsNamesOfTheBook[x]);

      int temp = 0;

      for (var test in tests) {
        temp += test;
      }
      totalProgress += (temp * 100) / 500;
    }

    _allTestsProgress =
        (totalProgress * 100) / (_allUnitsNamesOfTheBook.length * 100);
    print("end of test");
  }

  Future<void> setCourseProgress() async {
    await setWordsProgress();
    await setVocabularyBankProgress();
    await setTotalOfAllTestsProgress();
    print("last 2");
    _courseProgress = (_wordsProgress / 2) + (_vocabularyBankProgress / 2);
    print("last");
  }

  Future<void> setVocabularyBankProgress() async {
    DatabaseHelper dbHelper = DatabaseHelper();

    int totalProgress = 0;

    for (int x = 0; x < countAllUnitOfTheVocabularyBankCardSection(); x++) {
      totalProgress += await dbHelper
          .loadUnitProgress(_allUnitsNamesOfTheVocabularyBankCardSection[x]);
    }

    _vocabularyBankProgress = (totalProgress * 100) /
        (countAllUnitOfTheVocabularyBankCardSection() * 100);
    print("end of voc");
  }

  // this method will set all words that user added to card MyWords .
  void loadMyOwnWords() async {
    _allMyOwnWords.clear();
    List<Vocabulary> temp = [];

    for (var voc in _allVocabularyOfCurrentBook) {
      // print(
      // "vocabulary unit is ${voc.getUnitName()} and pass unit is : $unitName ");
      if (voc.getUnitName() == 'MyWords') {
        temp.add(voc);
        // print(
        // "selected word ${voc.getWord()}  and unit is ${voc.getUnitName()}");
      }
    }

    //  print("length vocabulary : ${_allVocabularyOfCurrentUnit.length}");
    _allMyOwnWords = temp;
  }

  void addWordToVocabulary(Vocabulary data) {
    _allVocabularyOfCurrentBook.add(data);
  }

  int countNumberOfTheWordsInCurrentUnit() {
    return _allVocabularyOfCurrentUnit.length;
  }

  void setAllVocabularyOfSelectedUnit(String unitName) {
    _allVocabularyOfCurrentUnit.clear();
    List<Vocabulary> temp = [];

    for (var voc in _allVocabularyOfCurrentBook) {
      // print(
      // "vocabulary unit is ${voc.getUnitName()} and pass unit is : $unitName ");
      if (voc.getUnitName() == unitName) {
        temp.add(voc);
        print(
            "selected word ${voc.getWord()}  and unit is ${voc.getUnitName()}");
      }
    }

    print("length vocabulary : ${_allVocabularyOfCurrentUnit.length}");
    _allVocabularyOfCurrentUnit = temp;
  }

  List<Vocabulary> getAllVocabularyOfCurrentUnit() {
    return _allVocabularyOfCurrentUnit;
  }

  List<String> getAllSynonymsOfCurrentUnit() {
    List<String> synonyms = [];

    for (var voc in _allVocabularyOfCurrentUnit) {
      synonyms.add(voc.getSynonym());
    }

    List<String> tt = [];

    for (String a in synonyms) {
      List<String> temp = a
          .split(',')
          .map(
            (e) => e.trim(),
          )
          .toList();
      print("no no $a");
      for (var x in temp) {
        tt.add(x);
      }
    }

    for (var g in tt) {
      print(" synonym are : $g  ...");
    }
    return tt;
  }

  List<String> getAllWordsOfCurrentUnit() {
    List<String> words = [];

    for (var voc in _allVocabularyOfCurrentUnit) {
      words.add(voc.getWord());
    }

    for (var a in words) {
      print(a);
    }
    return words;
  }

  List<String> getAllDescriptionOfCurrentUnit() {
    List<String> description = [];

    for (var voc in _allVocabularyOfCurrentUnit) {
      description.add(voc.getDescription());
    }

    return description;
  }

  List<String> getAllOwnDescriptionOfCurrentUnit() {
    List<String> ownDescription = [];

    for (var voc in _allVocabularyOfCurrentUnit) {
      ownDescription.add(voc.getOwnDescription());
    }

    return ownDescription;
  }

  Future<Map<String, dynamic>> loadJsonFromAssets(String filePath) async {
    String jsonString = await rootBundle.loadString(filePath);
    return jsonDecode(jsonString);
  }

  String getCurrentBook() {
    return _currentBookSelected;
  }

  String getCurrentUnit() {
    return _currentUnitSelected;
  }

  void setCurrentBook(String book) {
    _currentBookSelected = book;
  }

  void setCurrentUnit(String unit) {
    _currentUnitSelected = unit;
  }

  Future<void> setAllVocabularyOfTheCurrentBook(String bookName) async {
    _allVocabularyOfCurrentBook.clear();

    List<Map<String, dynamic>> data = await DatabaseHelper()
        .queryAllVocabularyOfTheBook('Vocabulary', bookName);

    for (var map in data) {
      String bookName = map['bookName'];
      String unitName = map['unitName'];
      String word = map['word'];
      String meaning = map['meaning'];
      String type = map['type'];
      dynamic synonymData = map['synonym'];
      List<String> synonym = [];

      if (synonymData is List) {
        // If the synonymData is already a list, use it directly
        synonym = synonymData.cast<String>();
      } else if (synonymData is String) {
        // If the synonymData is a string, split it and trim each element
        synonym = synonymData.split(' , ').map((e) => e.trim()).toList();
      }

      String description = map['description'];
      String ownDescription = map['ownDescription'];

      var vocabulary = Vocabulary(
          bookName, unitName, word,meaning, type, synonym, description, ownDescription);

      _allVocabularyOfCurrentBook.add(vocabulary);
    }
  }

  Future<List<Vocabulary>> getAllVocabularyOfTheBook() async {
    return _allVocabularyOfCurrentBook;
  }

  void setUnitsNamesOfTheBook(String bookName) async {
    _allUnitsNamesOfTheBook.clear();
    _allUnitsNamesOfTheVocabularyBankCardSection.clear();
    _allUnitsNamesOfTheWordsCardSection.clear();
    _allUnitsNamesOfTheBook = await DatabaseHelper().getUnitsIdByBook(bookName);

    for (String unitName in _allUnitsNamesOfTheBook) {
      if (unitName.startsWith("VB")) {
        _allUnitsNamesOfTheVocabularyBankCardSection.add(unitName);
      } else {
        _allUnitsNamesOfTheWordsCardSection.add(unitName);
      }
    }
  }

  List<String> getUnitNamesOfTheWordsCardSection() {
    return _allUnitsNamesOfTheWordsCardSection;
  }

  List<String> getUnitNamesOfTheVocabularyBankCardSection() {
    return _allUnitsNamesOfTheVocabularyBankCardSection;
  }

  /// this method will return all words that are in the unit of the current book .   imagine file 1 has unit 2 .   it return all words of unit2 of this book

  void deleteWord(String word) {
    List<Vocabulary> wordsCopy = List.from(
        _allVocabularyOfCurrentBook); // Create a copy of the _words list

    for (var a in wordsCopy) {
      if (a.getWord() == word) {
        _allVocabularyOfCurrentBook
            .remove(a); // Remove the element from the original list
      }
    }
    setAllVocabularyOfSelectedUnit(_currentUnitSelected);
  }

  List<int> _unitsProgressOfWordsCardSection = [];
  List<int> _unitsProgressOfVocabularyBankCardSection = [];

  Future<void> loadUnitsProgress() async {
    await _loadUnitsProgressOfWordsCardSection();
    await _loadUnitsProgressOfVocabularyBankCardSection();
  }

  Future<void> _loadUnitsProgressOfWordsCardSection() async {
    List<int> targetCollection = [];

    _unitsProgressOfWordsCardSection.clear();
    for (var a in _allUnitsNamesOfTheWordsCardSection) {
      int x = await DatabaseHelper().loadUnitProgress(a);

      targetCollection.add(x);
    }

    _unitsProgressOfWordsCardSection = targetCollection;
  }

  Future<void> _loadUnitsProgressOfVocabularyBankCardSection() async {
    List<int> targetCollection = [];

    for (var a in _allUnitsNamesOfTheVocabularyBankCardSection) {
      int x = await DatabaseHelper().loadUnitProgress(a);

      targetCollection.add(x);
    }
    _unitsProgressOfVocabularyBankCardSection.clear();
    _unitsProgressOfVocabularyBankCardSection = targetCollection;
  }

  int getUnitProgressOfCardSectionInOrder(int order) {
    if (CourseManager().action == Action.Words) {
      return _unitsProgressOfWordsCardSection[order];
    } else {
      if (order >= _unitsProgressOfVocabularyBankCardSection.length) {
        return _unitsProgressOfVocabularyBankCardSection[0];
      }
      return _unitsProgressOfVocabularyBankCardSection[order];
    }
  }

  bool unitCardSectionProgressIsNotEmpty() {
    if (CourseManager().action == Action.Words) {
      if (_unitsProgressOfWordsCardSection.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } else {
      if (_unitsProgressOfVocabularyBankCardSection.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    }
  }

  List<int> _testProgress = [];
  Future<void> loadTestProgressOfUnit(String unitName) async {
    print("in word loader load test progress");

    _testProgress = await DatabaseHelper().loadTestProgressOfUnit(unitName);

    for (var a in _testProgress) {
      print(" in for values : $a");
    }
  }

  int getTestProgressOfCurrentUnitInOrder(int order) {
    print("order get test progress is : ${_testProgress[order]}");

    return _testProgress[order];
  }

  int getTotalUnitsCardSectionProgressPercent() {
    var sum = 0;

    for (var a in _unitsProgressOfWordsCardSection) {
      sum += a;
    }
    return sum;
  }

  int getTotalVocabularyBankCardProgressPercent() {
    var sum = 0;

    for (var a in _unitsProgressOfVocabularyBankCardSection) {
      sum += a;
    }
    return sum;
  }

  bool TestProgressIsNotEmpty() {
    if (_testProgress.isNotEmpty) {
      print(
          "test progress in not empty and has length ${_testProgress.length}");
      return true;
    } else {
      print("is empty test progress");
      return false;
    }
  }
}
