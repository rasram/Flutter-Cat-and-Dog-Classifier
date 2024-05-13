import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_v2/tflite_v2.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ImagePickerWidget(),
    );
  }
}

class ImagePickerWidget extends StatefulWidget {
  const ImagePickerWidget({super.key});

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final ImagePicker picker = ImagePicker();
  File? image;
  File? file;
  var _output;
  var result = "";

  @override
  void initState() {
    super.initState();
    _loadModel().then((value) {
      setState(() {});
    });
  }

  _loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_cat_dog.tflite",
      labels: "assets/labels1.txt",
    );
  }

Future _pickImage() async {
  try {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final imageTemp = File(image.path);
    setState(() => this.image = imageTemp);
    classifyImage(imageTemp); // Pass the imageTemp file directly
  } on PlatformException catch (e) {
    print('Failed to pick image: $e');
  }
}


Future classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
        path: image.path,
        imageMean: 0.0,
        imageStd: 255.0,
        numResults: 2,
        threshold: 0.2,
        asynch: true);
    setState(() {
      _output = output;
      result = output![0]['label'].toString();
    });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppBar(
            title: const Text('Cat/Dog Image Classifier'),
            backgroundColor: Color.fromARGB(255, 78, 68, 160),
            foregroundColor: Colors.white,
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton(
              onPressed: () => _pickImage(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 80, 17, 43),
                foregroundColor: Color.fromARGB(255, 255, 255, 255),
              ),
              child: const Text('Select Image from Gallery'),
            ),
          ),
          const SizedBox(
            height: 100,
          ),
          if (image != null)
            Container(
                padding: const EdgeInsets.all(20),
                child: Image.file(
                  File(image!.path),
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
          
                ))
          else
            Container(
              child: const Text('No image selected'),
            ),
          Text(result),
        ],
),
);

}

}