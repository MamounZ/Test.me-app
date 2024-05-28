import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as Path;

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper;
  static Database? _database;

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper!;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    String path = join(await getDatabasesPath(), 'teachers_database.db');
    print('Database path: $path'); // Add this line to print the database path

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Teachers (
        Tid INTEGER PRIMARY KEY,
        Tname TEXT NOT NULL,
        Tpassword TEXT NOT NULL,
        Temail TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE Students (
        Sid INTEGER PRIMARY KEY,
        Sname TEXT NOT NULL,
        Spassword TEXT NOT NULL,
        Semail TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE Quiz (
        Qid INTEGER PRIMARY KEY,
        Qname TEXT NOT NULL,
        Qtime INTEGER NOT NULL,
        Qdate DATE NOT NULL,
        Tid INTEGER,
        FOREIGN KEY (Tid) REFERENCES Teachers (Tid)
      )
    ''');

    await db.execute('''
      CREATE TABLE Question (
        Quid INTEGER PRIMARY KEY,
        Qid INTEGER NOT NULL,
        Qutext TEXT NOT NULL,
        Qurightanswer TEXT NOT NULL,
        Qumark INTEGER NOT NULL,
        Qutype INTEGER NOT NULL,
        firstop TEXT,
        secondop TEXT,
        thirdop TEXT,
        fourthop TEXT,
        FOREIGN KEY (Qid) REFERENCES Quiz (Qid)
      )
    ''');

    await db.execute('''
      CREATE TABLE Student_Quiz (
        Sid INTEGER,
        Qid INTEGER,
        Smark INTEGER NOT NULL,
        PRIMARY KEY (Sid, Qid),
        FOREIGN KEY (Sid) REFERENCES Students (Sid),
        FOREIGN KEY (Qid) REFERENCES Quiz (Qid)
      )
    ''');

    await db.execute('''
      CREATE TABLE Student_Question (
        Sid INTEGER,
        Quid INTEGER,
        Sanswer TEXT NOT NULL,
        Answrestate TEXT NOT NULL,
        PRIMARY KEY (Sid, Quid),
        FOREIGN KEY (Sid) REFERENCES Students (Sid),
        FOREIGN KEY (Quid) REFERENCES Question (Quid)
      )
    ''');
  }

  Future<int> teacherLogin(String email, String password) async {
    Database db = await this.database;
    List<Map<String, dynamic>> teachers = await db.query('Teachers',
        where: 'Temail = ? AND Tpassword = ?', whereArgs: [email, password]);
    if (teachers.isNotEmpty) {
      // Return the teacher ID if login is successful
      return teachers[0]['Tid'];
    } else {
      // Return -1 if login fails
      return -1;
    }
  }

  Future<int> studentLogin(String email, String password) async {
    Database db = await this.database;
    List<Map<String, dynamic>> students = await db.query('Students',
        where: 'Semail = ? AND Spassword = ?', whereArgs: [email, password]);
    if (students.isNotEmpty) {
      // Return the teacher ID if login is successful
      return students[0]['Sid'];
    } else {
      // Return -1 if login fails
      return -1;
    }
  }

  Future<int> insertTeacher(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('Teachers', row);
  }

  Future<List<Map<String, dynamic>>> getAllTeachers() async {
    Database db = await database;
    return await db.query('Teachers');
  }

  Future<bool> isTeacherEmailExists(String email) async {
    Database db = await database;
    List<Map<String, dynamic>> teachers = await db.query(
      'Teachers',
      columns: ['Tid'],
      where: 'Temail = ?',
      whereArgs: [email],
    );
    return teachers.isNotEmpty;
  }

  Future<bool> isStudentEmailExists(String email) async {
    Database db = await database;
    List<Map<String, dynamic>> students = await db.query(
      'Students',
      columns: ['Sid'],
      where: 'Semail = ?',
      whereArgs: [email],
    );
    return students.isNotEmpty;
  }

  Future<int> insertStudent(Map<String, dynamic> row) async {
    Database db = await this.database;
    return await db.insert('Students', row);
  }

  Future<List<Map<String, dynamic>>> getAllStudents() async {
    Database db = await database;
    return await db.query('Students');
  }

  Future<int> insertExam(Map<String, dynamic> row) async {
    try {
      Database db = await database;
      int id = await db.insert('Quiz', row);
      return id;
    } catch (e) {
      print("Error inserting exam: $e");
      return -1; // Return -1 if an error occurs
    }
  }

  Future<int> insertSimpleQuestion(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('Question', row);
  }

  Future<int> insertMultipleChoiceQuestion(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('Question', row);
  }

  Future<List<Map<String, dynamic>>> getExamsByTeacherId(int? teacherId) async {
    Database db = await database;
    return await db.query('Quiz', where: 'Tid = ?', whereArgs: [teacherId]);
  }

  Future<Map<String, dynamic>> getTeacherById(int tid) async {
    Database db = await this.database;
    List<Map<String, dynamic>> result = await db.query(
      'Teachers',
      where: 'tid = ?',
      whereArgs: [tid],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return result.first;
    } else {
      throw Exception('Teacher with ID $tid not found');
    }
  }

  Future<Map<String, dynamic>> getStudentById(int sid) async {
    Database db = await this.database;
    List<Map<String, dynamic>> result = await db.query(
      'Students',
      where: 'sid = ?',
      whereArgs: [sid],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return result.first;
    } else {
      throw Exception('Student with ID $sid not found');
    }
  }

  Future<int> deleteExam(int examId) async {
    Database db = await database;
    return await db.delete('Quiz', where: 'Qid = ?', whereArgs: [examId]);
  }

  // Define the method to delete questions related to an exam by its ID
  Future<int> deleteQuestionsByExamId(int examId) async {
    Database db = await database;
    return await db.delete('Question', where: 'Qid = ?', whereArgs: [examId]);
  }

  Future<List<Map<String, dynamic>>> getExamsForStudent() async {
    Database db = await database;
    // Get the current date
    DateTime currentDate = DateTime.now();
    // Convert the current date to SQLite date format (YYYY-MM-DD HH:MM:SS)
    String formattedCurrentDate =
        currentDate.toIso8601String().substring(0, 19);
    // Query exams from the database where the exam date is greater than or equal to the current date
    return await db
        .query('Quiz', where: 'Qdate >= ?', whereArgs: [formattedCurrentDate]);
  }

  Future<String?> getTeacherNameById(int teacherId) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query('Teachers',
        columns: ['Tname'],
        where: 'Tid = ?',
        whereArgs: [teacherId],
        limit: 1); // Limit to 1 row as there should be only one match
    if (result.isNotEmpty) {
      return result.first['Tname'] as String?;
    } else {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getQuestionsByExamId(int? examId) async {
    Database db = await database;
    return await db.query('Question', where: 'Qid = ?', whereArgs: [examId]);
  }

  Future<int> insertStudentQuestion(int studentId, int questionId,
      String studentAnswer, String answerState) async {
    Database db = await database;
    return await db.insert('Student_Question', {
      'Sid': studentId,
      'Quid': questionId,
      'Sanswer': studentAnswer,
      'Answrestate': answerState,
    });
  }

  Future<int> insertStudentQuiz(
      int studentId, int examId, int studentMark) async {
    Database db = await database;
    return await db.insert('Student_Quiz', {
      'Sid': studentId,
      'Qid': examId,
      'Smark': studentMark,
    });
  }

  Future<int> insertStudentQuestion2(
    int? sid,
    int quid,
    String sanswer,
    String answerstate,
  ) async {
    Database db = await database;
    return await db.insert(
      'Student_Question',
      {
        'Sid': sid,
        'Quid': quid,
        'Sanswer': sanswer,
        'Answrestate': answerstate,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> insertStudentQuiz2(
    int? sid,
    int qid,
    int smark,
  ) async {
    Database db = await database;
    return await db.insert(
      'Student_Quiz',
      {
        'Sid': sid,
        'Qid': qid,
        'Smark': smark,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> isExamTaken(int? sid, int qid) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'Student_Quiz',
      where: 'Sid = ? AND Qid = ?',
      whereArgs: [sid, qid],
    );
    return result.isNotEmpty;
  }

  Future<int> getExamDuration(int qid) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'Quiz',
      columns: ['Qtime'],
      where: 'Qid = ?',
      whereArgs: [qid],
    );

    if (result.isNotEmpty) {
      return result.first['Qtime'] as int;
    } else {
      throw Exception('Quiz not found');
    }
  }

  Future<List<Map<String, dynamic>>> getStudentExamsWithMarksAndTeacher(
      int sid) async {
    final db = await openDatabase(
      Path.join(await getDatabasesPath(), 'teachers_database.db'),
    );

    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT q.Qid, q.Qname, sq.Smark, t.Tname FROM Quiz q '
      'INNER JOIN Student_Quiz sq ON q.Qid = sq.Qid '
      'INNER JOIN Teachers t ON q.Tid = t.Tid '
      'WHERE sq.Sid = ?',
      [sid],
    );

    return result;
  }

  Future<List<Map<String, dynamic>>> getStudentPerformance(int qid) async {
    final db = await openDatabase(
      Path.join(await getDatabasesPath(), 'teachers_database.db'),
    );

    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT s.Sid, s.Sname, sq.Smark FROM Students s '
      'INNER JOIN Student_Quiz sq ON s.Sid = sq.Sid '
      'WHERE sq.Qid = ?',
      [qid],
    );

    return result;
  }

  static Future<bool> onWillPop(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Exit App'),
            content: Text('Are you sure you want to logout?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
