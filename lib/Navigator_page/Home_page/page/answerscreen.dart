import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AnswerEntryScreen extends StatefulWidget {
  final String? initialTestName;
  final List<String>? initialAnswers;

  AnswerEntryScreen({this.initialTestName, this.initialAnswers});

  @override
  _AnswerEntryScreenState createState() => _AnswerEntryScreenState();
}

class _AnswerEntryScreenState extends State<AnswerEntryScreen> {
  List<String> answers = List.filled(20, '');
  TextEditingController _testNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialTestName != null) {
      _testNameController.text = widget.initialTestName!;
    }
    if (widget.initialAnswers != null) {
      answers = List<String>.from(widget.initialAnswers!);
    }
  }

  Future<void> _saveTest() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String testName = _testNameController.text;
    List<String> answersList = answers;

    // Load existing tests
    String? savedTestsJson = prefs.getString('savedTests');
    List<Map<String, dynamic>> savedTests = savedTestsJson != null
        ? List<Map<String, dynamic>>.from(jsonDecode(savedTestsJson))
        : [];

    // Add new test
    savedTests.add({
      'testName': testName,
      'answers': answersList,
    });

    // Save updated list
    await prefs.setString('savedTests', jsonEncode(savedTests));
    Navigator.pop(context, {
      'testName': testName,
      'answers': answersList,
    });
  }

  @override
  Widget build(BuildContext context) {
    int markedAnswers = answers.where((answer) => answer.isNotEmpty).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('To\'g\'ri variantni belgilang!'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 16),
            TextField(
              controller: _testNameController,
              decoration: InputDecoration(
                labelText: 'Test Nomi',
              ),
            ),
            SizedBox(height: 16),
            Text('$markedAnswers/20', style: TextStyle(fontSize: 20)),
            SizedBox(height: 16),
            Expanded(
              child:Container(
                width: 350,
              decoration: BoxDecoration(
                color:  Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ListView.builder(

                itemCount: 20,
                itemBuilder: (context, index) {
                  return

                    Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        SizedBox(width: 10),
                        CircleAvatar(
                          child: Text('${index + 1}'),
                        ),
                        SizedBox(width: 30),
                        for (var option in ['A', 'B', 'C', 'D'])
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: ChoiceChip(
                              label: Text(option),
                              selected: answers[index] == option,
                              selectedColor: Color.fromRGBO(10, 235, 5, 100),
                              onSelected: (selected) {
                                setState(() {
                                  answers[index] = selected ? option : '';
                                });
                              },
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveTest,
              child: Text('Saqlash'),
            ),
          ],
        ),
      ),
    );
  }
}
