import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'cameraOverlay.dart';
import 'package:image/image.dart' as img;

class MRZCameraView extends StatefulWidget {
  const MRZCameraView({
    super.key,
    required this.onImage,
    this.initialDirection = CameraLensDirection.back,
    required this.showOverlay,
  });

  final Function(InputImage inputImage) onImage;
  final CameraLensDirection initialDirection;
  final bool showOverlay;

  @override
  MRZCameraViewState createState() => MRZCameraViewState();
}

class MRZCameraViewState extends State<MRZCameraView> {
  CameraController? _controller;
  int _cameraIndex = 1;
  List<CameraDescription> cameras = [];

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  initCamera() async {
    cameras = await availableCameras();

    try {
      if (cameras.any((element) =>
          element.lensDirection == widget.initialDirection &&
          element.sensorOrientation == 90)) {
        _cameraIndex = cameras.indexOf(
          cameras.firstWhere(
            (element) =>
                element.lensDirection == widget.initialDirection &&
                element.sensorOrientation == 90,
          ),
        );
      } else {
        _cameraIndex = cameras.indexOf(
          cameras.firstWhere(
            (element) => element.lensDirection == widget.initialDirection,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }

    _startLiveFeed();
  }

  @override
  void dispose() {
    _stopLiveFeed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.showOverlay
          ? MRZCameraOverlay(child: _liveFeedBody())
          : _liveFeedBody(),
    );
  }

  Widget _liveFeedBody() {
    if (_controller?.value.isInitialized == false ||
        _controller?.value.isInitialized == null) {
      return Container();
    }
    if (_controller?.value.isInitialized == false) {
      return Container();
    }

    final size = MediaQuery.of(context).size;
    // calculate scale depending on screen and camera ratios
    // this is actually size.aspectRatio / (1 / camera.aspectRatio)
    // because camera preview size is received as landscape
    // but we're calculating for portrait orientation
    var scale = size.aspectRatio * _controller!.value.aspectRatio;
    // to prevent scaling down, invert the value
    if (scale < 1) scale = 1 / scale;

    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Transform.scale(
            scale: scale,
            child: Center(
              child: AspectRatio(
                aspectRatio: 9 / 16,
                child: CameraPreview(_controller!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future _startLiveFeed() async {
    final camera = cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );
    _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }

      _controller?.startImageStream(_processCameraImage);
      setState(() {});
    });
  }

  Future _stopLiveFeed() async {
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
  }

  Future _processCameraImage(CameraImage image) async {
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) return;
    widget.onImage(inputImage);
  }

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };


Future<Uint8List> cropLowerHalfFromInputImageBytes(
  Uint8List originalBytes,
) async {
  final originalImage = img.decodeImage(originalBytes);
  if (originalImage == null) {
    throw Exception("Failed to decode image");
  }

  final cropped = img.copyCrop(
    originalImage,
    0,
    originalImage.height ~/ 2,
    originalImage.width,
    originalImage.height ~/ 2,
  );

  return Uint8List.fromList(img.encodeJpg(cropped)); // or encodePng
}

  Uint8List? _cropBottomHalf(CameraImage image) {
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == InputImageFormat.nv21) {
      // nv21 format for Android.
      // Y and UV planes are concatenated in a single byte array.
      final int width = image.width;
      final int height = image.height;
      final Uint8List allBytes = image.planes[0].bytes;

      final int newHeight = height ~/ 2;
      final int newYPlaneSize = width * newHeight;
      // UV plane is subsampled by 2.
      final int newUVPlaneSize = (width * newHeight) ~/ 2;

      final Uint8List croppedBytes = Uint8List(newYPlaneSize + newUVPlaneSize);

      // Copy bottom half of Y plane.
      // The Y plane for the top half is width * newHeight bytes.
      final int yDataStartOffset = width * newHeight;
      croppedBytes.setRange(0, newYPlaneSize, allBytes, yDataStartOffset);

      // Copy bottom half of UV plane.
      // The full UV plane starts after the full Y plane.
      final int uvDataStartOffset = width * height;
      // The UV plane for the top half is newUVPlaneSize bytes.
      final int uvBottomHalfStartOffset = uvDataStartOffset + newUVPlaneSize;
      croppedBytes.setRange(newYPlaneSize, newYPlaneSize + newUVPlaneSize,
          allBytes, uvBottomHalfStartOffset);

      return croppedBytes;
    } else if (format == InputImageFormat.bgra8888) {
      // bgra8888 format for iOS
      final int height = image.height;
      final int bytesPerRow = image.planes[0].bytesPerRow;
      final Uint8List bytes = image.planes[0].bytes;

      final int newHeight = height ~/ 2;
      final int offset = newHeight * bytesPerRow;

      final int newSize = bytes.length - offset;

      if (newSize < 0) {
        return null;
      }

      final Uint8List croppedBytes = Uint8List(newSize);
      croppedBytes.setRange(0, newSize, bytes, offset);
      return croppedBytes;
    }

    return null;
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null) return null;

    // get image rotation
    // it is used in android to convert the InputImage from Dart to Java: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/android/src/main/java/com/google_mlkit_commons/InputImageConverter.java
    // `rotation` is not used in iOS to convert the InputImage from Dart to Obj-C: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/ios/Classes/MLKVisionImage%2BFlutterPlugin.m
    // in both platforms `rotation` and `camera.lensDirection` can be used to compensate `x` and `y` coordinates on a canvas: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/example/lib/vision_detector_views/painters/coordinates_translator.dart
    final camera = cameras[_cameraIndex];
    final sensorOrientation = camera.sensorOrientation;
    // print(
    //     'lensDirection: ${camera.lensDirection}, sensorOrientation: $sensorOrientation, ${_controller?.value.deviceOrientation} ${_controller?.value.lockedCaptureOrientation} ${_controller?.value.isCaptureOrientationLocked}');
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[_controller!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
      // print('rotationCompensation: $rotationCompensation');
    }
    if (rotation == null) return null;
    // print('final rotation: $rotation');

    // get image format
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    // print('format: $format');
    // validate format depending on platform
    // only supported formats:
    // * nv21 for Android
    // * bgra8888 for iOS
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) {
      return null;
    }

    // since format is constraint to nv21 or bgra8888, both only have one plane
    if (image.planes.length < 1) return null;
    var plane = image.planes.first;
    // print ('-------------------------------------------');
    // print('------>rotation: $rotation');
    // print ('------>format: $format');
    // print ('------>image.width: ${image.width}');
    // print ('------>image.height: ${image.height}');
    // print ('------>plane.bytesPerRow: ${plane.bytesPerRow}');
    // print ('------>plane.bytes: ${plane.bytes}');
    // print ('------>plane.bytes.length: ${plane.bytes.length}');
    // print ('------>plane.bytes.length: ${plane.bytes.length}');
    // print ('-------------------------------------------');



    //final croppedBytes = Uint8List.fromList(img.encodeJpg(croppedImage));

    
    // compose InputImage using bytes
    final croppedBytes = _cropBottomHalf(image);

    if (croppedBytes == null) {
      return null;
    }

    Size size;
    if (format == InputImageFormat.nv21) {
      size = Size(image.width.toDouble(), image.height.toDouble() / 2);
    } else {
      size = Size(image.width.toDouble(), image.height.toDouble() / 2);
    }

    // compose InputImage using bytes
    return InputImage.fromBytes(
      bytes: plane.bytes, //croppedBytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // used only in Android
        format: format, // used only in iOS
        bytesPerRow: plane.bytesPerRow, // used only in iOS
      ),
    );
  }
}