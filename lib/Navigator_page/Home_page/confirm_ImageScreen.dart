import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:typed_data';

class ConfirmImageScreen extends StatelessWidget {
  final Uint8List resizedBytes;
  final VoidCallback onConfirm;
  final VoidCallback onRetake;

  ConfirmImageScreen({
    required this.resizedBytes,
    required this.onConfirm,
    required this.onRetake,
  });
  
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Aniqlangan javoblar'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          (Image.memory(resizedBytes)),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.replay, size: 30,),
                onPressed: onRetake,
                tooltip: 'Rety',
              ),
              IconButton(
                icon: Icon(Icons.check, size: 30,),
                onPressed: onConfirm,
                tooltip: 'Confirm',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
