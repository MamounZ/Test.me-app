import 'package:flutter/material.dart';
import 'package:test_me/database_helper.dart';
import 'package:test_me/teachers/examlist.dart';
import 'package:test_me/teachers/login.dart';
import 'package:test_me/teachers/newexam.dart'; // Import your database helper

class TeacherSidebar extends StatelessWidget {
  final int? tid;
  final DatabaseHelper databaseHelper = DatabaseHelper();

  TeacherSidebar({required this.tid});

  Future<String> _getTeacherName() async {
    Map<String, dynamic> teacherInfo =
        await databaseHelper.getTeacherById(tid!);
    return teacherInfo['Tname'];
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<String>(
        future: _getTeacherName(),
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
                  snapshot.data ?? 'Teacher',
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
                      builder: (context) => TeacherExamListPage(teacherId: tid),
                    ),
                  );
                },
              ),
              ListTile(
                title: Text('New Exam'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewExamPage(teacherId: tid),
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
                    MaterialPageRoute(builder: (context) => TeacherLoginPage()),
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
