import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

typedef void Callback(List<dynamic> list, int h, int w);

class LiveCam extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Callback setRecog;

  LiveCam({this.cameras, this.setRecog});

  @override
  _LiveCamState createState() => _LiveCamState();
}

class _LiveCamState extends State<LiveCam> {
  CameraController controller;
  bool isDetecting = false;

  @override
  void initState() {
    super.initState();
    print(widget.cameras);
    if (widget.cameras == null || widget.cameras.length < 1) {
      // print("camera not found");
    } else {
      controller = new CameraController(
        widget.cameras[0],
        ResolutionPreset.high,
      );
      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
      controller.startImageStream((CameraImage img) {
        if (!isDetecting) {
          isDetecting = true;
          Tflite.detectObjectOnFrame(
                  bytesList: img.planes.map((plane) {
                    return plane.bytes;
                  }).toList(),
                  model: 'assets/model_unquant.tflite',
                  imageHeight: img.height,
                  imageWidth: img.width,
                  imageMean: 127.5,
                  imageStd: 127.5,
                  numResultsPerClass: 2,
                  threshold: 0.4)
              .then((recognitions) {
            widget.setRecog(recognitions, img.height, img.width);
            isDetecting = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    if (controller == null || !controller.value.isInitialized) {
      return Container();
    }

    var tmp = MediaQuery.of(context).size;
    var screenH = math.max(tmp.height, tmp.width);
    var screenW = math.min(tmp.height, tmp.width);
    tmp = controller.value.previewSize;
    var previewH = math.max(tmp.height, tmp.width);
    var previewW = math.min(tmp.height, tmp.width);
    var screenRatio = screenH / screenW;
    var previewRatio = previewH / previewW;

    return OverflowBox(
      maxHeight:
          screenRatio > previewRatio ? screenH : screenW / previewW * previewH,
      maxWidth:
          screenRatio > previewRatio ? screenH / previewH * previewW : screenW,
      child: CameraPreview(controller),
    );
  }
}
