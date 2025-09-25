import 'dart:typed_data';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'dart:ui' as ui show Size;

/// Utilities to normalize images into ML Kit-supported 8-bit formats.
class ImageConversionUtils {
  /// Load a file and ensure it is 8-bit per channel. Returns a JPEG byte array.
  static Future<Uint8List> loadAs8BitJpegBytes(File file) async {
    final bytes = await file.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw StateError('Failed to decode image: ${file.path}');
    }

    // If source is 16-bit or any unsupported depth, convert to 8-bit.
    // Re-encode to JPEG (always 8-bit/channel), normalizing unsupported depths.
    return Uint8List.fromList(img.encodeJpg(decoded, quality: 95));
  }

  /// Convert a raw 16-bit grayscale buffer (e.g., Y16) to 8-bit grayscale.
  /// [littleEndian] indicates the endianness of the source samples.
  static Uint8List convertGray16ToGray8(Uint16List gray16,
      {bool littleEndian = true}) {
    final int length = gray16.length;
    final Uint8List gray8 = Uint8List(length);
    for (int i = 0; i < length; i++) {
      // Normalize 16-bit to 8-bit by shifting. This preserves contrast.
      gray8[i] = (gray16[i] >> 8) & 0xFF;
    }
    return gray8;
  }

  /// Build an InputImage from an arbitrary image file by first converting it to
  /// an 8-bit JPEG on disk and then using fromFilePath (works for 16-bit PNGs).
  static Future<InputImage> inputImageFromFileForce8Bit(
    File file, {
    InputImageRotation rotation = InputImageRotation.rotation0deg,
  }) async {
    final Uint8List jpegBytes = await loadAs8BitJpegBytes(file);
    final String tmpPath =
        '${Directory.systemTemp.path}/mlkit_${DateTime.now().microsecondsSinceEpoch}.jpg';
    final File tmpFile = File(tmpPath);
    await tmpFile.writeAsBytes(jpegBytes, flush: true);
    return InputImage.fromFilePath(tmpFile.path);
  }

  /// Build InputImage from 8-bit grayscale bytes (width x height), Android/iOS safe.
  static InputImage inputImageFromGray8(
    Uint8List gray8,
    int width,
    int height, {
    InputImageRotation rotation = InputImageRotation.rotation0deg,
  }) {
    // Package expects platform-native formats. For simplicity, provide BGRA8888 layout
    // by expanding grayscale into BGRA (B=G=R=Y, A=255). This is iOS-friendly and
    // also acceptable on Android via conversion.
    final int numPixels = width * height;
    final Uint8List bgra = Uint8List(numPixels * 4);
    for (int i = 0, j = 0; i < numPixels; i++, j += 4) {
      final y = gray8[i];
      bgra[j] = y; // B
      bgra[j + 1] = y; // G
      bgra[j + 2] = y; // R
      bgra[j + 3] = 255; // A
    }

    return InputImage.fromBytes(
      bytes: bgra,
      metadata: InputImageMetadata(
        size: ui.Size(width.toDouble(), height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.bgra8888,
        bytesPerRow: width * 4,
      ),
    );
  }
}


