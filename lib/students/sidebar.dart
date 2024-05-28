import 'package:flutter/material.dart';
import 'package:test_me/database_helper.dart';
import 'package:test_me/students/examlist.dart';
import 'package:test_me/students/exammarks.dart';
import 'package:test_me/students/login.dart'; // Import your database helper

class StudentSidebar extends StatelessWidget {
  final int sid;
  final DatabaseHelper databaseHelper = DatabaseHelper();

  StudentSidebar({required this.sid});

  Future<String> _getStudentName() async {
    Map<String, dynamic> studentInfo = await databaseHelper.getStudentById(sid);
    return studentInfo['Sname'];
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<String>(
        future: _getStudentName(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Show loading indicator while fetching data
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          return ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Text(
                  snapshot.data ?? 'Student',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                decoration: BoxDecoration(
                  color: Colors.grey,
                ),
              ),
              ListTile(
                title: Text('Exam List'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentExamListPage(Sid: sid),
                    ),
                  );
                },
              ),
              ListTile(
                title: Text('Exam Marks'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExamsMarksPage(sid: sid),
                    ),
                  );
                },
              ),
              ListTile(
                title: Text('Logout'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => StudentLoginPage()),
                    (route) => false,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
