import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import intl package for date formatting
import 'package:test_me/database_helper.dart';
import 'package:test_me/teachers/addquestion.dart';
import 'package:test_me/teachers/sidebar.dart';

class NewExamPage extends StatefulWidget {
  final int? teacherId;

  NewExamPage({this.teacherId});

  @override
  _NewExamPageState createState() => _NewExamPageState();
}

class _NewExamPageState extends State<NewExamPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Function to open the date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (pickedDate != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _saveExam() async {
    String name = _nameController.text.trim();
    String time = _timeController.text.trim();
    String date = _dateController.text.trim();

    if (name.isNotEmpty && time.isNotEmpty && date.isNotEmpty) {
      int? teacherId = widget.teacherId;
      int examId = await _databaseHelper.insertExam({
        'Qname': name,
        'Qtime': time,
        'Qdate': date,
        'Tid': teacherId,
      });

      if (examId != -1) {
        _showSuccessDialog('Exam saved successfully!');
        // Navigate to the add question page with the exam ID as a parameter
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AddQuestionPage(Qid: examId, teacherId: widget.teacherId),
          ),
        );
      } else {
        _showErrorDialog('Failed to save exam. Please try again.');
      }
    } else {
      _showErrorDialog('Please fill in all fields.');
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => DatabaseHelper.onWillPop(context),
        child: Scaffold(
          appBar: AppBar(
            title: Text('New Exam'),
          ),
          drawer: TeacherSidebar(
            tid: widget.teacherId,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.teacherId != null) // Display teacherId if available

                  Text(
                    'Exam Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Exam Name'),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _timeController,
                  decoration: InputDecoration(labelText: 'Exam Time'),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: 'Exam Date',
                    suffixIcon: IconButton(
                      onPressed: () => _selectDate(context),
                      icon: Icon(Icons.calendar_today),
                    ),
                  ),
                  readOnly: true, // Make the field readonly
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveExam,
                  child: Text('Creat Exam'),
                ),
              ],
            ),
          ),
        ));
  }
}
