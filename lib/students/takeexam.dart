import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as Path;
import 'package:sqflite/sqflite.dart';
import 'package:test_me/database_helper.dart';
import 'package:test_me/students/examlist.dart';

class Question {
  final int id;
  final String text;
  final String correctAnswer;
  final int mark;
  final bool isMultipleChoice;
  String? firstOption;
  final String? secondOption;
  final String? thirdOption;
  final String? fourthOption;

  Question({
    required this.id,
    required this.text,
    required this.correctAnswer,
    required this.mark,
    required this.isMultipleChoice,
    this.firstOption,
    this.secondOption,
    this.thirdOption,
    this.fourthOption,
  });
}

class TakeExamPage extends StatefulWidget {
  final int? sid;
  final int qid;

  const TakeExamPage({Key? key, required this.sid, required this.qid})
      : super(key: key);

  @override
  _TakeExamPageState createState() => _TakeExamPageState();
}

class _TakeExamPageState extends State<TakeExamPage> {
  late List<Question> questions = [];
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  int remainingTime = 0;
  Map<int, String> studentAnswers = {}; // Map to store student answers
  late Timer timer;

  @override
  void initState() {
    super.initState();
    fetchQuestionsAndDuration();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Future<void> fetchQuestionsAndDuration() async {
    Database database = await openDatabase(
      Path.join(await getDatabasesPath(), 'teachers_database.db'),
    );

    // Fetch exam duration
    int examDuration = await _databaseHelper.getExamDuration(widget.qid);

    final List<Map<String, dynamic>> questionsData = await database
        .query('Question', where: 'Qid = ?', whereArgs: [widget.qid]);

    setState(() {
      questions = questionsData.map((questionMap) {
        return Question(
          id: questionMap['Quid'],
          text: questionMap['Qutext'],
          correctAnswer: questionMap['Qurightanswer'],
          mark: questionMap['Qumark'],
          isMultipleChoice: questionMap['Qutype'] == 'Multible Choise',
          firstOption: questionMap['firstop'],
          secondOption: questionMap['secondop'],
          thirdOption: questionMap['thirdop'],
          fourthOption: questionMap['fourthop'],
        );
      }).toList();

      startTimer(examDuration);
    });
  }

  void startTimer(int examDuration) {
    remainingTime = examDuration * 60; // Convert duration to seconds
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime > 0) {
          remainingTime--;
        } else {
          timer.cancel();
          submitExam();
        }
      });
    });
  }

  void submitExam() async {
    int totalMark = 0;

    for (Question question in questions) {
      String studentAnswer = studentAnswers[question.id] ?? '';
      bool isCorrect = studentAnswer == question.correctAnswer;
      String answerState = isCorrect ? 'right' : 'wrong';

      // Store student's answer and its state in Student_Question table
      await _databaseHelper.insertStudentQuestion2(
        widget.sid,
        question.id,
        studentAnswer,
        answerState,
      );

      // If the answer is correct, add its mark to the total mark
      if (isCorrect) {
        totalMark += question.mark;
      }
    }

    // Store the student's mark in the Student_Quiz table
    await _databaseHelper.insertStudentQuiz2(widget.sid, widget.qid, totalMark);

    // Show success message and navigate back to the exam list page
    if (!mounted) return; // Check if the widget is still mounted
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Success'),
        content: Text('The exam has been submitted successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentExamListPage(Sid: widget.sid),
                ),
              );
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Submit Exam'),
            content: Text(
                'Are you sure you want to leave? The exam will be submitted if you proceed.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                  submitExam();
                },
                child: Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Take Exam'),
              Text(
                '${(remainingTime ~/ 60).toString().padLeft(2, '0')}:${(remainingTime % 60).toString().padLeft(2, '0')}',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
        body: ListView.builder(
          itemCount: questions.length,
          itemBuilder: (context, index) {
            final question = questions[index];
            return Card(
              margin: EdgeInsets.all(8.0),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question.text,
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.0),
                    if (question.firstOption != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RadioListTile<String>(
                            title: Text(question.firstOption!),
                            value: question.firstOption!,
                            groupValue: studentAnswers[question.id],
                            onChanged: (value) {
                              setState(() {
                                studentAnswers[question.id] = value!;
                              });
                            },
                          ),
                          RadioListTile<String>(
                            title: Text(question.secondOption!),
                            value: question.secondOption!,
                            groupValue: studentAnswers[question.id],
                            onChanged: (value) {
                              setState(() {
                                studentAnswers[question.id] = value!;
                              });
                            },
                          ),
                          RadioListTile<String>(
                            title: Text(question.thirdOption!),
                            value: question.thirdOption!,
                            groupValue: studentAnswers[question.id],
                            onChanged: (value) {
                              setState(() {
                                studentAnswers[question.id] = value!;
                              });
                            },
                          ),
                          RadioListTile<String>(
                            title: Text(question.fourthOption!),
                            value: question.fourthOption!,
                            groupValue: studentAnswers[question.id],
                            onChanged: (value) {
                              setState(() {
                                studentAnswers[question.id] = value!;
                              });
                            },
                          ),
                        ],
                      )
                    else
                      TextFormField(
                        onChanged: (value) {
                          setState(() {
                            studentAnswers[question.id] = value;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Enter your answer',
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: submitExam,
          child: Icon(Icons.check),
        ),
      ),
    );
  }
}
