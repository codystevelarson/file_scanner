import 'dart:io';

import 'package:flutter/material.dart';
import 'package:foto_gal/screen/dir_explorer.dart';
import 'package:foto_gal/screen/image_gallery_screen.dart';
import 'package:foto_gal/utilities/constants.dart';

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
