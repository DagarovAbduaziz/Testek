import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GroupDetailPage extends StatefulWidget {
  final String groupName;

  GroupDetailPage({required this.groupName});

  @override
  _GroupDetailPageState createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  List<Map<String, dynamic>> studentDetails = [];
  List<Map<String, dynamic>> _savedTests = [];
  List<Map<String, dynamic>> _filteredStudents = [];
  int currentId = 1;
  String? selectedTestName;

  @override
  void initState() {
    super.initState();
    _loadStudentDetails();
    _loadSavedTests();
  }

  Future<void> _loadStudentDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? studentDetailsString = prefs.getString(widget.groupName);
    if (studentDetailsString != null) {
      setState(() {
        List<dynamic> decodedList = json.decode(studentDetailsString);
        studentDetails = decodedList.map((item) => Map<String, dynamic>.from(item)).toList();
        _filteredStudents = studentDetails;
        if (studentDetails.isNotEmpty) {
          currentId = studentDetails.map((e) => int.parse(e['id'])).reduce((a, b) => a > b ? a : b) + 1;
        }
      });
    }
  }

  Future<void> _loadSavedTests() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedTestsJson = prefs.getString('savedTests');
    if (savedTestsJson != null) {
      List<Map<String, dynamic>> savedTests = List<Map<String, dynamic>>.from(jsonDecode(savedTestsJson));
      setState(() {
        _savedTests = savedTests;
      });
    }
  }

  Future<void> _saveStudentDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(widget.groupName, json.encode(studentDetails));
  }

  void _editStudentDetails() async {
    List<String> newStudentNames = await showDialog(
      context: context,
      builder: (BuildContext context) {
        List<TextEditingController> controllers = [TextEditingController()];
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit Students'),
              content: Container(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: controllers.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: TextField(
                        controller: controllers[index],
                        decoration: InputDecoration(hintText: "Enter Student Name"),
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Add Another Student'),
                  onPressed: () {
                    setState(() {
                      controllers.add(TextEditingController());
                    });
                  },
                ),
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop([]);
                  },
                ),
                TextButton(
                  child: Text('Save'),
                  onPressed: () {
                    List<String> names = controllers.map((controller) => controller.text).toList();
                    Navigator.of(context).pop(names);
                  },
                ),
              ],
            );
          },
        );
      },
    );

    if (newStudentNames.isNotEmpty) {
      setState(() {
        for (var name in newStudentNames) {
          if (name.isNotEmpty) {
            studentDetails.add({
              'id': currentId.toString(),
              'name': name,
              'correctanswer': 0,
              'incorrectanswer': 0,
              'score': 0,
              'testName': null
            });
            currentId++;
          }
        }
      });
      _saveStudentDetails();
    }
  }

  void _deleteStudent(String id) {
    setState(() {
      studentDetails.removeWhere((student) => student['id'] == id);
      _filteredStudents = selectedTestName == null
          ? studentDetails
          : studentDetails.where((student) => student['testName'] == selectedTestName).toList();
    });
    _saveStudentDetails();
  }

  void _filterStudentsByTestName(String testName) {
    setState(() {
      selectedTestName = testName;
      _filteredStudents = studentDetails.where((student) => student['testName'] == testName).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _editStudentDetails,
          ),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Tests',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _savedTests.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _filterStudentsByTestName(_savedTests[index]['testName']),
                  child: Card(
                    margin: EdgeInsets.all(10),
                    child: Container(
                      width: 150,
                      padding: EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _savedTests[index]['testName'] ?? 'No Test Name',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10),

                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Students',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _filteredStudents.length,
            itemBuilder: (context, index) {
              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text(_filteredStudents[index]['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ID: ${_filteredStudents[index]['id']}'),
                      Text('Correct Answers: ${_filteredStudents[index]['correctanswer']}'),
                      Text('Incorrect Answers: ${_filteredStudents[index]['incorrectanswer']}'),
                      Text('Score: ${_filteredStudents[index]['score']}'),
                      Text('Test Name: ${_filteredStudents[index]['testName'] ?? 'N/A'}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteStudent(_filteredStudents[index]['id']),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
