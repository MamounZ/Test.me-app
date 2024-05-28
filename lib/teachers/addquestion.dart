import 'package:flutter/material.dart';
import 'package:test_me/database_helper.dart';
import 'package:test_me/teachers/newexam.dart';

class AddQuestionPage extends StatefulWidget {
  final int Qid; // Exam ID
  final int? teacherId;

  AddQuestionPage({required this.Qid, required this.teacherId});

  @override
  _AddQuestionPageState createState() => _AddQuestionPageState();
}

class _AddQuestionPageState extends State<AddQuestionPage> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();
  final TextEditingController _markController = TextEditingController();
  final TextEditingController _option1Controller = TextEditingController();
  final TextEditingController _option2Controller = TextEditingController();
  final TextEditingController _option3Controller = TextEditingController();
  final TextEditingController _option4Controller = TextEditingController();
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  int _selectedIndex =
      0; // Index of selected question type (0 for Simple, 1 for Multiple Choice)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Question'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 0;
                      });
                    },
                    child: Text('Add Simple Question'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedIndex == 0 ? Colors.blue : null,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 1;
                      });
                    },
                    child: Text('Add Multiple Choice Question'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedIndex == 1 ? Colors.blue : null,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _selectedIndex == 0
                ? _buildSimpleQuestionForm()
                : _buildMultipleChoiceQuestionForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleQuestionForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: _questionController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter your question here...',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Answer:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: _answerController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter the correct answer here...',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Mark:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: _markController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter the mark for this question...',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _saveQuestion('Simple');
            },
            child: Text('Save Question'),
          ),
          ElevatedButton(
            onPressed: () {
              _saveQuestion2('Simple');
            },
            child: Text('End Exam'),
          ),
        ],
      ),
    );
  }

  Widget _buildMultipleChoiceQuestionForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: _questionController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter your question here...',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Options:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          _buildOptionTextField(_option1Controller, 'Option 1'),
          _buildOptionTextField(_option2Controller, 'Option 2'),
          _buildOptionTextField(_option3Controller, 'Option 3'),
          _buildOptionTextField(_option4Controller, 'Option 4'),
          SizedBox(height: 16),
          Text(
            'Correct Answer:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: _answerController,
            decoration: InputDecoration(
              hintText: 'Enter the correct answer...',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Mark:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: _markController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter the mark for this question...',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _saveQuestion('Multiple Choice');
            },
            child: Text('Save Question'),
          ),
          ElevatedButton(
            onPressed: () {
              _saveQuestion2('Multiple Choice');
            },
            child: Text('End Exam'),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Future<void> _saveQuestion(String questionType) async {
    String question = _questionController.text.trim();
    String answer = _answerController.text.trim();
    String mark = _markController.text.trim();
    List<String> options = [
      _option1Controller.text.trim(),
      _option2Controller.text.trim(),
      _option3Controller.text.trim(),
      _option4Controller.text.trim(),
    ];

    if (questionType == 'Simple') {
      if (question.isNotEmpty && answer.isNotEmpty && mark.isNotEmpty) {
        int result = await _databaseHelper.insertSimpleQuestion({
          'Qutext': question,
          'Qurightanswer': answer,
          'qumark': mark,
          'qutype': 'Simple',
          'Qid': widget.Qid,
        });

        if (result != 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddQuestionPage(Qid: widget.Qid, teacherId: widget.teacherId),
            ),
          );
        } else {
          _showErrorDialog('Failed to save question. Please try again.');
        }
      } else {
        _showErrorDialog('Please fill in all fields.');
      }
    } else if (questionType == 'Multiple Choice') {
      // Check if any option is empty
      if (options.any((option) => option.isEmpty)) {
        _showErrorDialog('Please fill in all options.');
        return;
      }

      if (question.isNotEmpty && answer.isNotEmpty && mark.isNotEmpty) {
        int result = await _databaseHelper.insertMultipleChoiceQuestion({
          'Qutext': question,
          'Qurightanswer': answer,
          'qumark': mark,
          'qutype': 'Multiple Choice',
          'firstop': options[0],
          'secondop': options[1],
          'thirdop': options[2],
          'fourthop': options[3],
          'Qid': widget.Qid,
        });

        if (result != 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddQuestionPage(Qid: widget.Qid, teacherId: widget.teacherId),
            ),
          );
        } else {
          _showErrorDialog('Failed to save question. Please try again.');
        }
      } else {
        _showErrorDialog('Please fill in all fields.');
      }
    }
  }

  Future<void> _saveQuestion2(String questionType) async {
    String question = _questionController.text.trim();
    String answer = _answerController.text.trim();
    String mark = _markController.text.trim();
    List<String> options = [
      _option1Controller.text.trim(),
      _option2Controller.text.trim(),
      _option3Controller.text.trim(),
      _option4Controller.text.trim(),
    ];

    if (questionType == 'Simple') {
      if (question.isNotEmpty && answer.isNotEmpty && mark.isNotEmpty) {
        int result = await _databaseHelper.insertSimpleQuestion({
          'Qutext': question,
          'Qurightanswer': answer,
          'qumark': mark,
          'qutype': 'Simple',
          'Qid': widget.Qid,
        });

        if (result != 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewExamPage(teacherId: widget.teacherId),
            ),
          );
        } else {
          _showErrorDialog('Failed to save question. Please try again.');
        }
      } else {
        _showErrorDialog('Please fill in all fields.');
      }
    } else if (questionType == 'Multiple Choice') {
      // Check if any option is empty
      if (options.any((option) => option.isEmpty)) {
        _showErrorDialog('Please fill in all options.');
        return;
      }

      if (question.isNotEmpty && answer.isNotEmpty && mark.isNotEmpty) {
        int result = await _databaseHelper.insertMultipleChoiceQuestion({
          'Qutext': question,
          'Qurightanswer': answer,
          'qumark': mark,
          'qutype': 'Multiple Choice',
          'firstop': options[0],
          'secondop': options[1],
          'thirdop': options[2],
          'fourthop': options[3],
          'Qid': widget.Qid,
        });

        if (result != 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewExamPage(teacherId: widget.teacherId),
            ),
          );
        } else {
          _showErrorDialog('Failed to save question. Please try again.');
        }
      } else {
        _showErrorDialog('Please fill in all fields.');
      }
    }
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
}
