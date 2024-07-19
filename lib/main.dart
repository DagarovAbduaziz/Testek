import 'dart:typed_data';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/Navigator_page/home.dart';
import 'package:flutter_application/Navigator_page/result.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:image/image.dart'as img;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'Navigator_page/page/answerscreen.dart';
import 'Navigator_page/page/result_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Main(),
    );
  }
}
class Main extends StatefulWidget {
  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {

  List Screens = [
    Home(),
    AnswerEntryScreen(),
    Results()
  ];
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
          index: selectedIndex,
          items: [
            Icon(Icons.home),
            Icon(Icons.add),
            Icon(Icons.menu)
      ],

        onTap: (index) async {
          setState(() {
            selectedIndex = index;
          });
        },
          ),
      body: Screens[selectedIndex]

    );
  }
}



