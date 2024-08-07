// ignore: file_names
import 'dart:io';
import 'package:flutter/material.dart';

class DynamicCircleAvatar extends StatelessWidget {
  final String imagePath;
  final double radius;

  const DynamicCircleAvatar({super.key, required this.imagePath, this.radius = 36.0});

  @override
  Widget build(BuildContext context) {
    bool isNetworkImage =
        imagePath.startsWith('http') || imagePath.startsWith('https');
    bool isLocalImage = File(imagePath).existsSync();

    ImageProvider backgroundImage;

    if (isNetworkImage) {
      backgroundImage = NetworkImage(imagePath);
    } else if (isLocalImage) {
      backgroundImage = FileImage(File(imagePath));
    } else {
      backgroundImage = AssetImage(imagePath);
    }

    return CircleAvatar(
      onBackgroundImageError: (exception, stackTrace) {
        
      },
      radius: radius,
      backgroundColor: const Color.fromARGB(255, 220, 228, 235),
      backgroundImage: backgroundImage,
    );
  }
}
