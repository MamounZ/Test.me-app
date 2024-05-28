import 'package:flutter/material.dart';
import 'package:test_me/database_helper.dart';
import 'package:test_me/students/sidebar.dart';

class ExamsMarksPage extends StatefulWidget {
  final int sid;

  const ExamsMarksPage({Key? key, required this.sid}) : super(key: key);

  @override
  _ExamsMarksPageState createState() => _ExamsMarksPageState();
}

class _ExamsMarksPageState extends State<ExamsMarksPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  late Future<List<Map<String, dynamic>>> _examsFuture;

  @override
  void initState() {
    super.initState();
    _examsFuture = _fetchExams();
  }

  Future<List<Map<String, dynamic>>> _fetchExams() async {
    return await _databaseHelper.getStudentExamsWithMarksAndTeacher(widget.sid);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => DatabaseHelper.onWillPop(context),
        child: Scaffold(
          appBar: AppBar(
            title: Text('Exam Marks'),
          ),
          drawer: StudentSidebar(
            sid: widget.sid,
          ),
          body: FutureBuilder<List<Map<String, dynamic>>>(
            future: _examsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No exams found.'));
              } else {
                final exams = snapshot.data!;
                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: DataTable(
                        columnSpacing: 50.0,
                        horizontalMargin: 10.0,
                        dataRowHeight: 70.0,
                        headingRowHeight: 70.0,
                        border: TableBorder(
                          horizontalInside: BorderSide.none,
                          verticalInside: BorderSide.none,
                        ),
                        columns: [
                          DataColumn(label: Center(child: Text('Exam'))),
                          DataColumn(label: Center(child: Text('Teacher'))),
                          DataColumn(label: Center(child: Text('Mark'))),
                        ],
                        rows: exams.map((exam) {
                          return DataRow(
                            cells: [
                              DataCell(Center(child: Text(exam['Qname']))),
                              DataCell(Center(child: Text(exam['Tname']))),
                              DataCell(Center(
                                  child: Text(exam['Smark'].toString()))),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ));
  }
}
