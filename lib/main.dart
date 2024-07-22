
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/Navigator_page/Home_page/home.dart';
import 'package:flutter_application/Navigator_page/Results_page/result.dart';
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'Navigator_page/Home_page/page/answerscreen.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/home': (context) => Home(),
      },
      home: Main(),
    );
  }
}
class Main extends StatefulWidget {
  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {

  List<Map<String, dynamic>> _savedTests = [];

  @override
  void initState() {
    super.initState();
    _loadSavedTests();
  }

  Future<void> _loadSavedTests() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedTestsJson = prefs.getString('savedTests');
    if (savedTestsJson != null) {
      List<Map<String, dynamic>> savedTests = List<Map<String, dynamic>>.from(
          jsonDecode(savedTestsJson));
      setState(() {
        _savedTests = savedTests;
      });
    }
  }
  List Screens = [
    Home(),
    GroupPage()
  ];
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
          index: selectedIndex,
          items: [
            Icon(Icons.home, size: 40,),
            Icon(Icons.menu, size: 40)
      ],

        onTap: (index) async {
          setState(() {
            selectedIndex = index;
            }
          );
        },
          ),
      // floatingActionButton: FloatingActionButton(
      //   child: Icon(Icons.add, color: Colors.white,),
      //   backgroundColor: Colors.lightBlue,
      //   onPressed: () => _navigateToAnswerEntry(),
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(30),
      //   ),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Screens[selectedIndex]

    );
  }
}



