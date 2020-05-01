import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';
// import 'dart:async'; // Potentially required to fix problem of "Undefined class File"
import 'dart:io';

// import 'package:camera/camera.dart';
// import 'dart:math' as math;

// import 'camera.dart';
// import 'render.dart';

void main() {
  // Sets Portrait orientation only
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // 'await' can only be used in a function body with either 'async' or 'async*' function

  // Method 1
  loadModel() async {
    String googlenet = await Tflite.loadModel(
      model: 'googlenet.tflite',
      labels: 'labels.txt',
      numThreads: 1,
    );
  }

  // Method 2
  // static Future<String> loadModel() async {
  //   return Tflite.loadModel(
  //     model: "googlenet.tflite",
  //     labels: "labels.txt",
  //   );
  // }

  // void initState() {
  //   super.initState(); //Load TFLite Model
  //   TFLiteHelper.loadModel().then((value) {
  //     setState(() {
  //       modelLoaded = true;
  //     });
  //   });
  // }

  // await Tflite.runModelOnFrame(
  //       bytesList: image.planes.map((plane) {
  //         return plane.bytes;
  //       }).toList(),
  //       numResults: 5)
  //   .then((value) {  if (value.isNotEmpty) {
  //    //Do something with the results
  // }});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness:
            Brightness.light, // Normal Theme (.dark turns app into Dark Mode)
      ),
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
  String _model = 'GoogLeNet';
  File _image;
  List _recognitions;
  double _imageHeight;
  double _imageWidth;
  bool _busy = false;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    if (image == null) return;
    setState(() {
      _image = image;
      _busy = true;
    });
//    predictImage(image);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Center(
          child: _image == null
              ? Text('No Image Selected',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ))
              : Image.file(_image),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: getImage(),
          tooltip: 'Pick Image',
          child: Icon(Icons.add_a_photo),
        ),
      ],
    );
  }
}
