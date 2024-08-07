import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_caht/DatabaseHelper.dart';
import 'package:flutter_application_caht/Screens/Course.dart';
import 'package:flutter_application_caht/Screens/LevelPreview.dart';
import 'package:flutter_application_caht/Screens/Unit.dart';
import 'package:flutter_application_caht/CourseManager.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:flutter_application_caht/Screens/Unit.dart' as unit;

Color customPainterRectColor = Colors.deepPurple.shade50;
Color customPainterCircleColor = Colors.deepPurple;
Color cardWidgetBackColor = Colors.deepPurple.shade100;
Color circleAvatarColor = Colors.deepPurple;
Color cardWidgetFontColor = Colors.deepPurple;
Color choosePageTitleColor = Colors.deepPurple.shade50;
Color progressBarPageColor = Colors.deepPurple;
Color progressBarBackPageColor = Colors.deepPurple.shade100;
Color progressBarTextPageColor = Colors.white;

class Choose extends StatefulWidget {
  static const String id = "choose";
  const Choose({super.key});

  @override
  State<Choose> createState() => _ChooseState();
}

class _ChooseState extends State<Choose> {
  final databaseHelper = DatabaseHelper();

  void HandleWords() async {
    Navigator.pushNamed(context, UnitsPage.id);
    CourseManager().action = unit.Action.Words;
  }

  void HandleMyWords() {
    CourseManager().setCurrentUnit("MyWords");
    CourseManager().setAllVocabularyOfSelectedUnit("MyWords");
    Navigator.pushNamed(context, LevelPrevieww.id);
  }

  void HandleVocabularyBank() {
    CourseManager().action = unit.Action.VocabularyBank;
    Navigator.pushNamed(context, UnitsPage.id);
  }

  void HandleTest() {
    Navigator.pushNamed(context, UnitsPage.id);
    CourseManager().action = unit.Action.Test;
  }

  int _selectedIndex = 1;
  final dbHelper = DatabaseHelper();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void _onItemTapped(int index) async {
    if (index == 0) {
      Navigator.pushReplacementNamed(context, Course.id);
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
        Navigator.pushNamed(
          context,
          Choose.id,
        );
      }
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  void setCourseProgress() async {
    await CourseManager().setCourseProgress();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
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
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: CircleRectanglePainter(
                    rectColor: customPainterRectColor,
                    circleColor: customPainterCircleColor,
                    heigh: 400,
                    widht: double.infinity,
                    left: 0,
                    top: 0),
                // Provides the painting area
              ),
            ),
            Positioned(
              top: 1.0,
              left: 10.0,
              child: Text(
                'American English File',
                style: TextStyle(
                  color:
                      choosePageTitleColor, // Changed to black for better visibility
                  fontSize: 27.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              top: 10.0,
              right: 20.0,
              child: CircularPercentIndicator(
                  radius: 45,
                  backgroundColor: progressBarBackPageColor,
                  percent: CourseManager().getCourseProgress() / 100,
                  animation: true,
                  animationDuration: 3000,
                  progressColor: progressBarPageColor,
                  lineWidth: 7,
                  circularStrokeCap: CircularStrokeCap.round,
                  center: Text(
                    "${CourseManager().getCourseProgress()} %",
                    style: TextStyle(
                        fontSize: 16, color: progressBarTextPageColor),
                  )),
            ),
            Positioned(
              bottom: 45.0,
              left: 30.0,
              right: 30.0,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Card2(
                        icon: Icons.book,
                        progress: 0,
                        cardName: "Book",
                        color: Colors.brown,
                        backGroudColor: Colors.brown.shade200,
                        circleAvatar: Colors.brown,
                      ),
                      Card2(
                        progress: CourseManager().getWordsProgress(),
                        icon: Icons.wordpress,
                        color: Colors.red,
                        circleAvatar: Colors.red,
                        backGroudColor: Colors.red.shade100,
                        cardName: "Words",
                        press: HandleWords,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Card2(
                        icon: Icons.book_outlined,
                        color: Colors.green,
                        circleAvatar: Colors.green,
                        cardName: "Vocabulary Bank",
                        progress: CourseManager().getVocabularyBankProgress(),
                        backGroudColor: Colors.green.shade200,
                        press: HandleVocabularyBank,
                      ),
                      Card2(
                        icon: Icons.book,
                        circleAvatar: Colors.blue,
                        color: Colors.blue,
                        progress: 0,
                        backGroudColor: Colors.blue.shade200,
                        cardName: "My words",
                        press: HandleMyWords,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Card2(
                        icon: Icons.quiz_outlined,
                        color: Colors.pink,
                        circleAvatar: Colors.pink,
                        progress: CourseManager().getTotalOfAllTestsProgress(),
                        backGroudColor: Colors.pink.shade200,
                        cardName: "Test",
                        press: HandleTest,
                      ),
                      Card2(
                        progress: 0,
                        icon: Icons.chat,
                        circleAvatar: Colors.orange,
                        color: Colors.orange,
                        backGroudColor: Colors.orange.shade200,
                        cardName: "Conversation",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class Card2 extends StatefulWidget {
  Card2(
      {super.key,
      required this.icon,
      required this.color,
      required this.cardName,
      required this.backGroudColor,
      required this.progress,
      required this.circleAvatar,
      this.press});
  Color color;
  IconData icon;
  String cardName;
  VoidCallback? press;
  Color backGroudColor;
  double progress;
  Color circleAvatar;

  @override
  State<Card2> createState() => _Card2State();
}

class _Card2State extends State<Card2> with SingleTickerProviderStateMixin {
  bool isTapped = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
    setState(() {
      isTapped = true;
    });
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
    setState(() {
      isTapped = false;
    });

    if (widget.press != null) {
      widget.press!();
    }
  }

  void _onTapCancel() {
    _animationController.reverse();
    setState(() {
      isTapped = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Material(
        elevation: isTapped ? 8.0 : 4.0,
        borderRadius: BorderRadius.circular(16.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          child: Container(
            padding: const EdgeInsets.all(7),
            width: 150.0,
            height: 150.0,
            decoration: BoxDecoration(
              border: Border.all(width: 0.1),
              color: isTapped ? Colors.grey.shade300 : widget.backGroudColor,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 3,
                  offset: const Offset(0, 2), // changes position of shadow
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30.0,
                  child: Icon(widget.icon),
                  backgroundColor: widget.circleAvatar,
                ),
                // Added icon with yellow color
                const SizedBox(height: 10.0),
                Text(
                  widget.cardName,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: cardWidgetFontColor, // Changed text color to black
                  ),
                ),
                const SizedBox(height: 10.0),
                Padding(
                  padding: const EdgeInsets.all(3),
                  child: FAProgressBar(
                    border: Border.all(color: Colors.black, width: 0.2),
                    size: 16,
                    currentValue: widget.progress,
                    animatedDuration: const Duration(seconds: 3),
                    displayText: " %",
                    backgroundColor: widget.backGroudColor,
                    progressColor: widget.color,
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

class CircleRectanglePainter extends CustomPainter {
  CircleRectanglePainter(
      {required this.heigh,
      required this.circleColor,
      required this.rectColor,
      required this.widht,
      required this.left,
      required this.top});

  double heigh = 2;
  double widht = 200;
  double top = 0;
  double left = 50;

  Color rectColor;
  Color circleColor;
  @override
  void paint(Canvas canvas, Size size) {
    // Define the rectangle
    Rect rect = Rect.fromLTWH(left, top, widht, heigh);

    // Define the circle
    Offset circleCenter = const Offset(120, -100);
    double circleRadius = 300;

    // Create a Paint object for the rectangle
    Paint rectPaint = Paint()
      ..color = rectColor
      ..style = PaintingStyle.fill;

    // Draw the rectangle
    canvas.drawRect(rect, rectPaint);

    // Save the canvas state before clipping
    canvas.save();

    // Clip to the rectangle
    canvas.clipRect(rect);

    // Create a Paint object for the circle
    Paint circlePaint = Paint()
      ..color = circleColor
      ..style = PaintingStyle.fill;

    // Draw the circle
    canvas.drawCircle(circleCenter, circleRadius, circlePaint);

    // Restore the canvas state
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
