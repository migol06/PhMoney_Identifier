import 'package:flutter/material.dart';
import 'package:glaucoma_identifier/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
// import 'package:tflite/tflite.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // LocalModel model = LocalModel("ph_currency.tflite");
  // ImageLabeler _imageLabeler = GoogleMlKit.vision.imageLabeler();
  final Camera _camera = Camera();
  bool _hasImage = false;
  String result = '';
  bool isBusy = false;
  String? text;
  int? index;
  double? confidence;
  String? imagePath;

  // Future<void> processImageWithRemoteModel(String? path) async {
  //   final inputImage = InputImage.fromFilePath(path!);
  //   final options = CustomRemoteLabelerOption(
  //       confidenceThreshold: 0.5, modelName: 'ph_currency.tflite');
  //   _imageLabeler = GoogleMlKit.vision.imageLabeler(options);
  //   processImage(inputImage);
  // }

  // Future<void> processImage(InputImage inputImage) async {
  //   if (isBusy) return;
  //   isBusy = true;
  //   await Future.delayed(const Duration(milliseconds: 50));
  //   final labels = await _imageLabeler.processImage(inputImage);
  //   // final painter = LabelDetectorPainter(labels);
  //   // customPaint = CustomPaint(painter: painter);
  //   isBusy = false;
  //   if (mounted) {
  //     setState(() {
  //       for (ImageLabel label in labels) {
  //         text = label.label;
  //         index = label.index;
  //         confidence = label.confidence;
  //         debugPrint(text);
  //       }
  //     });
  //   }
  // }

  loadModel() async {
    String? res = await Tflite.loadModel(
        model: "assets/ph_currency.tflite",
        labels: "assets/ph_currency.txt",
        numThreads: 1, // defaults to 1
        isAsset:
            true, // defaults to true, set to false to load resources outside assets
        useGpuDelegate:
            false // defaults to false, set to true to use GPU delegate
        );

    debugPrint(res);
  }

  Future<void> getImage(ImageSource source) async {
    await _camera.getImage(source);
    setState(() {
      _hasImage = true;
      imagePath = _camera.image?.path;
      debugPrint(_camera.image?.path);
    });
  }

  Future<void> processImage() async {
    var recognitions = await Tflite.runModelOnImage(
        path: imagePath!, // required
        imageMean: 0.0, // defaults to 117.0
        imageStd: 255.0, // defaults to 1.0
        numResults: 2, // defaults to 5
        threshold: 0.2, // defaults to 0.1
        asynch: true // defaults to true
        );

    for (var output in recognitions!) {
      debugPrint(output.toString());
      if (mounted) {
        setState(() {
          result = output.toString();
        });
      }
    }
  }

  @override
  void initState() {
    // loadModelFiles();
    loadModel();
    super.initState();
  }

  @override
  void dispose() async {
    // Tflite.close();
    // _imageLabeler.close();
    await Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Money Identifier'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: imageContainer(context),
          ),
          ElevatedButton(
              onPressed: () {
                getImage(ImageSource.camera);
              },
              child: const Text('Camera')),
          ElevatedButton(
              onPressed: () {
                getImage(ImageSource.gallery);
              },
              child: const Text('Gallery')),
          ElevatedButton(
              onPressed: () {
                // processImageWithRemoteModel(imagePath);
                processImage();
              },
              child: const Text('Scan')),
          Text(
            'Hello $result',
          )
        ],
      ),
    );
  }

  Widget imageContainer(BuildContext context) {
    return Container(
      child: _hasImage ? Image.file(_camera.image!) : const Text('Text'),
      width: double.infinity,
      height: MediaQuery.of(context).size.height / 2,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 5.0),
          borderRadius: const BorderRadius.all(Radius.circular(10.0))),
    );

    // loadModelFiles() async {
    //   Tflite.close();
    //   String? res = await Tflite.loadModel(
    //       model: 'assets/glaucoma.tflite',
    //       labels: 'assets/glaucoma.txt',
    //       numThreads: 1, // defaults to 1
    //       isAsset:
    //           true, // defaults to true, set to false to load resources outside assets
    //       useGpuDelegate:
    //           false // defaults to false, set to true to use GPU delegate
    //       );
    //   debugPrint(res);
    // }
    // }

    // doImageClassification() async {
    //   var recognitions = await Tflite.runModelOnImage(
    //       path: _camera.image!.path, // required
    //       imageMean: 0.0, // defaults to 117.0
    //       imageStd: 255.0, // 255.0  defaults to 1.0
    //       numResults: 1, // defaults to 5
    //       threshold: 2.5, // defaults to 0.1
    //       asynch: true // defaults to true
    //       );

    //   for (var output in recognitions!) {
    //     result = output["label"] +
    //         " " +
    //         (output["confidence"] as double).toStringAsFixed(2);
    //     debugPrint(result + 'here');
    //   }

    //   setState(() {
    //     result;
    //   });
    // }
  }
}
