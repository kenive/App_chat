import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraPage extends StatefulWidget {
  final List<CameraDescription>? cameras;
  const CameraPage({this.cameras, Key? key}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController controller;
  XFile? pictureFile;

  @override
  void initState() {
    super.initState();
    controller = CameraController(
      widget.cameras![0],
      ResolutionPreset.max,
    );
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget cameraPreview() {
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRect(
        child: Transform.scale(
          scale: controller.value.aspectRatio,
          child: Center(
            child: AspectRatio(
              aspectRatio: 1 / controller.value.aspectRatio,
              child: CameraPreview(controller),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const SizedBox(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    children: [
                      SizedBox(
                          height: 500,
                          width: 400,
                          child: !controller.value.isInitialized
                              ? Container()
                              : AspectRatio(
                                  aspectRatio: 1,
                                  child: ClipRect(
                                    child: Transform.scale(
                                      scale: controller.value.aspectRatio,
                                      child: Center(
                                        child: AspectRatio(
                                          aspectRatio:
                                              1 / controller.value.aspectRatio,
                                          child: CameraPreview(controller),
                                        ),
                                      ),
                                    ),
                                  ),
                                )),
                      Container(
                        decoration: const ShapeDecoration(
                          shape: CustomBorder(
                            borderColor: Colors.red,
                            // borderRadius: 50,
                            // borderLength: 32,
                            // borderWidth: 1,
                          ),
                        ),
                      ),

                      // Positioned(
                      //   top: 500 / 4,
                      //   child: Container(
                      //     margin: const EdgeInsets.symmetric(horizontal: 10),
                      //     height: 250,
                      //     width: double.infinity,
                      //     decoration: BoxDecoration(
                      //         border: Border.all(width: 2, color: Colors.red)),
                      //   ),
                      // ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      pictureFile = await controller.takePicture();
                      setState(() {
                        pictureFile = pictureFile;
                      });
                    },
                    child: const Text(' Image'),
                  ),
                ),
                if (pictureFile != null) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    width: double.infinity,
                    height: 300,
                    child: Image.file(
                      File(pictureFile!.path),
                      fit: BoxFit.cover,
                    ),
                  )
                ]

                //Android/iOS
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const _CARD_ASPECT_RATIO = 1 / 1.618;

const _OFFSET_X_FACTOR = 0.05;

class CustomBorder extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutBottomOffset;

  const CustomBorder({
    this.borderColor = Colors.black,
    this.borderWidth = 10,
    this.overlayColor = Colors.white,
    this.borderRadius = 12,
    this.borderLength = 32,
    this.cutOutBottomOffset = 0,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path _getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    return _getLeftTopPath(rect)
      ..lineTo(
        rect.right,
        rect.bottom,
      )
      ..lineTo(
        rect.left,
        rect.bottom,
      )
      ..lineTo(
        rect.left,
        rect.top,
      );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final offsetX = rect.width * _OFFSET_X_FACTOR;
    final cardWidth = rect.width - offsetX * 2;
    final cardHeight = cardWidth * _CARD_ASPECT_RATIO;
    final offsetY = (rect.height - cardHeight) / 2;

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final boxPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    final cutOutRect = Rect.fromLTWH(
      rect.left + offsetX,
      rect.top + offsetY,
      cardWidth,
      cardHeight,
    );

    canvas
      // ..saveLayer(
      //   rect,
      //   backgroundPaint,
      // )
      ..drawRect(
        rect,
        backgroundPaint,
      )
      ..drawRRect(
        RRect.fromLTRBAndCorners(
          cutOutRect.right - borderLength,
          cutOutRect.top,
          cutOutRect.right,
          cutOutRect.top + borderLength,
          topRight: Radius.circular(borderRadius),
        ),
        borderPaint,
      )
      ..drawRRect(
        RRect.fromLTRBAndCorners(
          cutOutRect.left,
          cutOutRect.top,
          cutOutRect.left + borderLength,
          cutOutRect.top + borderLength,
          topLeft: Radius.circular(borderRadius),
        ),
        borderPaint,
      )
      //Draw bottom right corner
      ..drawRRect(
        RRect.fromLTRBAndCorners(
          cutOutRect.right - borderLength,
          cutOutRect.bottom - borderLength,
          cutOutRect.right,
          cutOutRect.bottom,
          bottomRight: Radius.circular(borderRadius),
        ),
        borderPaint,
      )
      ..drawRRect(
        RRect.fromLTRBAndCorners(
          cutOutRect.left,
          cutOutRect.bottom - borderLength,
          cutOutRect.left + borderLength,
          cutOutRect.bottom,
          bottomLeft: Radius.circular(borderRadius),
        ),
        borderPaint,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          cutOutRect,
          Radius.circular(borderRadius),
        ),
        boxPaint,
      )
      ..restore();
  }

  @override
  ShapeBorder scale(double t) {
    return CustomBorder(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}
