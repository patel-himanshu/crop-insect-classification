import 'dart:io';
import 'package:tflite/tflite.dart';

class Model {
  Model({this.model, this.labels});
  final String model;
  final String labels;

  void loadModel() async {
    Tflite.close();

    String res;
    res = await Tflite.loadModel(
      model: this.model,
      labels: this.labels,
    );

    print('Model Loaded: $res');
  }

  Future<List> predictImage(File image) async {
    if (image == null) return [];

    // var imagePath;
    // try {
    //   imagePath = image.path;
    //   print('Image path is $imagePath');
    // } catch (e) {
    //   print('Image Path not obtained');
    // }

    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      // path: imagePath,
      imageMean: 0.0,
      imageStd: 255.0,
      numResults: 2,
      threshold: 0.2,
      asynch: true,
    );
    return recognitions;
  }
}
