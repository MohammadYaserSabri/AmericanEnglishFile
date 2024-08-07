import 'package:flutter/material.dart';
import 'package:flutter_application_caht/Screens/InputQuestionWidget.dart';
import 'package:flutter_application_caht/Screens/MultipleQuestionWidget.dart';
import 'package:flutter_application_caht/Screens/Question.dart';
import 'package:flutter_application_caht/CourseManager.dart';

class QuestionScreen extends StatelessWidget {
  QuestionScreen.from();
  QuestionType questionType = QuestionType.MultipleChoice;
  static const String id = "QuestionScreen";
  QuestionScreen({required this.questionType});



  @override
  Widget build(BuildContext context) {
    Question question = Question();
    question.initialize(questionType, CourseManager().getTestLevel());

    question.generateQuestions();
    print(" question type is :${questionType} ");
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,

        title: Text('Question Screen', style: TextStyle(color: Colors.deepPurple.shade50),),
      ),
      body: Container(
        child: questionType == QuestionType.Input
            ? InputQuestionWidget(
                question: question,
              )
            : MultipleChoiceQuestionWidget(
                question: question,
              ),
      ),
    );
  }
}
