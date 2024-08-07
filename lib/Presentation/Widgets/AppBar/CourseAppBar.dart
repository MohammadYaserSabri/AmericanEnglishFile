import 'package:flutter/material.dart';

AppBar courseAppBar(String title, VoidCallback onChatPressed, VoidCallback onLanguagePressed) {
  return AppBar(
    title: Text(
      title,
      style: TextStyle(color: Colors.deepPurple.shade50),
    ),
    backgroundColor: Colors.deepPurple,
    actions: [
      IconButton(
        icon: const Icon(Icons.chat_bubble, color: Colors.white),
        onPressed: onChatPressed,
      ),
      IconButton(
        icon: const Icon(Icons.language, color: Colors.white),
        onPressed: onLanguagePressed,
      ),
    ],
  );
}
