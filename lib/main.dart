import 'dart:io';
import 'package:MaskDetector/cam.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _image;
  List _output;
  final picker = ImagePicker();

  // navigation to live cam
  Future realTimeCam(context) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => LiveCam()));
  }

  // load image from gallery

  void pickImageGallery() async {
    var image = await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(image.path);
    });
    applyModel();
  }

// pick from camera

  void takePhoto() async {
    var image = await ImagePicker().getImage(source: ImageSource.camera);
    setState(() {
      if (image != null) {
        _image = File(image.path);
      } else {
        print("no image selected");
      }
    });
    applyModel();
  }

  // move to realtime det4ection

  // load Model

  @override
  void initState() {
    super.initState();
    Tflite.loadModel(
      model: 'assets/model_unquant.tflite',
      labels: 'assets/labels.txt',
    );
  }

  // apply model
  void applyModel() async {
    var output = await Tflite.runModelOnImage(
      path: _image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    setState(() {
      _output = output;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(
                child: Text(
                  "Mask Detector",
                  style: TextStyle(
                      fontFamily: 'NeoSans',
                      color: Colors.yellow,
                      fontWeight: FontWeight.bold,
                      fontSize: 30),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Center(
                child: Container(
                    child: _image != null
                        ? Image.file(
                            _image,
                            width: 300,
                          )
                        : Image.asset('assets/logo.png', width: 350)),
              ),
              if (_output != null)
                Column(
                  children: [
                    SizedBox(
                      height: 50,
                    ),
                    Container(
                      child: Text(
                        "Result",
                        style: TextStyle(
                          color: Colors.red,
                          fontFamily: 'NeoSans',
                          fontSize: 18,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    // (${_output[0]["confidence"]}
                    Text(
                      '${_output[0]["label"]}',
                      style: TextStyle(
                        fontFamily: 'NeoSans',
                        color: Colors.white,
                        fontSize: 45,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              SizedBox(height: 10),
              Column(
                children: [
                  SizedBox(
                    height: 30.0,
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  SizedBox(
                    width: 300,
                    height: 60,
                    child: RaisedButton(
                      color: Colors.yellow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      onPressed: pickImageGallery,
                      child: Text(
                        'Choose from Gallery',
                        style: TextStyle(fontFamily: 'NeoSans'),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  SizedBox(
                    width: 300,
                    height: 60,
                    child: RaisedButton(
                      color: Colors.yellow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      onPressed: takePhoto,
                      child: Text(
                        'From Camera',
                        style: TextStyle(fontFamily: 'NeoSans'),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  SizedBox(
                    width: 300,
                    height: 60,
                    child: RaisedButton(
                      color: Colors.yellow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      onPressed: () {
                        realTimeCam(context);
                      },
                      child: Text(
                        'Real Time Detection',
                        style: TextStyle(fontFamily: 'NeoSans'),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
