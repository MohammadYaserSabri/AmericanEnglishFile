import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_caht/DatabaseHelper.dart';
import 'package:flutter_application_caht/Screens/Unit.dart';
import 'package:flutter_application_caht/Vocabulary.dart';
import 'package:flutter_application_caht/CourseManager.dart';

class WordPreview extends StatefulWidget {
  const WordPreview({Key? key}) : super(key: key);
  static const String id = "WordPreview";
  @override
  State<WordPreview> createState() => _WordPreviewState();
}

class _WordPreviewState extends State<WordPreview> {
  List<Vocabulary> _words = [];
  bool flag = false;
  Queue<Vocabulary> _wordsInQueue = Queue();
  Vocabulary? _editingWord;

  DatabaseHelper dbHelper = DatabaseHelper();
  @override
  void initState() {
    super.initState();
    _words = CourseManager().getAllVocabularyOfCurrentUnit();
  }

  @override
  Widget build(BuildContext context) {
    if (!flag) {
      for (var word in _words) {
        _wordsInQueue.add(word);
      }
      flag = true;
    }

    Vocabulary newWord = Vocabulary('', "", "", "", "", [], "", "");
    if (_wordsInQueue.length >= 1) {
      newWord = _wordsInQueue.removeFirst();
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(16),
                color: Colors.deepPurple,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      newWord.getUnitName(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "1/${_wordsInQueue.length}",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: Container(
                padding: EdgeInsets.all(20),
                color: Colors.deepPurple.shade50,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        color: Colors.deepPurple,
                        child: Text(
                          "Word : ",
                          style: TextStyle(
                              color: Colors.deepPurple.shade50, fontSize: 18),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(children: [
                        Text(
                          newWord.getWord(),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ]),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        color: Colors.deepPurple,
                        child: Text(
                          "Meaning : ",
                          style: TextStyle(
                              color: Colors.deepPurple.shade50, fontSize: 18),
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(children: [
                        Text(
                          newWord.getMeaning(),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ]),
                      SizedBox(height: 20),
                      Container(
                        color: Colors.deepPurple,
                        child: Text(
                          "Type : ",
                          style: TextStyle(
                              color: Colors.deepPurple.shade50, fontSize: 18),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(children: [
                        Text(
                          newWord.getType(),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ]),
                      SizedBox(height: 20),
                      Container(
                        color: Colors.deepPurple,
                        child: Text(
                          "Synonyms : ",
                          style: TextStyle(
                              color: Colors.deepPurple.shade50, fontSize: 18),
                        ),
                      ),
                      Row(children: [
                        Expanded(
                          child: Text(
                            newWord.getSynonym() +
                                "jldsjflsjldfjlsdjflkjldjfldjlfkjlksdjfljsdlfjlsdjfjsdklfjlssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ]),
                      SizedBox(height: 10),
                      Container(
                        color: Colors.deepPurple,
                        child: Text(
                          "Description : ",
                          style: TextStyle(
                              color: Colors.deepPurple.shade50, fontSize: 18),
                        ),
                      ),
                      Text(
                        newWord.getDescription(),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        color: Colors.deepPurple,
                        child: Text(
                          "Own Description : ",
                          style: TextStyle(
                              color: Colors.deepPurple.shade50, fontSize: 18),
                        ),
                      ),
                      Row(children: [
                        Text(
                          newWord.getOwnDescription(),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.deepPurple,
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          if (_wordsInQueue.length >= 1) {
                            setState(() {});
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Study Complete"),
                                  content: Text(
                                      "You have completed the study. What would you like to do next?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
                                        // Perform action to read again
                                      },
                                      child: Text("Read Again"),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        await DatabaseHelper()
                                            .updateUnitProgress(
                                                100,
                                                CourseManager()
                                                    .getCurrentUnit());

                                        await CourseManager()
                                            .setCourseProgress();

                                        Navigator.of(context)
                                            .pop(); // Close the dialog
                                        Navigator.pushReplacementNamed(
                                            context, UnitsPage.id);
                                      },
                                      child: Text("Back to Home"),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.deepPurple,
                          elevation: 5,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        icon:
                            Icon(Icons.arrow_forward, color: Colors.deepPurple),
                        label: Text(
                          'Next',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.deepPurple,
                          elevation: 5,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        icon: Icon(Icons.volume_up, color: Colors.deepPurple),
                        label: Text(
                          'Listen',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _editWord(context, newWord);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.deepPurple,
                          elevation: 5,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        icon: Icon(Icons.edit, color: Colors.deepPurple),
                        label: Text(
                          'Edit',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editWord(BuildContext context, Vocabulary word) {
    TextEditingController wordController =
        TextEditingController(text: word.getWord());
    TextEditingController MeaningController =
        TextEditingController(text: word.getMeaning());
    TextEditingController ownDescriptionController =
        TextEditingController(text: word.getOwnDescription());
    TextEditingController typeController =
        TextEditingController(text: word.getType());
    TextEditingController descriptionController =
        TextEditingController(text: word.getDescription());

    List<TextEditingController> synonymControllers = [];
    for (var synonym in word.getSynonym().split(',')) {
      if (synonym.isNotEmpty) {
        synonymControllers.add(TextEditingController(text: synonym.trim()));
      }
    }

    _editingWord = word;
    String targetWord = word.getWord();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Word"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: wordController,
                  decoration: InputDecoration(labelText: 'Word'),
                ),
                TextFormField(
                  controller: MeaningController,
                  decoration: InputDecoration(labelText: 'meaning'),
                ),
                TextFormField(
                  controller: typeController,
                  decoration: InputDecoration(labelText: 'Type'),
                ),
                SizedBox(height: 10),
                Text(
                  "Synonyms:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                for (var i = 0; i < synonymControllers.length; i++)
                  TextFormField(
                    controller: synonymControllers[i],
                    decoration: InputDecoration(labelText: 'Synonym ${i + 1}'),
                  ),
                SizedBox(height: 10),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                TextFormField(
                  controller: ownDescriptionController,
                  decoration: InputDecoration(labelText: 'Own Description'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                _editingWord!.setWord(wordController.text);
                _editingWord!.setMeaning(MeaningController.text);
                _editingWord!.setType(typeController.text);
                _editingWord!.setSynonym(
                    synonymControllers.map((e) => e.text).join(','));
                _editingWord!.setDescription(descriptionController.text);
                _editingWord!.setOwnDescription(ownDescriptionController.text);
                await dbHelper.updateWord(
                    _editingWord!.getBookName(),
                    _editingWord!.getUnitName(),
                    targetWord,
                    _editingWord!.toMap());

                CourseManager().setAllVocabularyOfSelectedUnit(
                    CourseManager().getCurrentUnit());

                Navigator.of(context).pop();
                setState(() {});
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }
}
