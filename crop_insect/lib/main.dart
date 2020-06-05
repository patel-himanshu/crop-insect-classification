import 'dart:io';
import 'package:image/image.dart' as IMG;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crop_insect/model.dart';

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
  List _recognitions = [];

  // Loads GoogLeNet model
  Model googlenet =
      Model(model: 'assets/googlenet2.tflite', labels: 'assets/labels.txt');

  @override
  void initState() {
    super.initState();
    googlenet.loadModel();
  }

  // Function to upload image using Camera or Gallery upload
  Future imageUpload(int option) async {
    print('Image Upload Function');
    var image;
    if (option == 0) {
      image = await ImagePicker.pickImage(source: ImageSource.camera);
    } else {
      image = await ImagePicker.pickImage(source: ImageSource.gallery);
    }

    if (image == null) return;
    setState(() {
      _image = image;
    });

    IMG.Image image1 = IMG.decodeJpg(File(image).readAsBytesSync());
    IMG.Image image2 = IMG.copyResize(image1, width: 32, height: 32);
    File image3 = File('image2.png')..writeAsBytesSync(IMG.encodePng(image2));

    // Performs the predicitions
    List recognitions = await googlenet.predictImage(image3);
    setState(() {
      _recognitions = recognitions;
    });
  }

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
              ? Column(
                  children: <Widget>[
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 3,
                    ),
                    Center(
                      child: Text(
                        'No image selected. \n\nPlease, select an image using \n(1) Your phone\'s Camera \n(2) Your Image Gallery.',
                        style: Theme.of(context).textTheme.title,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: MediaQuery.of(context).size.height / 2,
                        child: Image.file(_image),
                      ),
                      Container(
                        height: 200.0,
                        child: ListView.builder(
                          itemCount: _recognitions.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Center(
                                child: Text(
                                  _recognitions[index]['label'],
                                  style: Theme.of(context).textTheme.title,
                                ),
                              ),
                              subtitle: Center(
                                child: Text(
                                  "Confidence: ${_recognitions[index]['confidence'].toString()}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
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
                    style: Theme.of(context).textTheme.title,
                  ),
                )
              : Center(child: Image.file(_image)),
        ),
      );
    }

    // Final MaterialApp with Scaffold
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness:
            Brightness.light, // Normal Theme (.dark turns app into Dark Mode)
        textTheme: ThemeData.light().textTheme.copyWith(
              title: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text(
              'Crop Insect Classification',
              style: TextStyle(
                fontSize: 25.0,
                color: Colors.yellow,
              ),
            ),
          ),
          backgroundColor: Colors.green[700], //deepPurple,
        ),
        backgroundColor: Colors.orange[200], //Colors.lightGreen[300],
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
