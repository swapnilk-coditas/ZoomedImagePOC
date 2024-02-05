import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ZoomAndDragImage extends StatefulWidget {
  final String imageUrl;

  const ZoomAndDragImage({super.key, required this.imageUrl});

  @override
  _ZoomAndDragImageState createState() => _ZoomAndDragImageState();
}

class _ZoomAndDragImageState extends State<ZoomAndDragImage> {
  Offset imageOffset = Offset.zero;
  double imageScale = 1.0;
  late double scaleCopy;
  late PhotoViewController controller;

  bool isTextAtTop = false;

  bool isTextVisible = false;

  @override
  void initState() {
    super.initState();
    controller = PhotoViewController()..outputStateStream.listen(listener1);

    isTextVisible = false;
  }

  void listener1(PhotoViewControllerValue value) {
    setState(() {
      imageOffset = controller.position;
      imageScale = controller.scale!;
      scaleCopy = value.scale!;
      isTextVisible = imageScale > 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PhotoView(
          enableRotation: true,
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
          imageProvider: AssetImage(widget.imageUrl),
          controller: controller,
          gestureDetectorBehavior:
              HitTestBehavior.opaque, // Added for better gesture detection
        ),
        Positioned(
          top: _calculateTextTopPosition(),
          left: _calculateTextLeftPosition(),
          child: Visibility(
            visible: isTextVisible,
            child: Text(
              'Coordinates: (${imageOffset.dx.toStringAsFixed(2)}, ${imageOffset.dy.toStringAsFixed(2)})',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                background: Paint()..color = Colors.black.withOpacity(0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  double _calculateTextTopPosition() {
    if (imageOffset.dy > 0) {
      // Top of the image is visible
      return imageOffset.dy;
    } else if (imageOffset.dy * imageScale >
        MediaQuery.of(context).size.height) {
      // Bottom of the image is visible
      return MediaQuery.of(context).size.height - 50; // Adjust for text height
    } else {
      // Middle of the image is visible
      double top = (MediaQuery.of(context).size.height / 2) -
          (imageOffset.dy * imageScale / 2);
      return top.clamp(
          0,
          MediaQuery.of(context).size.height -
              50); // Clamp to avoid exceeding the screen height
    }
  }

  double _calculateTextLeftPosition() {
    double left;
    double screenWidth = MediaQuery.of(context).size.width;

    if (controller.value.scale != null) {
      double scaledImageWidth = screenWidth * controller.value.scale!;

      if (scaledImageWidth >= screenWidth) {
        // Image is wider than the screen, position text based on image offset
        left = (screenWidth / 2) -
            (controller.position.dx * controller.value.scale!);
      } else {
        // Image is narrower than the screen, center text horizontally
        left = (screenWidth - scaledImageWidth) / 2;
      }
    } else {
      // Default to center if scale is null
      left = (screenWidth - 50) / 2; // Adjust as needed
    }

    return left;
  }
}
