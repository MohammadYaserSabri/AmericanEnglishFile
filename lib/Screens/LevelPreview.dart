import 'package:flutter/material.dart';
import 'package:flutter_application_caht/Presentation/DatabaseHelper.dart';
import 'package:flutter_application_caht/Presentation/Vocabulary.dart';
import 'package:flutter_application_caht/Presentation/CourseManager.dart';
import 'package:flutter_application_caht/Presentation/WordPreview.dart';

DatabaseHelper dbHelper = DatabaseHelper();
List<Vocabulary> _words = [];

class LevelPrevieww extends StatefulWidget {
  static const String id = "LevelPrevi";

  @override
  _LevelPreviewwState createState() => _LevelPreviewwState();
}

class _LevelPreviewwState extends State<LevelPrevieww> {
  @override
  Widget build(BuildContext context) {
    _words.clear();
    _words = CourseManager().getAllVocabularyOfCurrentUnit();

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70.0),
        child: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AddWordDialog(
                  bookName: CourseManager().getCurrentBook(),
                  unitName: CourseManager().getCurrentUnit(),
                  onWordAdded: () => setState(() {}),
                );
              },
            );
          },
          child: const Icon(Icons.add),
          backgroundColor: Colors.deepPurple.shade500,
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.deepPurple,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Level Preview",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "1/${_words.length}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                color: const Color.fromARGB(255, 255, 255, 255),
                child: ListView.builder(
                  itemCount: _words.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      elevation: 4,
                      color: Colors.deepPurple.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: ListTile(
                          title: Text(
                            _words[index].getWord(),
                            style: const TextStyle(
                              color: Colors.deepPurple,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.deepPurple,
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Delete Word"),
                                    content: const Text(
                                        "Are you sure you want to delete this word?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          await dbHelper.deleteWord(
                                              _words[index].getWord(),
                                              _words[0].getBookName(),
                                              _words[0].getUnitName());

                                          CourseManager().deleteWord(
                                              _words[index].getWord());

                                          Navigator.of(context).pop();
                                          setState(() {});
                                        },
                                        child: const Text("Delete"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.deepPurple,
              child: SizedBox(
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    if (_words.length >= 1) {
                      Navigator.pushReplacementNamed(
                        context,
                        WordPreview.id,
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Error"),
                            content: const Text("Your list is empty to learn"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Ok"),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade100,
                    elevation: 5,
                  ),
                  child: const Text(
                    'Go To Level',
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class AddWordDialog extends StatefulWidget {
  AddWordDialog(
      {required this.bookName,
      required this.unitName,
      required this.onWordAdded});
  final Function()? onWordAdded;
  final String unitName;
  final String bookName;

  @override
  _AddWordDialogState createState() => _AddWordDialogState();
}

class _AddWordDialogState extends State<AddWordDialog> {
  List<TextEditingController> _synonymControllers = [TextEditingController()];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? word;
  String? type;
  String? meaning;
  List<String> synonym = [""];
  String? description;

  @override
  void dispose() {
    for (var controller in _synonymControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Add Word',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  onChanged: (value) {
                    word = value;
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.deepPurple[50],
                    labelText: 'Word',
                    labelStyle:
                        const TextStyle(color: Colors.deepPurple, fontSize: 16),
                    hintText: 'Enter the word',
                    hintStyle: TextStyle(color: Colors.deepPurple[200]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.deepPurple),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.deepPurple, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a word';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  onChanged: (value) {
                    meaning = value;
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.deepPurple[50],
                    labelText: 'meaning',
                    labelStyle:
                        const TextStyle(color: Colors.deepPurple, fontSize: 16),
                    hintText: 'Enter the meaning',
                    hintStyle: TextStyle(color: Colors.deepPurple[200]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.deepPurple),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.deepPurple, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  onChanged: (value) {
                    type = value;
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.deepPurple[50],
                    labelText: 'Type',
                    labelStyle:
                        const TextStyle(color: Colors.deepPurple, fontSize: 16),
                    hintText: 'Enter the type',
                    hintStyle: TextStyle(color: Colors.deepPurple[200]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.deepPurple),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.deepPurple, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  onChanged: (value) {
                    description = value;
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.deepPurple[50],
                    labelText: 'Description',
                    labelStyle:
                        const TextStyle(color: Colors.deepPurple, fontSize: 16),
                    hintText: 'Enter the description',
                    hintStyle: TextStyle(color: Colors.deepPurple[200]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.deepPurple),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.deepPurple, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ExpansionTile(
                  title: const Text(
                    'Synonyms',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                      fontSize: 18,
                    ),
                  ),
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: _synonymControllers.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: TextFormField(
                            controller: _synonymControllers[index],
                            onChanged: (value) {
                              if (index < synonym.length) {
                                synonym[index] = value;
                              } else {
                                synonym.add(value);
                              }
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.deepPurple[50],
                              labelText: 'Synonym ${index + 1}',
                              labelStyle: const TextStyle(
                                  color: Colors.deepPurple, fontSize: 16),
                              hintText: 'Enter synonym ${index + 1}',
                              hintStyle:
                                  TextStyle(color: Colors.deepPurple[200]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.deepPurple),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.deepPurple, width: 2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          trailing: _synonymControllers.length > 1
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _synonymControllers.removeAt(index);
                                      synonym.removeAt(
                                          index); // Remove the corresponding synonym
                                    });
                                  },
                                )
                              : null,
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _synonymControllers.add(TextEditingController());
                          synonym.add('');
                        });
                      },
                      child: const Text(
                        'Add Synonym',
                        style: TextStyle(color: Colors.deepPurple),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      Vocabulary newWord = Vocabulary(
                          widget.bookName,
                          widget.unitName,
                          word!,
                          meaning!,
                          type!,
                          synonym,
                          description ?? '',
                          "Add your own description");

                      await dbHelper.insert(newWord.toMap(), "Vocabulary");

                      print(widget.unitName);
                      CourseManager wordLoader = CourseManager();
                      wordLoader.addWordToVocabulary(newWord);
                      wordLoader.setAllVocabularyOfSelectedUnit(
                          wordLoader.getCurrentUnit());

                      if (widget.onWordAdded != null) {
                        widget.onWordAdded!();
                      }

                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Add Word',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
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
