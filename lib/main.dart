import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:image/image.dart'as img;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'answerscreen.dart';
import 'result_screen.dart';

// Future<String> _decodeAndSaveImage(String base64String) async {
//   try {
//     // Decode base64 string
//     Uint8List decodedBytes = base64Decode(base64String);
//
//     // Get the application's documents directory
//     Directory appDocDir = await getApplicationDocumentsDirectory();
//     String appDocPath = appDocDir.path;
//
//     // Create the image file path
//     String filePath = '$appDocPath/decoded_image.png';
//
//     // Write the image file
//     File file = File(filePath);
//     await file.writeAsBytes(decodedBytes);
//
//     return filePath;
//   } catch (e) {
//     print('Error decoding and saving image: $e');
//     return '';
//   }
// }
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CameraScreen(),
    );
  }
}

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _image;
  File? _image2;
  String? _base64Image;
  String? _testName;
  List<String>? _testAnswers;
  List<Map<String, dynamic>> _savedTests = [];
  int? _selectedTestIndex;

  Future<File> resizeImage(File imageFile, int width, int height) async {
    // Read the image file as bytes
    final Uint8List imageBytes = await imageFile.readAsBytes();

    // Decode the image using the image package
    img.Image? originalImage = img.decodeImage(imageBytes);

    // Check if image decoding was successful
    if (originalImage == null) {
      throw Exception('Failed to decode image');
    }

    // Resize the image
    img.Image resizedImage = img.copyResize(originalImage, width: width, height: height);

    // Get the temporary directory
    final Directory tempDir = await getTemporaryDirectory();
    final String resizedImagePath = '${tempDir.path}/resized_image.jpg';

    // Save the resized image as a new file
    final File resizedImageFile = File(resizedImagePath)
      ..writeAsBytesSync(img.encodeJpg(resizedImage));

    return resizedImageFile;
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      try {
        _image2 = await resizeImage(_image!, 600, 800);
        setState(() {
          _base64Image = base64Encode(_image2!.readAsBytesSync());
        });

        _sendImage(); // Automatically send the image after picking
      } catch (e) {
        // Handle any errors
        print('Error resizing image: $e');
      }
    }
  }

  Future<void> _sendImage() async {
    if (_base64Image != null && _selectedTestIndex != null) {
      // try {
        final url = Uri.parse('https://omrapi-48a67da55efc.herokuapp.com/');
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'image': 'data:image/jpeg;base64,$_base64Image',
            'answers': _savedTests[_selectedTestIndex!]['answers'].map((answer) {
              switch (answer) {
                case 'A':
                  return 0;
                case 'B':
                  return 1;
                case 'C':
                  return 2;
                case 'D':
                  return 3;
                default:
                  return -1; // for unanswered
              }
            }).toList(),
          }),
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultScreen(
                correctAnswers: jsonResponse['Correct'],
                incorrectAnswers: jsonResponse['F'],
                unansweredQuestions: jsonResponse['N'],
                score: jsonResponse['D'],
                studentName: 'Rajapboyev A.',
              ),
            ),
          );
        } else {
          print('Failed to send image: ${response.statusCode}');
        }
      // } on SocketException catch (e) {
      //   print('SocketException: $e');
      // } on TimeoutException catch (e) {
      //   print('TimeoutException: $e');
      // } catch (e) {
      //   print('Exception: $e');
      // }
    } else {
      print('No image to send or no test selected');
    }
  }

  Future<void> _navigateToAnswerEntry({int? editIndex}) async {
    Map<String, dynamic>? result;

    if (editIndex != null) {
      result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AnswerEntryScreen(
            initialTestName: _savedTests[editIndex]['testName'],
            initialAnswers: _savedTests[editIndex]['answers'],
          ),
        ),
      );
    } else {
      result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AnswerEntryScreen(),
        ),
      );
    }

    if (result != null && result['testName'] != null && result['answers'] != null) {
      setState(() {
        if (editIndex != null) {
          _savedTests[editIndex] = {
            'testName': result?['testName'],
            'answers': result?['answers'],
          };
        } else {
          _savedTests.add({
            'testName': result?['testName'],
            'answers': result?['answers'],
          });
        }
      });
      print('Test Name: ${result['testName']}');
      print('Test Answers: ${result['answers']}');
    }
  }

  void _deleteTest(int index) {
    setState(() {
      _savedTests.removeAt(index);
      if (_selectedTestIndex == index) {
        _selectedTestIndex = null;
      } else if (_selectedTestIndex != null && _selectedTestIndex! > index) {
        _selectedTestIndex = _selectedTestIndex! - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/img_1.png', width: 180, height: 70),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text('?', style: TextStyle(color: Colors.white, fontSize: 20)),
            style: TextButton.styleFrom(backgroundColor: Colors.indigoAccent),
          ),
          SizedBox(height: 50),
        ],
      ),
      body: Center(

        child: Column(
          children: [
            SizedBox(height: 20,),
          Container(
          height: 40,
          width: 300,
          decoration: BoxDecoration(
            color: Color.fromRGBO(90, 248, 64, 100),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          child: Text(
            'Yaratilgan Testlar',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ), SizedBox(height: 15),
            Expanded(
              child: _savedTests.isEmpty
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/img.png', // Ensure this image is in the assets folder
                    width: 200,
                    height: 200,
                  ),
                  SizedBox(height: 20),
                  Text('No tests available. Please add a test.'),
                ],
              )
                  : ListView.builder(
                  itemCount: _savedTests.length,
                  itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTestIndex = index;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: _selectedTestIndex == index ? Colors.blue.shade100 : Colors.white,
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _savedTests[index]['testName'] ?? 'No name',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => _navigateToAnswerEntry(editIndex: index),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => _deleteTest(index),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: 100,
              right: 100,
              child: FloatingActionButton(
                onPressed: _navigateToAnswerEntry,
                child: Icon(Icons.add),
              ),
            ),
            Positioned(
              bottom: 25,
              left: 25,
              child: Container(
                width: MediaQuery.of(context).size.width - 50,
                height: 75,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: Icon(Icons.home),
                      iconSize: 40,
                    ),
                    IconButton(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: Icon(Icons.camera),
                      iconSize: 40,
                    ),
                    IconButton(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: Icon(Icons.menu),
                      iconSize: 40,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class DisplayImageScreen extends StatelessWidget {
  final String imagePath;
  final VoidCallback onConfirm;

  DisplayImageScreen({
    required this.imagePath,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirm Image'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.file(File(imagePath)),
          SizedBox(height: 20),
          Text('Do you want to proceed with this image?'),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Retake'),
              ),
              ElevatedButton(
                onPressed: onConfirm,
                child: Text('Confirm'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

