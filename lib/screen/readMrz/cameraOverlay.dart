import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'dart:math' as math;

class MRZCameraOverlay extends StatelessWidget {
  MRZCameraOverlay({
    required this.child,
    super.key,
  });

  final _log = Logger('MRZCameraOverlay');

  static const _documentFrameRatio =
      1.42; // Passport's size (ISO/IEC 7810 ID-3) is 125mm × 88mm
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        final overlayRect = _calculateOverlaySize(
          Size(
            math.min(c.maxWidth, c.maxHeight),
            math.max(c.maxWidth, c.maxHeight),
          ),
        );
        return Stack(
          children: [
            child,
            ClipPath(
              clipper: _DocumentClipper(rect: overlayRect),
              child: Container(
                foregroundDecoration: const BoxDecoration(
                  color: Color.fromRGBO(0, 0, 0, 0.45),
                ),
              ),
            ),
            _WhiteOverlay(rect: overlayRect),
            Positioned(
              //left: 10,
              right: 26,
              bottom: 10,
              height: overlayRect.height,
              child: const Center(
                child: RotatedBox(
                  quarterTurns: 1,
                  child: Text(
                    'Scan the first passport page, with bottom in the view.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () {
                  _log.info('Overlay closed');
                  Navigator.of(context, rootNavigator: true).pop();
                },
                tooltip: 'Close',
              ),
            ),
          ],
        );
      },
    );
  }

  RRect _calculateOverlaySize(Size size) {
    double width, height, left, top;

    double overlayTotalHeightInPercent = 0.95;
    // In portrait, we can respect the 5% left/right margins.
    width = size.width * 0.3;
    left = 20; //size.width * 0.1;
    height = overlayTotalHeightInPercent * size.height; 


    // Position the overlay 5% from the bottom of the screen.
    final bottom = (height) + ((1 - overlayTotalHeightInPercent) * size.height) * 0.5;
    top = bottom - height;

    final rect = RRect.fromLTRBR(
        left, top, left + width, top + height, const Radius.circular(8));
    return rect;
  }
}

class _DocumentClipper extends CustomClipper<Path> {
  _DocumentClipper({
    required this.rect,
  });

  final RRect rect;

  @override
  Path getClip(Size size) => Path()
    ..addRRect(rect)
    ..addRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height))
    ..fillType = PathFillType.evenOdd;

  @override
  bool shouldReclip(_DocumentClipper oldClipper) => false;
}

class _WhiteOverlay extends StatelessWidget {
  const _WhiteOverlay({
    required this.rect,
  });
  final RRect rect;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: rect.left,
      top: rect.top,
      child: Container(
        width: rect.width,
        height: rect.height,
        decoration: BoxDecoration(
          border: Border.all(width: 2.0, color: const Color(0xFFFFFFFF)),
          borderRadius: BorderRadius.all(rect.tlRadius),
        ),
      ),
    );
  }
}