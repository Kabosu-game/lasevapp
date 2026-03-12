import 'dart:io';
import 'package:flutter/material.dart';

Widget buildFileImage(String path) {
  return Image.file(
    File(path),
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) => const Center(
      child: Icon(Icons.image, size: 32, color: Colors.grey),
    ),
  );
}
