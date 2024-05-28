import 'package:flutter/material.dart';
import 'package:test_me/database_helper.dart';
import 'package:test_me/students/sidebar.dart';
import 'package:test_me/students/takeexam.dart';

class StudentExamListPage extends StatefulWidget {
  final int? Sid;

  StudentExamListPage({this.Sid});
  @override
  _StudentExamListPageState createState() => _StudentExamListPageState();
}

class _StudentExamListPageState extends State<StudentExamListPage> {
  late Future<List<Map<String, dynamic>>> _examsFuture;
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _examsFuture = _fetchExams();
  }

  Future<List<Map<String, dynamic>>> _fetchExams() async {
    List<Map<String, dynamic>> examsData =
        await _databaseHelper.getExamsForStudent();
    List<Map<String, dynamic>> examsWithTakenStatus = [];

    for (Map<String, dynamic> examData in examsData) {
      bool isExamTaken = await _databaseHelper.isExamTaken(
        widget.Sid,
        examData['Qid'],
      );
      examsWithTakenStatus.add({
        ...examData,
        'taken': isExamTaken ? 1 : 0,
      });
    }

    return examsWithTakenStatus;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => DatabaseHelper.onWillPop(context),
        child: Scaffold(
          appBar: AppBar(
            title: Text('Exam List'),
          ),
          drawer: StudentSidebar(
            sid: widget.Sid!,
          ),
          body: FutureBuilder<List<Map<String, dynamic>>>(
            future: _examsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No exams available'));
              } else {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> examData = snapshot.data![index];
                    return ListTile(
                      title: Text(examData['Qname']),
                      subtitle: Text(
                          'Date: ${examData['Qdate']}\nDuration: ${examData['Qtime']}'),
                      trailing: examData['taken'] == 1
                          ? Text('Already Taken',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 112, 112, 112),
                                  fontSize: 15))
                          : ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TakeExamPage(
                                      sid: widget.Sid,
                                      qid: examData['Qid'],
                                    ),
                                  ),
                                );
                              },
                              child: Text('Take Exam'),
                            ),
                    );
                  },
                );
              }
            },
          ),
        ));
  }
}
