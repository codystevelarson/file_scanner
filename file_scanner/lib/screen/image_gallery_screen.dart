import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_scanner/models/dir_scan.dart';
import 'package:file_scanner/screen/dir_explorer.dart';
import 'package:path_provider/path_provider.dart';

class ImageGalleryScreen extends StatefulWidget {
  final DirScan? scan;

  const ImageGalleryScreen({
    super.key,
    this.scan,
  });
  @override
  _ImageGalleryScreenState createState() => _ImageGalleryScreenState();
}

class _ImageGalleryScreenState extends State<ImageGalleryScreen> {
  List<File> files = [];

  //flag to check if preview or list view
  bool _isListView = true;
  //flag to check if image files are loading
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    //find all image files on the computer
    if (widget.scan != null) {
      files = widget.scan!.files;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Gallery'),
        actions: [
          // toggle button to switch between preview and list view
          IconButton(
            icon: _isListView ? Icon(Icons.view_list) : Icon(Icons.preview),
            onPressed: () {
              setState(() {
                _isListView = !_isListView;
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _isListView
              ? ListView.builder(
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Image.file(
                        widget.scan!.files[index],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(files[index].path.split('/').last),
                    );
                  },
                )
              : GridView.builder(
                  itemCount: files.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                  ),
                  itemBuilder: (context, index) {
                    return Image.file(
                      widget.scan!.files[index],
                      fit: BoxFit.contain,
                    );
                  },
                ),
    );
  }
}
