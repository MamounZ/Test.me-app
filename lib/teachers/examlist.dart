import 'package:flutter/material.dart';
import 'package:test_me/database_helper.dart'; // Import the DatabaseHelper class
import 'addquestion.dart'; // Import the AddQuestionPage
import 'studentperformance.dart'; // Import the StudentPerformancePage
import 'package:test_me/teachers/sidebar.dart';

class TeacherExamListPage extends StatefulWidget {
  final int? teacherId;

  const TeacherExamListPage({required this.teacherId});

  @override
  _ExamListPageState createState() => _ExamListPageState();
}

class _ExamListPageState extends State<TeacherExamListPage> {
  late Future<List<Map<String, dynamic>>> _exams;

  @override
  void initState() {
    super.initState();
    _exams = DatabaseHelper().getExamsByTeacherId(widget.teacherId);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => DatabaseHelper.onWillPop(context),
        child: Scaffold(
          appBar: AppBar(
            title: Text('Exam List'),
          ),
          drawer: TeacherSidebar(
            tid: widget.teacherId,
          ),
          body: FutureBuilder<List<Map<String, dynamic>>>(
            future: _exams,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                final exams = snapshot.data!;
                return ListView.builder(
                  itemCount: exams.length,
                  itemBuilder: (context, index) {
                    final exam = exams[index];
                    return ListTile(
                      title: Text(exam['Qname']),
                      subtitle: Text('Date: ${exam['Qdate']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              // Navigate to AddQuestionPage
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddQuestionPage(
                                      Qid: exam['Qid'],
                                      teacherId: widget.teacherId),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.bar_chart),
                            onPressed: () {
                              // Navigate to StudentPerformancePage
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StudentPerformancePage(
                                      qid: exam['Qid'],
                                      examName: exam['Qname']),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              // Implement delete functionality here
                              _deleteExam(exam['Qid']);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
            },
          ),
        ));
  }

  // Function to delete exam
  void _deleteExam(int examId) async {
    // Implement delete functionality
    int result = await DatabaseHelper().deleteExam(examId);
    if (result != 0) {
      // Exam deleted successfully, also delete related questions
      await DatabaseHelper().deleteQuestionsByExamId(examId);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Exam deleted successfully')));
      setState(() {
        // Reload the exam list
        _exams = DatabaseHelper().getExamsByTeacherId(widget.teacherId);
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to delete exam')));
    }
  }
}
