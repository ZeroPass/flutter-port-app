import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:mrz_parser/mrz_parser.dart';
import 'cameraViewfinder.dart';
import 'mrzHelper.dart';
import 'dart:typed_data';

typedef MRZController = GlobalKey<MRZScannerState>;

class MRZScanner extends StatefulWidget {
  const MRZScanner({
    Key? controller,
    required this.onSuccess,
    this.initialDirection = CameraLensDirection.back,
    this.showOverlay = true,
  }) : super(key: controller);
  final Function(MRZResult mrzResult, List<String> lines) onSuccess;
  final CameraLensDirection initialDirection;
  final bool showOverlay;
  @override
  // ignore: library_private_types_in_public_api
  MRZScannerState createState() => MRZScannerState();
}

class MRZScannerState extends State<MRZScanner> {
  final TextRecognizer _textRecognizer = TextRecognizer();
  bool _canProcess = true;
  bool _isBusy = false;
  List result = [];

  void resetScanning() => _isBusy = false;
  void dataScanned() => _isBusy = true; //to avoid continuous scanning even after data is received

  @override
  void dispose() async {
    _canProcess = false;
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MRZCameraView(
      showOverlay: widget.showOverlay,
      initialDirection: widget.initialDirection,
      onImage: _processImage,
    );
  }

  void _parseScannedText(List<String> lines) {
    try {
      final data = MRZParser.parse(lines);
      _isBusy = true;

      widget.onSuccess(data, lines);
    } catch (e) {
      _isBusy = false;
    }
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;

    final Size imageSize = inputImage.metadata!.size;
    final int imageWidth = imageSize.width.toInt();
    final int imageHeight = imageSize.height.toInt();
    final int imageRotation = inputImage.metadata!.rotation.rawValue;
    print('image width: $imageWidth, height: $imageHeight, rotation: $imageRotation');

    try {
      InputImage imageToProcess = inputImage;
      final imageBytes = inputImage.bytes;

      // Crop the image to the bottom half to focus on the MRZ code.
      if (imageBytes != null && inputImage.metadata != null) {
        final int halfHeight = imageHeight ~/ 2;
        final int bytesPerRow = inputImage.metadata!.bytesPerRow;
        final int startOffset = halfHeight * bytesPerRow;

        if (startOffset < imageBytes.length) {
          final Uint8List bottomHalfBytes = imageBytes.sublist(startOffset);
          imageToProcess = InputImage.fromBytes(
            bytes: bottomHalfBytes,
            metadata: InputImageMetadata(
              size: Size(imageWidth.toDouble(), halfHeight.toDouble()),
              rotation: inputImage.metadata!.rotation,
              format: inputImage.metadata!.format,
              bytesPerRow: bytesPerRow,
            ),
          );
        }
      }

      final recognizedText = await _textRecognizer.processImage(imageToProcess);
      String fullText = recognizedText.text;
      String trimmedText = fullText.replaceAll(' ', '');
      List allText = trimmedText.split('\n');

      List<String> ableToScanText = [];
      for (var e in allText) {
        if (MRZHelper.testTextLine(e).isNotEmpty) {
          ableToScanText.add(MRZHelper.testTextLine(e));
        }
      }
      List<String>? result = MRZHelper.getFinalListToParse([...ableToScanText]);

      if (result != null) {
        _parseScannedText([...result]);
      } else {
        _isBusy = false;
      }
    }
    catch (e) {
      print('Error processing image: $e');
      _isBusy = false;
    }
  }
}