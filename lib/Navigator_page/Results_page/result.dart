import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application/Navigator_page/Results_page/page/group_detail_page.dart';
import 'package:url_launcher/url_launcher.dart';

class GroupPage extends StatefulWidget {
  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  final Uri _url = Uri.parse('https://online.publuu.com/596170/1336392');
  List<String> groups = [];
  Map<String, int> studentCounts = {};
  bool _showDefaultImage = true;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      groups = prefs.getStringList('groups') ?? [];
      _loadStudentCounts();
      if (groups.isNotEmpty) {
        _showDefaultImage = false;
      }
    });
  }

  Future<void> _loadStudentCounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, int> counts = {};

    for (String group in groups) {
      String? studentDetailsString = prefs.getString(group);
      if (studentDetailsString != null) {
        List<dynamic> decodedList = json.decode(studentDetailsString);
        counts[group] = decodedList.length;
      } else {
        counts[group] = 0;
      }
    }

    setState(() {
      studentCounts = counts;
    });
  }

  Future<void> _saveGroups() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('groups', groups);
  }


  void _navigateToGoogle() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  void _createNewGroup() async {
    String? newGroupName = await showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _groupNameController = TextEditingController();
        return AlertDialog(
          title: Text('Yangi Guruh Yaratish'),
          content: TextField(
            controller: _groupNameController,
            decoration: InputDecoration(hintText: "Guruh nomini kiriting"),
          ),
          actions: [
            TextButton(
              child: Text('Bekor qilish'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Saqlash'),
              onPressed: () {
                Navigator.of(context).pop(_groupNameController.text);
              },
            ),
          ],
        );
      },
    );

    if (newGroupName != null && newGroupName.isNotEmpty) {
      setState(() {
        groups.add(newGroupName);
        studentCounts[newGroupName] = 0; // Initialize student count for new group
        _showDefaultImage = false;
      });
      _saveGroups();
    }
  }

  void _deleteGroup() async {
    List<String> groupsToDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        List<bool> selectedGroups = List<bool>.filled(groups.length, false);
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Guruhlarni o'chirish"),
              content: Container(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    return CheckboxListTile(
                      title: Text(groups[index]),
                      value: selectedGroups[index],
                      onChanged: (bool? value) {
                        setState(() {
                          selectedGroups[index] = value!;
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Bekor qilish'),
                  onPressed: () {
                    Navigator.of(context).pop([]);
                  },
                ),
                TextButton(
                  child: Text("O'chirish"),
                  onPressed: () {
                    List<String> groupsToDelete = [];
                    for (int i = 0; i < selectedGroups.length; i++) {
                      if (selectedGroups[i]) {
                        groupsToDelete.add(groups[i]);
                      }
                    }
                    Navigator.of(context).pop(groupsToDelete);
                  },
                ),
              ],
            );
          },
        );
      },
    );

    if (groupsToDelete.isNotEmpty) {
      setState(() {
        groups.removeWhere((group) => groupsToDelete.contains(group));
        studentCounts.removeWhere((key, value) => groupsToDelete.contains(key));
      });
      _saveGroups();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      for (String group in groupsToDelete) {
        prefs.remove(group);
      }
      if (groups.isEmpty) {
        _showDefaultImage = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Guruhlar'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String result) {
              if (result == 'create') {
                _createNewGroup();
              } else if (result == 'delete') {
                _deleteGroup();
              } else if (result == 'sheet') {
                _navigateToGoogle();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'create',
                child: Text('Yangi Guruh'),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text("Guruhni O'chirish"),
              ),
              const PopupMenuItem<String>(
                value: 'sheet',
                child: Text('Test Varaqasi'),
              ),
            ],
          ),
        ],
      ),
      body:
      _showDefaultImage
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/menu_img.png', height: 400, width: 300,), // Replace with your default image asset
            SizedBox(height: 1),
            Text(
              'Guruhlar mavjud emas',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18,),
            ),
          ],
        ),
      )
      :ListView.builder(
        itemCount: groups.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GroupDetailPage(groupName: groups[index])),
              );
              _loadGroups();
            },
            child: Card(
              margin: EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent, Colors.lightBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      groups[index],
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${studentCounts[groups[index]] ?? 0} O'quvchilar",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
