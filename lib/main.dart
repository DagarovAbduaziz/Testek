
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/Navigator_page/Home_page/home.dart';
import 'package:flutter_application/Navigator_page/Results_page/result.dart';
import 'dart:convert';
import 'dart:async';



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
      initialRoute: '/',
      routes: {
        '/home': (context) => Home(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Main()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/icons/logo.png', // Path to your logo image
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}


class Main extends StatefulWidget {

  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  @override



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
            Icon(Icons.home, size: 35,),
            Icon(Icons.menu, size: 35)
          ],

          onTap: (index) async {
            setState(() {
              selectedIndex = index;
            }
            );
          },
        ),
        body: Screens[selectedIndex]

    );
  }
}
