import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  List<Map<String, dynamic>> _savedTests = [];
  int? _selectedTestIndex;

  List<Map<String, dynamic>> get savedTests => _savedTests;
  int? get selectedTestIndex => _selectedTestIndex;

  void addTest(Map<String, dynamic> test) {
    _savedTests.add(test);
    notifyListeners();
  }

  void updateTest(int index, Map<String, dynamic> test) {
    _savedTests[index] = test;
    notifyListeners();
  }

  void deleteTest(int index) {
    _savedTests.removeAt(index);
    if (_selectedTestIndex == index) {
      _selectedTestIndex = null;
    } else if (_selectedTestIndex != null && _selectedTestIndex! > index) {
      _selectedTestIndex = _selectedTestIndex! - 1;
    }
    notifyListeners();
  }

  void selectTest(int? index) {
    _selectedTestIndex = index;
    notifyListeners();
  }
}
