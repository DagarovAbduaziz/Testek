import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../home.dart';

class ResultScreen extends StatefulWidget {
  final String groupName;
  final int correctAnswers;
  final int incorrectAnswers;
  final int unansweredQuestions;
  final double score;
  final String testName;
  final String id;

  ResultScreen({
    required this.testName,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.unansweredQuestions,
    required this.score,
    required this.groupName,
    required this.id,
  });

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  List<Map<String, dynamic>> studentDetails = [];

  @override
  void initState() {
    super.initState();
    _loadStudentDetails();
  }

  Future<void> _loadStudentDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? studentDetailsString = prefs.getString(widget.groupName);
    if (studentDetailsString != null) {
      setState(() {
        List<dynamic> decodedList = json.decode(studentDetailsString);
        studentDetails = decodedList.map((item) => Map<String, dynamic>.from(item)).toList();
      });
    }
  }

  Future<void> _saveStudentDetails() async {
    int work = 0;
    for (var student in studentDetails) {
      if ((student['id'] == widget.id) & ((student['testName'] ==
          widget.testName) | (student['testName'] == null))) {
        student['correctanswer'] = widget.correctAnswers;
        student['incorrectanswer'] = widget.incorrectAnswers;
        student['score'] = widget.score;
        student['testName'] = widget.testName;
        work = 1;
        break;
      }
    }
    if(work == 0) {
          studentDetails.add({
            'id': widget.id,
            'name': studentDetails.firstWhere((student) => student['id'] == widget.id)['name'],
            'correctanswer': widget.correctAnswers,
            'incorrectanswer': widget.incorrectAnswers,
            'score': widget.score,
            'testName': widget.testName
          });
    }

    // Save the updated student details back to SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(widget.groupName, json.encode(studentDetails));

    // Navigate back
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Main()),
          (Route<dynamic> route) => false,
    );  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Natija'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Natija',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      widget.testName,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    ResultRow(
                      label: 'To\'g\'ri javoblar:',
                      value: widget.correctAnswers.toString(),
                      color: Colors.green,
                    ),
                    ResultRow(
                      label: 'Noto\'g\'ri javoblar:',
                      value: widget.incorrectAnswers.toString(),
                      color: Colors.red,
                    ),
                    ResultRow(
                      label: 'Tashlab ketilganlar soni:',
                      value: widget.unansweredQuestions.toString(),
                      color: Colors.orange,
                    ),
                    SizedBox(height: 20),
                    Text(
                      '${widget.score.toStringAsFixed(2)}%',
                      style: TextStyle(fontSize: 40, color: Colors.green),
                    ),
                    SizedBox(height: 20),
                    Text(
                      studentDetails.firstWhere((student) => student['id'] == widget.id)['name'],
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveStudentDetails,
                      child: Text('Saqlash'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 90),
            ],
          ),
        ),
      ),
    );
  }
}

class ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  ResultRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value,
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
