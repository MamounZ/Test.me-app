import 'package:flutter/material.dart';
import 'package:test_me/students/exammarks.dart';
import 'package:test_me/teachers/addquestion.dart';
import 'package:test_me/teachers/login.dart';
import 'package:test_me/teachers/register.dart';
import 'package:test_me/students/login.dart';
import 'package:test_me/students/register.dart';
import 'package:test_me/teachers/examlist.dart';
import 'package:test_me/students/examlist.dart';
import 'package:test_me/teachers/newexam.dart';
import 'package:test_me/students/takeexam.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Set the initial route to the teacher login page
      initialRoute: '/teacher_login',
      routes: {
        // Define the route for the teacher login page
        '/teacher_login': (context) => TeacherLoginPage(),
        '/teacher_register': (context) => TeacherRegisterPage(),
        '/student_login': (context) => StudentLoginPage(),
        '/student_register': (context) => StudentRegisterPage(),
        '/teacher_examlist': (context) => TeacherExamListPage(teacherId: 0),
        '/student_examlist': (context) => StudentExamListPage(),
        '/newexam': (context) => NewExamPage(),
        '/addquestion': (context) => AddQuestionPage(Qid: 0, teacherId: 0),
        '/takeexam': (context) => TakeExamPage(
              sid: 0,
              qid: 0,
            ),
        '/student_exammarkslist': (context) => ExamsMarksPage(
              sid: 0,
            ),
      },
    );
  }
}

class MainPage extends StatelessWidget {
  final bool isTeacher; // Assuming you have a way to determine the user's role

  MainPage({required this.isTeacher});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Page'),
      ),
      drawer: isTeacher
          ? TeacherSidebar()
          : StudentSidebar(), // Conditionally render the sidebar
      body: Center(
        child: Text('Welcome to the Main Page!'),
      ),
    );
  }
}

class TeacherSidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Teacher Sidebar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: Text('Exam List'),
            onTap: () {
              Navigator.pushNamed(context, '/teacher_examlist');
            },
          ),
          ListTile(
            title: Text('New Exam'),
            onTap: () {
              Navigator.pushNamed(context, '/newexam');
            },
          ),
        ],
      ),
    );
  }
}

class StudentSidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Student Sidebar',
              style: TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: Text('Exam List'),
            onTap: () {
              Navigator.pushNamed(context, '/student_examlist');
            },
          ),
          ListTile(
            title: Text('Exam Marks'),
            onTap: () {
              Navigator.pushNamed(context, '/student_exammarkslist');
            },
          ),
        ],
      ),
    );
  }
}
