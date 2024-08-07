import 'package:flutter/material.dart';
import 'package:flutter_application_caht/Presentation/Widgets/CustomAvatar/DynamicCircleAvatar/DynamicCircleAvatar.dart';

Widget buildDrawerHeader() {
  return DrawerHeader(
    decoration: const BoxDecoration(color: Colors.deepPurple),
    child: Column(
      children: [
        Center(
          child: CircularProgressIndicator(
            backgroundColor: Colors.blue,
            color: Colors.blue.shade100,
          ),
        ),
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: DynamicCircleAvatar(imagePath: ""),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {/* Add camera logic */},
                child: const CircleAvatar(
                  radius: 15,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.camera_alt,
                    size: 20,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {/* Add edit profile logic */},
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "userName",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              const SizedBox(width: 5),
              const Icon(Icons.edit, color: Colors.white, size: 20),
            ],
          ),
        ),
      ],
    ),
  );
}