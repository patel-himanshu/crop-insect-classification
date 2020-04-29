import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
// import 'package:camera/camera.dart';
// import 'dart:math' as math;

// import 'camera.dart';
// import 'render.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // 'await' can only be used in a function body with either 'async' or 'async*' function
  loadModel() async {
    String googlenet = await Tflite.loadModel(
      model: 'googlenet.tflite',
      labels: 'labels.txt',
      numThreads: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text('Crop Insect Classification'),
          ),
          backgroundColor: Colors.orange[600],
        ),
        backgroundColor: Colors.lightBlue[200],
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(15.0),
            child: MainPage(),
          ),
        ),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Text(
            'Page Content will come here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: Text('Upload image of insect'),
        ),
      ],
    );
  }
}
