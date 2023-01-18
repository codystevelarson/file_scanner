import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_scanner/screen/dir_explorer.dart';
import 'package:file_scanner/screen/image_gallery_screen.dart';
import 'package:file_scanner/utilities/constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: darkTheme,
      home: DirectoryExplorer(),
      routes: {
        'gallery': (context) => const ImageGalleryScreen(),
        'files': (context) => const DirectoryExplorer(),
      },
    );
  }
}
