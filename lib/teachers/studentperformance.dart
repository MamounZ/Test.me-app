import 'package:flutter/material.dart';
import 'package:test_me/database_helper.dart';

class StudentPerformancePage extends StatefulWidget {
  final int qid;
  final String examName;

  const StudentPerformancePage({
    Key? key,
    required this.qid,
    required this.examName,
  }) : super(key: key);

  @override
  _StudentPerformancePageState createState() => _StudentPerformancePageState();
}

class _StudentPerformancePageState extends State<StudentPerformancePage> {
  late Future<List<Map<String, dynamic>>> studentPerformance;

  @override
  void initState() {
    super.initState();
    studentPerformance = DatabaseHelper().getStudentPerformance(widget.qid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Performance for the Exam: ${widget.examName}',
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: studentPerformance,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No students have taken this exam.'));
          } else {
            return Center(
              child: SingleChildScrollView(
                child: DataTable(
                  columns: [
                    DataColumn(label: Center(child: Text('Student ID'))),
                    DataColumn(label: Center(child: Text('Name'))),
                    DataColumn(label: Center(child: Text('Mark'))),
                  ],
                  rows: snapshot.data!.map((student) {
                    return DataRow(
                      cells: [
                        DataCell(
                            Center(child: Text(student['Sid'].toString()))),
                        DataCell(Center(child: Text(student['Sname']))),
                        DataCell(
                            Center(child: Text(student['Smark'].toString()))),
                      ],
                    );
                  }).toList(),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
