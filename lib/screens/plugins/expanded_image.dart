import 'package:flutter/material.dart';

class ExtendedImage extends StatelessWidget {
  final String imagePath;
  final double extensionHeight;

  ExtendedImage({required this.imagePath, this.extensionHeight = 100.0});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.fromHeight(extensionHeight + _getImageHeight()),
      painter: ImageWithExtensionPainter(imagePath: imagePath, extensionHeight: extensionHeight),
    );
  }

  double _getImageHeight() {
    // Calculate the height of your image here.
    // Replace this with the actual height calculation.
    return 200.0; // Replace with your image's actual height.
  }
}

class ImageWithExtensionPainter extends CustomPainter {
  final String imagePath;
  final double extensionHeight;

  ImageWithExtensionPainter({required this.imagePath, required this.extensionHeight});

  @override
  void paint(Canvas canvas, Size size) {
    // Paint the white background
    Paint paint = Paint()..color = Colors.white;
    Rect backgroundRect = Rect.fromPoints(Offset(0, _getImageHeight()), Offset(size.width, size.height));
    canvas.drawRect(backgroundRect, paint);

    // Load and paint the image
    Image image = Image.asset(imagePath);
    image.image.resolve(ImageConfiguration()).addListener((ImageInfo info, bool _) {
      canvas.drawImageRect(
        info.image,
        Rect.fromPoints(const Offset(0, 0), Offset(size.width, _getImageHeight())),
        Rect.fromPoints(const Offset(0, 0), Offset(size.width, _getImageHeight())),
        Paint(),
      );
    } as ImageStreamListener);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

  double _getImageHeight() {
    // Calculate the height of your image here.
    // Replace this with the actual height calculation.
    return 200.0; // Replace with your image's actual height.
  }
}


