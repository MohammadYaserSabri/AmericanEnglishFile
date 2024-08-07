import 'dart:math';

import 'package:flutter/animation.dart';
import 'package:flutter_application_caht/Vocabulary.dart';
import 'package:flutter_application_caht/CourseManager.dart';

List<String> _words = [];
List<String> _synonyms = [];
List<String> _descriptions = [];
List<Vocabulary> _vocabulary = [];

class Question {
  int _correctAnswers = 0;
  static final Question _intance = Question._Internal();

  factory Question() {
    return _intance;
  }

  Question._Internal() {
    _wordLoader = CourseManager();
  }

  void initialize(QuestionType questionType, TestLevel testLevel) {
    _correctAnswers = 0;
    _questionLevel = testLevel;
    _questionType = questionType;
    _numberOfTheQuestions = _wordLoader.countNumberOfTheWordsInCurrentUnit();
    _initializeModel(_questionType);
  }

  // we need to load all word, description and neccessay data using this class
  late CourseManager _wordLoader;
  // all question based on the words included in each season
  int _numberOfTheQuestions = 0;
  int _nextQuestion = 0;
  // is our test is multiple choise or input type
  late QuestionType _questionType;
  // we need this variable for our test levels : for example in test one we test user by word and synonym ,  in second test with word and description and so on .
  late TestLevel _questionLevel;
  // based on test level we generate all question list and  pass them to our field model by calling method next();
  List<QuestionModel> _questionList = [];
  // with this variable other classes can acces to our question data .
  late QuestionModel model;

  int getNumberOfQuestions() {
    return _numberOfTheQuestions;
  }

  QuestionType getQuestionType() {
    return _questionType;
  }

  void _initializeModel(QuestionType modelType) {
    if (modelType == QuestionType.Input) {
      model = InputQuestionModel();
    } else {
      model = MultipleChoiceQuestionModel();
    }
  }

// when we are going to go to next question
  bool next() {
    /*   print(_questionList.length);
    print("next quesion number is : $_nextQuestion"); */
    if (_nextQuestion >= _questionList.length) return false;

    model = _questionList[_nextQuestion];
    _nextQuestion++;
    return true;
  }

// this method must be call in the generate level question , otherwise the app will crash
  void _start() {
    if (_nextQuestion >= _questionList.length) return;

    model = _questionList[_nextQuestion];
    _nextQuestion++;
  }

// it will restart the question s.  useful for test again
  void reset() {
    _nextQuestion = 0;
    _correctAnswers = 0;
  }

  int getTotalOfCorrectedAnswers() {
    return _correctAnswers;
  }

  void increaseCorrectAnswers() {
    print("answers is correct for increase");

    _correctAnswers++;
  }

  void generateQuestions() {
    _words = _wordLoader.getAllWordsOfCurrentUnit();
    _synonyms = _wordLoader.getAllSynonymsOfCurrentUnit();
    _descriptions = _wordLoader.getAllDescriptionOfCurrentUnit();
    _vocabulary = _wordLoader.getAllVocabularyOfCurrentUnit();
    _vocabulary.shuffle();
    print("teset level is ${_questionLevel}");
    switch (_questionLevel) {
      case TestLevel.First:
        _generateLevelQuestion(Options.Synonym, (vocab) => vocab.getWord(),
            (vocab) => vocab.getSingleSynonymBasedOnExam());
        break;
      case TestLevel.Second:
        _generateLevelQuestion(Options.Desciption, (vocab) => vocab.getWord(),
            (vocab) => vocab.getDescription());
        break;
      case TestLevel.Third:
        _generateLevelQuestion(Options.Synonym,
            (vocab) => vocab.getDescription(), (vocab) => vocab.getWord());
        break;
      case TestLevel.Fourth:
        _generateLevelQuestion(
            Options.Synonym,
            (vocab) => vocab.getSingleSynonymBasedOnExam(),
            (vocab) => vocab.getSingleSynonymBasedOnExam());
        break;
      case TestLevel.Fiveth:
        _generateLevelQuestion(
            Options.Word,
            (vocab) => vocab.getSingleSynonymBasedOnExam(),
            (vocab) => vocab.getWord());
        break;

      default:
        break;
    }
  }

  MultipleChoiceQuestionModel _createMultipleChoiceQuestionModel(
      String question, String answer, Options optionType, Vocabulary vocab) {
    MultipleChoiceQuestionModel multipleChoiceQuestionModel =
        MultipleChoiceQuestionModel();

    // print("in here");
    multipleChoiceQuestionModel.correctAnswer = answer;
    multipleChoiceQuestionModel.question = question;
    multipleChoiceQuestionModel.allAvailableCorrectAnswers = [
      vocab.getWord(),
    ];

    for (var a in vocab.getMultipleSynonymBasedOnExam()) {
      multipleChoiceQuestionModel.allAvailableCorrectAnswers.add(a);
    }
    // print("vefore option");
    multipleChoiceQuestionModel.options =
        _generateOptionsBasedOnMultipleChoiceModel(answer, optionType);
    //print("after option");
    return multipleChoiceQuestionModel;
  }

  InputQuestionModel _createInputChoiceQuestionModel(
      String question, String answer, Options optionType, Vocabulary vocab) {
    InputQuestionModel inputQuestionModel = InputQuestionModel();

    inputQuestionModel.question = question;
    inputQuestionModel.correctAnswer = answer;
    inputQuestionModel.answerLength = answer.length;
    inputQuestionModel.options =
        _generateOptionsBasedOnInputModel(answer, optionType, vocab);

    return inputQuestionModel;
  }

  void _generateLevelQuestion(
      Options optionType,
      String Function(Vocabulary) questionSelector,
      String Function(Vocabulary) answerSelector) {
    List<QuestionModel> questions = [];

    // print("number of quesois again : $_numberOfTheQuestions");
    // print("vocab lenght is :${_vocabulary.length}");
    for (int x = 0; x < _numberOfTheQuestions; x++) {
      Vocabulary vocab = _vocabulary[x];
      String question = questionSelector(vocab);
      String answer = answerSelector(vocab);
      //    print("single aagin : $answer");
      //   print("model is :${this.model}");
      if (model is MultipleChoiceQuestionModel) {
        //     print("before in if");
        MultipleChoiceQuestionModel questionModel =
            _createMultipleChoiceQuestionModel(
                question, answer, optionType, vocab);
        //     print("in if");
        questions.add(questionModel);
      } else if (model is InputQuestionModel) {
        InputQuestionModel questionModel = _createInputChoiceQuestionModel(
            question, answer, optionType, vocab);
        questions.add(questionModel);
        // print("else");
      }
      //  print("in loop");
    }
    //  print("in assign");
    this._questionList = questions;
    //  print("quewton list is : ${_questionList.length}");
    //  print("start");
    // this method will setup of first model variable question .   if we ommit this the app will crash
    _start();
  }

  /// this input model does not support description input.
  List<String> _generateOptionsBasedOnInputModel(
      String correctAnswer, Options optionType, Vocabulary vocabulary) {
    List<String> options = [];
    // in here when the question is Nice so all synonyms are the answers for input . because user can change them (later update).  but in multiple one answer we need .  in this it is vice versa
    switch (optionType) {
      case Options.Synonym:
        options = vocabulary.getMultipleSynonymBasedOnExam();
        break;
      //  in here when question is a synonym so the answers are word and the synoyms as i mention them in below
      case Options.Word:
        options = vocabulary.getMultipleSynonymBasedOnExam();
        options.add(correctAnswer);

        break;

      default:
        break;
    }

    options.shuffle();

    return options;
  }
}

List<String> _generateOptionsBasedOnMultipleChoiceModel(
    String correctAnswer, Options optionType) {
  List<String> options = [];
  Random random = Random();

  List<String> sourceList;
  switch (optionType) {
    case Options.Synonym:
      sourceList = _synonyms;
      break;
    case Options.Desciption:
      sourceList = _descriptions;
      break;
    case Options.Word:
      sourceList = _words;
      break;
    default:
      sourceList = [];
      break;
  }
  // print("before if ");
  // print(sourceList.length);
  if (sourceList.isNotEmpty) {
    List<String> selectedOptions = [];
    // Ensure the correct answer is added
    selectedOptions.add(correctAnswer);

    // Pick random elements from the source list
    while (selectedOptions.length < 4) {
      // Let's assume we need 4 options
      String randomOption = sourceList[random.nextInt(sourceList.length)];

      // print("in while");
      selectedOptions.add(randomOption);
      // print("selected length : ${selectedOptions.length}");
    }
    //  print("after that option length : ${options.length}");
    options = selectedOptions.toList();
    options.shuffle();
    //  print("now suffle");
  }
  // print("before return lenth : ${options.length}");
  return options;
}

abstract class QuestionModel {
  String question = "lkjljljljljlj";
  List<String> options = [];
  String correctAnswer = "";
  bool isAvailable = false;
}

class InputQuestionModel extends QuestionModel {
  InputQuestionModel();

  int answerLength = 0;

  void setCorrectAnswer(String answer) {
    correctAnswer = answer;
    answerLength = correctAnswer.length;
  }
}

class MultipleChoiceQuestionModel extends QuestionModel {
  MultipleChoiceQuestionModel();
  List<String> allAvailableCorrectAnswers = [];
}

enum QuestionType {
  Input,
  MultipleChoice,
}

enum TestLevel { First, Second, Third, Fourth, Fiveth, sixth }

enum Options { Word, Synonym, Desciption, WordAndSynonym }
