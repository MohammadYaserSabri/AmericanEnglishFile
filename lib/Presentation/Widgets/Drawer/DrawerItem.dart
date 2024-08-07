
// ignore_for_file: file_names

import 'package:flutter/material.dart';

Widget buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
  return ListTile(
    leading: Icon(icon, color: Colors.deepPurple),
    title: Text(title, style: TextStyle(color: Colors.deepPurple)),
    onTap: onTap,
  );
}