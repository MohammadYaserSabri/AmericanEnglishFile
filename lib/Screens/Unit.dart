import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:flutter_application_caht/Screens/Course.dart';
import 'package:flutter_application_caht/Screens/LevelPreview.dart';
import 'package:flutter_application_caht/Screens/Question.dart';
import 'package:flutter_application_caht/Screens/QuestionScreen.dart';
import 'package:flutter_application_caht/CourseManager.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:percent_indicator/percent_indicator.dart';

// Sample class representing a unit
class Unit {
  final String name;

  Unit(this.name);
}

class UnitsPage extends StatefulWidget {
  static const String id = "UnitPage";
  UnitsPage({super.key});
  UnitsPage.from();

  @override
  State<UnitsPage> createState() => _UnitsPageState();
}

class _UnitsPageState extends State<UnitsPage> {
  // Sample list of units
  List<Unit> unitsWordsCard = [];
  List<Unit> unitsVBCard = [];
  List<Unit> allUnits = [];

  void clear2() {
    allUnits.clear();
    unitsVBCard.clear();
    unitsWordsCard.clear();
  }

  @override
  void initState() {
    print(
        "ininijlfksjldjfsljflsjfjuljljlkjlk;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;s");
    super.initState();
    clear2();
    var unitsName3 = CourseManager().getAllUnitsNamesOFTheBook();

    for (var name in unitsName3) {
      var x = Unit(name);
      allUnits.add(x);
    }
    var unitsName = CourseManager().getUnitNamesOfTheWordsCardSection();

    for (var name in unitsName) {
      var x = Unit(name);
      unitsWordsCard.add(x);
    }

    var unitsName2 =
        CourseManager().getUnitNamesOfTheVocabularyBankCardSection();

    for (var name in unitsName2) {
      var x = Unit(name);
      unitsVBCard.add(x);
    }

    loadUnitsProgress();
  }

  void loadUnitsProgress() async {
    await wordLoader.loadUnitsProgress();
    setState(() {});
  }

  final wordLoader = CourseManager();
  @override
  Widget build(BuildContext context) {
    print(unitsVBCard.length);
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      appBar: AppBar(
        title: Text(
          'Units Page',
          style: TextStyle(color: Colors.deepPurple.shade50),
        ),
        backgroundColor: Colors.deepPurple, // Setting app bar color to red
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top section with an image
          Container(
            height: MediaQuery.of(context).size.height *
                0.4, // Adjust the height as needed
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'images/Suggest.png'), // Replace with your image path
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Bottom section with ListView of buttons
          Expanded(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: ListView.builder(
                itemCount: wordLoader.action == Action.Words
                    ? unitsWordsCard.length
                    : wordLoader.action == Action.Test
                        ? allUnits.length
                        : unitsVBCard.length,
                itemBuilder: (BuildContext context, int index) {
                  return wordLoader.action == Action.Words ||
                          wordLoader.action == Action.VocabularyBank
                      ? GestureDetector(
                          onTap: () {
                            CourseManager().setCurrentUnit(
                                wordLoader.action == Action.Words
                                    ? unitsWordsCard[index].name
                                    : unitsVBCard[index].name);
                            CourseManager().setAllVocabularyOfSelectedUnit(
                                wordLoader.action == Action.Words
                                    ? unitsWordsCard[index].name
                                    : unitsVBCard[index].name);

                            Navigator.pushReplacementNamed(
                              context,
                              LevelPrevieww.id,
                            );

                            // Print("in push name is unit is : $unitName");
                          },
                          child: GestureCard(
                            unitProgress: wordLoader
                                        .unitCardSectionProgressIsNotEmpty() &&
                                    wordLoader
                                            .getUnitProgressOfCardSectionInOrder(
                                                index) >
                                        0
                                ? double.parse(wordLoader
                                    .getUnitProgressOfCardSectionInOrder(index)
                                    .toString())
                                : 0,
                            unitName: wordLoader.action == Action.Words
                                ? unitsWordsCard[index].name
                                : unitsVBCard[index].name,
                            action: CourseManager().action,
                          ))
                      : GestureCard(
                          unitProgress: 0,
                          unitName: allUnits[index].name,
                          action: CourseManager().action,
                          onPressed: () {},
                        );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum Action { Words, Test, VocabularyBank }

class GestureCard extends StatefulWidget {
  GestureCard({
    Key? key,
    required this.unitName,
    this.onPressed,
    this.arguments,
    required this.unitProgress,
    required this.action,
  }) : super(key: key);

  final String unitName;
  final VoidCallback? onPressed;
  final Object? arguments;
  final Action action;
  double unitProgress = 0;
  @override
  _GestureCardState createState() => _GestureCardState();
}

class _GestureCardState extends State<GestureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  List<String> testButtonNames = ["Test1", "Test2", "Test3", "Test4", "Test5"];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
    // load();
  }

  load() async {
    await CourseManager()
        .loadTestProgressOfUnit(CourseManager().getCurrentUnit());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: ScaleTransition(
        scale: _animation,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient:  LinearGradient(
              colors: [
                Colors.deepPurple.shade100,
                Colors.deepPurple.shade200
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 3,
                blurRadius: 7,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: widget.action == Action.Test
              ? ExpansionTile(
                  onExpansionChanged: (value) async {
                    print("before");

                    print("after");

                    CourseManager().setCurrentUnit(widget.unitName);
                    CourseManager()
                        .setAllVocabularyOfSelectedUnit(widget.unitName);

                    await CourseManager().loadTestProgressOfUnit(
                        CourseManager().getCurrentUnit());

                    setState(() {});
                  },
                  title: Text(
                    widget.unitName,
                    style:  TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  iconColor: Colors.white,
                  textColor: Colors.deepPurple,
                  backgroundColor: Colors.transparent,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(5, (index) {
                            return TestButton(
                              testProgress:
                                  CourseManager().TestProgressIsNotEmpty()
                                      ? CourseManager()
                                          .getTestProgressOfCurrentUnitInOrder(
                                              index)
                                      : 0,
                              name: testButtonNames[index],
                              testLevel: TestLevel.values[index],
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                      Expanded(
                        child: Text(
                          widget.unitName,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (widget.unitProgress > 0)
                        Expanded(
                            child: FAProgressBar(
                          backgroundColor:
                              const Color.fromARGB(255, 255, 251, 245),
                          progressColor: Colors.deepPurple.shade300,
                          displayText: "%",
                          size: 14,
                          displayTextStyle: TextStyle(
                              color:Colors.deepPurple.shade50,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                          maxValue: 100,
                          currentValue: widget.unitProgress,
                        ))
                    ]),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class TestButton extends StatefulWidget {
  TestButton(
      {Key? key,
      required this.testLevel,
      required this.name,
      required this.testProgress})
      : super(key: key);

  final TestLevel testLevel;
  String name;
  int testProgress = 0;
  @override
  _TestButtonState createState() => _TestButtonState();
}

class _TestButtonState extends State<TestButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();

    print(" test progress is : ${widget.testProgress}");
  }

  Color setBackColorOfTestProgress(int value) {
    if (value > 80) {
      return Color.fromARGB(255, 108, 255, 9);
    } else if (value > 60) {
      return Color.fromARGB(255, 199, 243, 39);
    } else if (value > 30) {
      return Color.fromARGB(255, 255, 121, 112);
    } else {
      return Color.fromARGB(255, 255, 55, 41);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(-1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        )),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 5),
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(2, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.testProgress > 0)
                Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF066909),
                          offset: Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: CircularPercentIndicator(
                      radius: 24,
                      backgroundColor: Colors.green,
                      percent: widget.testProgress / 100,
                      animation: true,
                      animationDuration: 3000,
                      progressColor: Colors.greenAccent,
                      lineWidth: 7,
                      circularStrokeCap: CircularStrokeCap.round,
                      center: Text(
                        "${widget.testProgress} %",
                        style: TextStyle(
                            fontSize: 11,
                            color: setBackColorOfTestProgress(
                                widget.testProgress)),
                      ),
                    )),
              SizedBox(width: 5),
              GestureDetector(
                onTap: () {
                  CourseManager().setTestLevel(widget.testLevel);
                  showDialog(
                    context: context,
                    builder: (context) {
                      return QuestionSelector();
                    },
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    widget.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class QuestionSelector extends StatelessWidget {
  static const String id = "QuestionSelector";

  bool isInputTestMethodIsValidForThisTest(TestLevel testLevel) {
    if (testLevel == TestLevel.Second) {
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    TestLevel testLevel = CourseManager().getTestLevel();
    return AlertDialog(
      content: Text("What kind of test do you prefer ?"),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Test method"),
          GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                  child: Icon(
                Icons.cancel,
                color: Colors.red,
              )))
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //  if (isInputTestMethodIsValidForThisTest(testLevel))
            GestureDetector(
              onTap: () {
                print("tapped input");

                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                  return QuestionScreen(questionType: QuestionType.Input);
                }));
              },
              child: Container(
                padding: EdgeInsets.all(10),
                color: Colors.blue,
                child: Text(" Input type"),
              ),
            ),
            GestureDetector(
                onTap: () {
                  print("tapped in muliple ");

                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) {
                    return QuestionScreen(
                        questionType: QuestionType.MultipleChoice);
                  }));
                },
                child: Container(
                  padding: EdgeInsets.all(10),
                  color: Color.fromARGB(255, 41, 248, 41),
                  child: Text(" Multiple choose"),
                ))
          ],
        )
      ],
    );
  }
}
