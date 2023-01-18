import 'dart:io';

class DirScan {
  final Directory directory;

  final List<File> files;

  DirScan(this.directory, {this.files = const []});
}
