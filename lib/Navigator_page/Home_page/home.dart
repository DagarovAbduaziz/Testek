
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_application/Navigator_page/Home_page/page/support_page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:image/image.dart'as img;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../main.dart';
import 'confirm_ImageScreen.dart';
import 'page/answerscreen.dart';
import 'page/result_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  File? _image;
  File? _image2;
  String? _base64Image;
  List<Map<String, dynamic>> _savedTests = [];
  int? _index;
  int? _answer_index;
  late String _id;
  bool _isLoading = false;
  String? _errorMessage;
  List<String> groups = [];
  late String _selectedGroup;
  List<Map<String, String>> studentDetails = [];
  String? groupName2;


  @override


  void initState() {
    super.initState();
    _loadSavedTests();
    _loadGroups();
  }

  Future<void> _checkPermissions() async {
    var status = await Permission.storage.status;
    if (status.isDenied) {
      // Request the permission
      if (await Permission.storage.request().isGranted) {
        print('Storage permission granted');
      } else {
        print('Storage permission denied');
      }
    }
    // You can check other permissions similarly
  }

  Future<void> _loadGroups() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      groups = prefs.getStringList('groups') ?? [];
    });
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

  Future<void> _showGroupSelectionDialog({int? index}) async {
    String? selectedGroup;
    TextEditingController idController = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button to close the dialog.
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("O'quvchi malumotlari"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedGroup,
                hint: Text('Guruh tanlang'),
                items: groups.map((group) {
                  return DropdownMenuItem<String>(
                    value: group,
                    child: Text(group),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedGroup = value;
                  });
                },
              ),
              TextField(
                controller: idController,
                decoration: InputDecoration(labelText: 'ID kiriting'),
                keyboardType:TextInputType.number,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Bekor qilish'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Saqlash'),
              onPressed: () async {
                if ( await Permission.camera.request().isGranted) {
                    print('Camera permission granted');
                    }
                else {
                      print('Camera permission denied');
                      }
                if (selectedGroup != null && idController.text.isNotEmpty) {
                  setState(() {
                    _selectedGroup = selectedGroup!;
                    _index = index;
                    _id = idController.text;
                  });
                  _pickImage(ImageSource.camera, ans_index: index);
                  Navigator.pop(context);
                } else {
                  // Show error message or validate input
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source, {int? ans_index}) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      try {
        _image2 = await resizeImage(_image!, 600, 800);
        setState(() {
          _answer_index = ans_index;
          _base64Image = base64Encode(_image2!.readAsBytesSync());
        });


        _sendImage(); // Automatically send the image after picking
      } catch (e) {
        // Handle any errors
        print('Error resizing image: $e');
      }
    }
  }


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

  Future<void> _sendImage() async {
    Uint8List resizedImageBytes;
    if (_base64Image != null && _answer_index != null) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final url = Uri.parse('https://fathomless-mesa-02157-479cf4303ad2.herokuapp.com/');
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'image': 'data:image/jpeg;base64,$_base64Image',
            'answers': _savedTests[_answer_index!]['answers'].map((answer) {
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
            'group': _selectedGroup,
            'id': _id,
          }),
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          Uint8List bytes = base64Decode(jsonResponse['encode']);

          // Resize image
          img.Image image = img.decodeImage(Uint8List.fromList(bytes))!;
          img.Image resized = img.copyResize(image, width: 400, height: 600); // Resize dimensions as needed

          // Encode image back to base64
          Uint8List resizedBytes = Uint8List.fromList(img.encodePng(resized));
          resizedImageBytes = resizedBytes;
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ConfirmImageScreen(
                  resizedBytes: resizedImageBytes,
                    onConfirm: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResultScreen(
                correctAnswers: jsonResponse['Correct'],
                incorrectAnswers: jsonResponse['F'],
                unansweredQuestions: jsonResponse['N'],
                score: jsonResponse['D'],
                groupName: _selectedGroup,
                id: _id,
                testName: _savedTests[_answer_index!]['testName'],
                          ),
                        ),
                      );
                    },
                  onRetake: () {

                    _pickImage(ImageSource.camera, ans_index: _index); // Go back to CameraScreen
                  },
                ),
            ),
          );
        } else {
          setState(() {
            _errorMessage = 'Rasmga olishda xatolik';
          });
        }
      } on SocketException catch (_) {
        setState(() {
          _errorMessage = 'Internetga ulanishda xatolik';
        });
      } on TimeoutException catch (_) {
        setState(() {
          _errorMessage = 'Serverga ulanishda xatolik';
        });
      }  finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Rasmda xatolik';
      });
    }
  }
  Future<void> _navigateToSupport()async {
    Map<String, dynamic>? result;

    result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => YouTubeVideoPage(),
      ),
    );
  }

  Future<void> _navigateToAnswerEntry({int? editIndex}) async {
    Map<String, dynamic>? result;

    if (editIndex != null) {
      result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AnswerEntryScreen(
            initialTestName: _savedTests[editIndex]['testName'],
            initialAnswers: List<String>.from(_savedTests[editIndex]['answers']),
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
            'answers': List<String>.from(result?['answers']),
          };
        } else {
          _savedTests.add({
            'testName': result?['testName'],
            'answers': List<String>.from(result?['answers']),
          });
        }
      });
      // Save to shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('savedTests', jsonEncode(_savedTests));
      print('Test Name: ${result['testName']}');
      print('Test Answers: ${result['answers']}');
    }
  }

  void _deleteTest(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Load existing tests
    String? savedTestsJson = prefs.getString('savedTests');
    List<Map<String, dynamic>> savedTests = savedTestsJson != null
        ? List<Map<String, dynamic>>.from(jsonDecode(savedTestsJson))
        : [];

    // Remove the test at the specified index
    if (index >= 0 && index < savedTests.length) {
      savedTests.removeAt(index);

      // Save the updated list
      await prefs.setString('savedTests', jsonEncode(savedTests));

      // Update the UI
      setState(() {
        _savedTests = savedTests;
      });
    }
  }

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/img_1.png', width: 180, height: 50),
        actions: [
          FloatingActionButton(mini: true,
            onPressed: _navigateToSupport,
            backgroundColor: Colors.indigoAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text('?', style: TextStyle(color: Colors.white, fontSize: 20)),
          ),
          SizedBox()
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
                color: Colors.blue,
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
                  fontWeight: FontWeight.w500,
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
                  Text("Testlar mavjud emas. Iltimos test qo'shing!"),
                ],
              )
                  : ListView.builder(
                itemCount: _savedTests.reversed.toList().length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    child: Container(
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.all(15),
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _savedTests[(index)]['testName'] ?? 'No name',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red,),
                                onPressed: () => _deleteTest(index),
                              ),
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.green,),
                                onPressed: () => _navigateToAnswerEntry(editIndex: index),
                              ),
                              IconButton(
                                icon: Icon(Icons.camera, size: 40,),
                                onPressed: () =>
                                    _showGroupSelectionDialog(index: index),
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

            if (_isLoading)
              CircularProgressIndicator(),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            SizedBox(height: 20)

          ],
        ),

      ),

      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 40, bottom: 20.0),
          child: FloatingActionButton(
            onPressed: _navigateToAnswerEntry,
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(Icons.add, color: Colors.white,),
          ),
        ),
      ),
    );
  }
}