import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';
// import 'dart:async'; // Potentially required to fix problem of "Undefined class File"
import 'dart:io';

// import 'package:camera/camera.dart';
// import 'dart:math' as math;

void main() {
  // Sets Portrait orientation only
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  File _image;
  List _recognitions;
  // String _model = 'GoogLeNet';
  // double _imageHeight;
  // double _imageWidth;
  bool _busy = false;

  Future cameraCapture() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    if (image == null) return;
    setState(() {
      _image = image;
      _busy = true;
    });
//    predictImage(image);
  }

  Future galleryUpload() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() {
      _image = image;
      _busy = true;
    });
//    predictImage(image);
  }

  Future loadModel(File image) async {
    Tflite.close();
    String res = await Tflite.loadModel(
      model: 'googlenet.tflite',
      labels: 'labels.txt',
      numThreads: 1, // Default value
    );

    List recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 6,
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    setState(() {
      _recognitions = recognitions;
    });
  }

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
    Size size = MediaQuery.of(context).size;
    List<Widget> stackChildren = [];

    if (_recognitions != null) {
      stackChildren.add(Positioned(
        top: 0.0,
        left: 0.0,
        width: size.width,
        child: _image == null
            ? Text('No image selected.')
            : Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        alignment: Alignment.topCenter,
                        image: MemoryImage(_recognitions),
                        fit: BoxFit.fill)),
                child: Opacity(opacity: 0.3, child: Image.file(_image))),
      ));
    } else {
      stackChildren.add(Positioned(
        top: 0.0,
        left: 0.0,
        width: size.width,
        child: _image == null
            ? Center(
                child: Text('Please, select an image.',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    )),
              )
            : Center(child: Image.file(_image)),
      ));
    }

    if (_busy) {
      stackChildren.add(const Opacity(
        child: ModalBarrier(dismissible: false, color: Colors.grey),
        opacity: 0.3,
      ));
      stackChildren.add(const Center(child: CircularProgressIndicator()));
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness:
            Brightness.light, // Normal Theme (.dark turns app into Dark Mode)
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text('Crop Insect Classification'),
          ),
          backgroundColor: Colors.green, //deepPurple,
        ),
        backgroundColor: Colors.yellow[300], //Colors.lightGreen[300],
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: stackChildren,
            ),
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FloatingActionButton(
              onPressed: cameraCapture,
              tooltip: 'Capture Image from Camera',
              child: Icon(Icons.add_a_photo),
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue[900],
              elevation: 7.0,
            ),
            SizedBox(height: 5.0,),
            FloatingActionButton(
              onPressed: galleryUpload,
              tooltip: 'Upload Image from Gallery',
              child: Icon(Icons.insert_photo),
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue[900],
              elevation: 7.0,
            ),
          ],
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.endFloat, // Default value
      ),
    );
  }
}
