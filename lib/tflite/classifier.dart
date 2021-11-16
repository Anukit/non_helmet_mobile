import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:image/image.dart' as imageLib;
import 'package:non_helmet_mobile/tflite/recognition.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

import 'stats.dart';

/// Classifier
class Classifier {
  /// Instance of Interpreter
  Interpreter? _interpreter;

  /// Labels file loaded as List
  List<String>? _labels;

  static const String MODEL_FILE_NAME = "detect.tflite";
  static const String LABEL_FILE_NAME = "labelmap.txt";

  ///Input size of image (height = width = 300)
  static const int INPUT_SIZE = 300;

  /// Result score threshold
  static const double THRESHOLD = 0.5;

  ///[ImageProcessor] used to pre-precess the image
  ImageProcessor? imageProcessor;

  ///Padding the image to transform into square
  int? padSize;

  ///Shapes of outpot tensor
  List<List<int>>? _outputShapes;

  ///Types of output tensor
  List<TfLiteType>? _outputTypes;

  /// Number of results to show
  static const int NUM_RESULTS = 10;

  Classifier({
    Interpreter? interpreter,
    List<String>? labels,
  }) {
    loadModel(interpreter: interpreter);
    loadLabels(labels: labels);
  }

  /// Loads interpreter from asset
  void loadModel({Interpreter? interpreter}) async {
    try {
      _interpreter = await Interpreter.fromAsset(
        MODEL_FILE_NAME,
        options: InterpreterOptions()..threads = 4,
      );

      var outputTensors = _interpreter!.getOutputTensors();
      _outputTypes = [];
      _outputShapes = [];
      for (var tensor in outputTensors) {
        _outputShapes!.add(tensor.shape);
        _outputTypes!.add(tensor.type);
      }
    } catch (e) {
      print("Error while creating interpreter: $e");
    }
  }

  /// Loads labels from assets
  void loadLabels({List<String>? labels}) async {
    try {
      _labels = await FileUtil.loadLabels("assets/" + LABEL_FILE_NAME);
    } catch (e) {
      print("Error while loading labels: $e");
    }
  }

  /// Pre-process the image
  TensorImage getProcessedImage(TensorImage inputImage) {
    padSize = max(inputImage.height, inputImage.width);
    if (imageProcessor == null) {
      //create ImageProcessor
      imageProcessor = ImageProcessorBuilder()
          // Padding the image
          .add(ResizeWithCropOrPadOp(padSize!, padSize!))
          // Resizing tp input size
          .add(ResizeOp(INPUT_SIZE, INPUT_SIZE, ResizeMethod.BILINEAR))
          .build();
    }
    inputImage = imageProcessor!.process(inputImage);
    return inputImage;
  }

  ///Runs object detection on the input image
  Map<String, dynamic> predict(imageLib.Image image) {
    var predictStartTime = DateTime.now().millisecondsSinceEpoch;

    if (_interpreter == null) {
      print("Interpreter not initialized");

      ///return null;
      exit(0);
    }

    var preProcessStart = DateTime.now().millisecondsSinceEpoch;

    //create TensorImage from image
    TensorImage inputImage = TensorImage.fromImage(image);

    //Pre-process TensorImage
    inputImage = getProcessedImage(inputImage);

    var preProcessElapsedTime =
        DateTime.now().millisecondsSinceEpoch - preProcessStart;

    //TensorBuffer for output tensors
    TensorBuffer outputLocation = TensorBufferFloat(_outputShapes![0]);
    TensorBuffer outputClasses = TensorBufferFloat(_outputShapes![1]);
    TensorBuffer outputScores = TensorBufferFloat(_outputShapes![2]);
    TensorBuffer numLocation = TensorBufferFloat(_outputShapes![3]);

    // Inputsobject for rinForMultipleInputs
    // Use [TensorImage.buffer] or [TensorBuffer.buffer] to pass by reference
    List<Object> inputs = [inputImage.buffer];

    // Outputs map
    Map<int, Object> outputs = {
      0: outputLocation.buffer,
      1: outputClasses.buffer,
      2: outputScores.buffer,
      3: numLocation.buffer
    };

    var inferenceTimeStart = DateTime.now().microsecondsSinceEpoch;

    //run inference
    _interpreter!.runForMultipleInputs(inputs, outputs);

    var inferenceTimeElapsed =
        DateTime.now().microsecondsSinceEpoch - inferenceTimeStart;

    // Maximum number of result to show
    int resultsCount = min(NUM_RESULTS, numLocation.getIntValue(0));

    // Using labelOffset = 1 as ??? at index 0
    int labelOffset = 1;

    // Using bouding box utils for easy conversion of tensorbuffer to list<rect>
    List<Rect> location = BoundingBoxUtils.convert(
        tensor: outputLocation,
        valueIndex: [1, 0, 2, 3],
        boundingBoxAxis: 2,
        boundingBoxType: BoundingBoxType.BOUNDARIES,
        coordinateType: CoordinateType.RATIO,
        height: INPUT_SIZE,
        width: INPUT_SIZE);

    List<Recognition> recognitions = [];

    for (int i = 0; i < resultsCount; i++) {
      //Prediction score
      var score = outputScores.getDoubleValue(i);

      //Label string
      var labelIndex = outputClasses.getIntValue(i) + labelOffset;
      var label = _labels!.elementAt(labelIndex);

      if (score > THRESHOLD) {
        // inverse of rect
        // [locations] corresponds to the image size 300 X 300
        // inverseTransformRect transforms it our [inputImage]

        Rect transformedRect = imageProcessor!
            .inverseTransformRect(location[i], image.height, image.width);

        recognitions.add(Recognition(i, label, score, transformedRect));
      }
    }

    var predictElapsedTime =
        DateTime.now().millisecondsSinceEpoch - predictStartTime;

    return {
      "recognitions": recognitions,
      "stats": Stats(
          totalPredictTime: predictElapsedTime,
          inferenceTime: inferenceTimeElapsed,
          preProcessingTime: preProcessElapsedTime)
    };
  }

  /// Gets the interpreter instance
  Interpreter? get interpreter => _interpreter;

  /// Gets the loaded labels
  List<String>? get labels => _labels;
}
