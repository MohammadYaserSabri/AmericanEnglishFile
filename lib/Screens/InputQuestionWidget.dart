import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_caht/Presentation/Screens/StudyDashBoard.dart';
import 'package:flutter_application_caht/Screens/Question.dart';
import 'package:flutter_application_caht/Screens/Test.dart';

class InputQuestionWidget extends StatefulWidget {
  final Question question;

  InputQuestionWidget({required this.question});

  @override
  _InputQuestionWidgetState createState() => _InputQuestionWidgetState();
}

class _InputQuestionWidgetState extends State<InputQuestionWidget> {
  late List<TextEditingController> controllers;
  late InputQuestionModel questionModel;
  bool isCorrect = false;
  bool isAnswered = false;
  Color borderColor = Colors.grey;

  String ans = '';

  @override
  void initState() {
    super.initState();

    if (widget.question.model is InputQuestionModel) {
      questionModel = widget.question.model as InputQuestionModel;
      controllers = List.generate(15, (_) => TextEditingController());
    } else {
      throw Exception("Question model is not of type InputQuestionModel");
    }
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void clearAllInputs() {
    for (var controller in controllers) {
      controller.clear();
    }
    setState(() {
      borderColor = Colors.grey;
    });
  }

  void deleteLastInput() {
    for (int i = controllers.length - 1; i >= 0; i--) {
      if (controllers[i].text.isNotEmpty) {
        controllers[i].clear();
        FocusScope.of(context).previousFocus();
        break;
      }
    }
  }

  void checkAnswer() {
    String userAnswer = controllers.map((controller) => controller.text).join();
    setState(() {
      isAnswered = true;
      isCorrect = userAnswer == questionModel.correctAnswer;
      borderColor = isCorrect ? Colors.green : Colors.red;
    });
  }

  void revealCorrectAnswer() {
    setState(() {
      for (int i = 0; i < questionModel.correctAnswer.length; i++) {
        controllers[i].text = questionModel.correctAnswer[i];
      }
    });
  }

  void nextQuestion() {
    setState(() {
      if (isCorrect) {
        widget.question.increaseCorrectAnswers();
      }

      bool isThereAnyWordToTest = widget.question.next();
      if (!isThereAnyWordToTest) {
        showDialog(
          useSafeArea: true,
          context: context,
          builder: (BuildContext context) {
            return TestResultDialog(
              questionType: widget.question.getQuestionType(),
              correctAnswers: widget.question.getTotalOfCorrectedAnswers(),
              totalQuestions: widget.question.getNumberOfQuestions(),
            );
          },
        ).then((value) {
          if (value == 'Test Again') {
          } else if (value == 'Back to Home') {
            Navigator.pushNamed(context, StudyDashboard.id);
          }
          widget.question.reset();
        });
      } else {
        questionModel = widget.question.model as InputQuestionModel;
        controllers.forEach((controller) => controller.clear());
        isAnswered = false;
        isCorrect = false;
        borderColor = Colors.grey;
      }

      ans = questionModel.options.join();
    });
  }

  void revealNextLetter() {
    setState(() {
      String correctAnswer = questionModel.correctAnswer;
      for (int i = 0; i < correctAnswer.length; i++) {
        if (controllers[i].text.isEmpty) {
          controllers[i].text = correctAnswer[i];
          FocusScope.of(context).nextFocus();
          break;
        }
      }
    });
  }

  bool flag = false;
  void _onKeyEvent(KeyEvent event) {
    flag = !flag;
    if (event.logicalKey == LogicalKeyboardKey.backspace && flag) {
      deleteLastInput();
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: _onKeyEvent,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple[600],
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'Write a correct synonym for the word:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Center(
                    child: Text(
                      widget.question.model.question,
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple[800],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(questionModel.answerLength, (index) {
                    return Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                        border: Border.all(color: borderColor, width: 2),
                      ),
                      child: TextField(
                        controller: controllers[index],
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          counterText: '',
                        ),
                        maxLength: 1,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple[900],
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty &&
                              index < questionModel.answerLength - 1) {
                            FocusScope.of(context).nextFocus();
                          }
                        },
                      ),
                    );
                  }),
                ),
                SizedBox(height: 50),
                ElevatedButton(
                  onPressed: isAnswered ? nextQuestion : checkAnswer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAnswered
                        ? (isCorrect ? Colors.green : Colors.red)
                        : Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    isAnswered ? "Next" : "Submit",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 80,
            right: 20,
            child: FloatingActionButton(
              onPressed: isAnswered ? revealCorrectAnswer : revealNextLetter,
              tooltip: isAnswered ? 'Reveal Answer' : 'Hint',
              backgroundColor:
                  isAnswered ? Colors.red.shade200 : Colors.yellow.shade600,
              child: Icon(
                isAnswered ? Icons.visibility : Icons.lightbulb_outline,
                color: Colors.deepPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
