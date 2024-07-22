import 'package:flutter/material.dart';
import 'package:flutter_application/Navigator_page/Results_page/page/group_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';


class GroupPage extends StatefulWidget {
  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  List<String> groups = [];

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      groups = prefs.getStringList('groups') ?? [];
    });
  }

  Future<void> _saveGroups() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('groups', groups);
  }

  void _createNewGroup() async {
    String? newGroupName = await showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _groupNameController = TextEditingController();
        return AlertDialog(
          title: Text('Create New Group'),
          content: TextField(
            controller: _groupNameController,
            decoration: InputDecoration(hintText: "Enter group name"),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
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
              title: Text('Delete Groups'),
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
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop([]);
                  },
                ),
                TextButton(
                  child: Text('Delete'),
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
      });
      _saveGroups();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      for (String group in groupsToDelete) {
        prefs.remove(group);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Groups'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String result) {
              if (result == 'create') {
                _createNewGroup();
              } else if (result == 'delete') {
                _deleteGroup();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'create',
                child: Text('Create New Group'),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text('Delete Group'),
              ),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: groups.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GroupDetailPage(groupName: groups[index])),
              );
            },
            child: Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(20),
              color: Colors.blueAccent,
              child: Text(
                groups[index],
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          );
        },
      ),
    );
  }
}
