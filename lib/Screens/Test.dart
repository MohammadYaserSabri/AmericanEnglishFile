import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_caht/Presentation/DatabaseHelper.dart';
import 'package:flutter_application_caht/Presentation/Screens/StudyDashBoard.dart';
import 'package:flutter_application_caht/Screens/Question.dart';
import 'package:flutter_application_caht/Screens/QuestionScreen.dart';
import 'package:flutter_application_caht/Presentation/CourseManager.dart';

class AnimatedButton extends StatefulWidget {
  final bool isSelected;
  final bool isCorrect;
  final String option;
  final VoidCallback? onTap;

  AnimatedButton({
    required this.isSelected,
    required this.isCorrect,
    required this.option,
    required this.onTap,
  });

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  widget.option,
                  textAlign: TextAlign.justify,
                  maxLines: 7, // You can adjust the max lines
                  overflow: TextOverflow.ellipsis, // Handles overflow
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.isSelected
                        ? widget.isCorrect
                            ? Colors.green
                            : Colors.red
                        : Colors.black,
                  ),
                ),
              ),
              if (widget.isSelected)
                Icon(widget.isCorrect ? Icons.check_circle : Icons.cancel,
                    color: widget.isCorrect ? Colors.green : Colors.red)
            ],
          ),
        ));
  }
}

class TestResultDialog extends StatelessWidget {
  final int correctAnswers;
  final int totalQuestions;
  QuestionType questionType;
  TestResultDialog({
    required this.questionType,
    required this.correctAnswers,
    required this.totalQuestions,
  });

  String _getMessage() {
    if (correctAnswers == 0) {
      return 'No correct answers. Keep practicing!';
    } else if (correctAnswers == totalQuestions) {
      return 'Excellent! You got all the answers correct!';
    } else if (correctAnswers > totalQuestions / 2) {
      return 'Good job! You answered more than half of the questions correctly.';
    } else {
      return 'Nice try! You answered some questions correctly. Keep practicing!';
    }
  }

  IconData _getIcon() {
    if (correctAnswers == 0) {
      return Icons.sentiment_dissatisfied;
    } else if (correctAnswers == totalQuestions) {
      return Icons.sentiment_very_satisfied;
    } else if (correctAnswers > totalQuestions / 2) {
      return Icons.sentiment_satisfied;
    } else {
      return Icons.sentiment_neutral;
    }
  }

  Color _getIconColor() {
    if (correctAnswers == 0) {
      return Colors.red;
    } else if (correctAnswers == totalQuestions) {
      return Colors.green;
    } else if (correctAnswers > totalQuestions / 2) {
      return Colors.blue;
    } else {
      return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: Row(
        children: [
          Icon(
            _getIcon(),
            color: _getIconColor(),
            size: 40,
          ),
          SizedBox(width: 10),
          Text(
            'Test Result',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Correct Answers: $correctAnswers / $totalQuestions',
              style: TextStyle(
                fontSize: 18,
                color: Colors.blue.shade900,
              ),
            ),
            SizedBox(height: 10),
            Text(
              _getMessage(),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(5),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                  onPressed: () {
                    // Navigate to the question screen again
                    Navigator.pop(context, 'Test Again');
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuestionScreen(
                          questionType: questionType, // or other type
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.refresh),
                  label: Text(
                    'Test Again',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(5),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                  onPressed: () async {
                    // Navigate back to the home screen
                    Navigator.pop(context, 'Back to Home');
                    // Calculate the test progress as a percentage
                    double progress = (correctAnswers * 100) / totalQuestions;

// Convert the progress to an integer, rounding to the nearest whole number
                    int progressInt = progress.round();

// Update the test progress in the database
                    await DatabaseHelper().updateTestProgress(progressInt);
                    Navigator.pushNamed(context, StudyDashboard.id);

                    await CourseManager().loadTestProgressOfUnit(
                        CourseManager().getCurrentUnit());
                  },
                  icon: Icon(Icons.home),
                  label: Text(
                    'Back to Home',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
