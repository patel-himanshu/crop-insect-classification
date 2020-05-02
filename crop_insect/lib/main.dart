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
      debugShowCheckedModeBanner: false,
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
  List _recognitions = [0];
  // double _imageHeight;
  // double _imageWidth;
  bool _busy = false;

  void fileInfo(image) {
    print('File Info Function');
    new FileImage(image)
        .resolve(new ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      setState(() {
        // _imageHeight = info.image.height.toDouble();
        // _imageWidth = info.image.width.toDouble();
      });
    }));
  }

  // Function to upload image using Camera or Gallery upload
  Future imageUpload(int option) async {
    print('Image Upload Function');
    var image;
    // Default image upload method is by Camera
    if (option == 0) {
      image = await ImagePicker.pickImage(source: ImageSource.camera);
    } else {
      image = await ImagePicker.pickImage(source: ImageSource.gallery);
    }

    if (image == null) return;

    setState(() {
      _image = image;
      _busy = true;
    });

    fileInfo(image);
  }

  Future recognizeImage(File image) async {
    print('recognizeImage');
    print(_recognitions);
    List recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2, // Default = 5
      threshold: 0.2, // Default = 0.1
      imageMean: 0.0, // Default = 117.0
      imageStd: 255.0, // Default = 1.0
    );

    setState(() {
      _recognitions = recognitions;
    });
    print(_recognitions);
  }

  Future loadModel(File image) async {
    Tflite.close();
    print('loadModel Tflite.close()');

    await Tflite.loadModel(
      model: 'assets/googlenet.tflite',
      labels: 'assets/labels.txt',
      numThreads: 1, // Default value
    );
    print('Tflite.loadModel executed');

    try {
      recognizeImage(image);
      print('loadModel recognizeImage completed');
    } catch (e) {
      print('loadModel recognizeImage failed');
    }
  }

  @override
  void initState() {
    print('initState');
    super.initState();
    _busy = true;

    loadModel(_image).then((val) {
      setState(() {
        print('loadModel setState');
        _busy = false;
      });
    });
  }

  // onSelect(model) async {
  //   setState(() {
  //     _busy = true;
  //     _recognitions = null;
  //   });

  //   await loadModel(_image);

  //   if (_image != null)
  //     fileInfo(_image);
  //   else
  //     setState(() {
  //       _busy = false;
  //     });
  // }

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
      stackChildren.add(
        Positioned(
          top: 0.0,
          left: 0.0,
          width: size.width,
          child: _image == null
              ? Center(
                  child: Text(
                    'No image selected.',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : Text('If Condition'),
              // : Container(
              //     decoration: BoxDecoration(
              //       image: DecorationImage(
              //           alignment: Alignment.topCenter,
              //           image: MemoryImage(_recognitions),
              //           fit: BoxFit.fill),
              //     ),
              //     child: Opacity(
              //       opacity: 0.3,
              //       child: Image.file(_image),
              //     ),
              //   ),
        ),
      );
    } else {
      stackChildren.add(
        Positioned(
          top: 0.0,
          left: 0.0,
          width: size.width,
          child: _image == null
              ? Center(
                  child: Text(
                    'Please, select an image.',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              // : Text('Else Condition'),
              : Center(child: Image.file(_image)),
        ),
      );
    }

    // Displays Circular Progress Indicator, whenever app is processing
    if (_busy) {
      print('Busy Function Activated');
      stackChildren.add(const Opacity(
        child: ModalBarrier(dismissible: false, color: Colors.grey),
        opacity: 0.3,
      ));
      stackChildren.add(const Center(child: CircularProgressIndicator()));
    }
  
    // Final MaterialApp with Scaffold
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
              onPressed: () => imageUpload(0),
              tooltip: 'Capture Image from Camera',
              child: Icon(Icons.add_a_photo),
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue[900],
              elevation: 7.0,
            ),
            SizedBox(
              height: 5.0,
            ),
            FloatingActionButton(
              onPressed: () => imageUpload(1),
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
