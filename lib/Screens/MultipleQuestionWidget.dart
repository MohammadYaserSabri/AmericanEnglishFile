// ignore_for_file: unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:flutter_application_caht/Presentation/Screens/StudyDashBoard.dart';
import 'package:flutter_application_caht/Screens/Question.dart';
import 'package:flutter_application_caht/Screens/Test.dart';

class MultipleChoiceQuestionWidget extends StatefulWidget {
  MultipleChoiceQuestionWidget({required this.question});

  final Question question;

  @override
  State<MultipleChoiceQuestionWidget> createState() =>
      _MultipleChoiceQuestionWidgetState();
}

class _MultipleChoiceQuestionWidgetState
    extends State<MultipleChoiceQuestionWidget> {
  String? selectedAnswer;
  bool isPressed = false;
  bool isCorrected = false;
  late MultipleChoiceQuestionModel questionModel;

  void handleTap(String option) {
    setState(() {
      selectedAnswer = option;
      isPressed = true;
      isCorrected = option == questionModel.correctAnswer ||
          questionModel.allAvailableCorrectAnswers.contains(option);

      if (questionModel.allAvailableCorrectAnswers.contains(option)) {
        print("it has");
      } else {
        print("it do not have because $option  was not in the answer list : ");
        for (var a in questionModel.allAvailableCorrectAnswers) {
          print(" elements : $a");
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    questionModel = widget.question.model as MultipleChoiceQuestionModel;
  }

  void nextQuestion() {
    setState(() {
      if (isCorrected) {
        widget.question.increaseCorrectAnswers();
      }
      if (!widget.question.next()) {
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
        questionModel = widget.question.model as MultipleChoiceQuestionModel;
        selectedAnswer = null;
        isPressed = false;
        isCorrected = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade300, Colors.deepPurple.shade900],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(4, 4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Select the correct synonym for this word:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  questionModel.question,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: questionModel.options.map((option) {
                  bool isCorrect = option == questionModel.correctAnswer ||
                      questionModel.allAvailableCorrectAnswers.contains(option);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: AnimatedButton(
                      isSelected: isPressed,
                      isCorrect: isCorrect,
                      option: option,
                      onTap: selectedAnswer == null
                          ? () => handleTap(option)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          if (selectedAnswer != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  textStyle: TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  shadowColor: Colors.black,
                  elevation: 10,
                ),
                onPressed: nextQuestion,
                child: Text('Next Question'),
              ),
            ),
        ],
      ),
    );
  }
}
