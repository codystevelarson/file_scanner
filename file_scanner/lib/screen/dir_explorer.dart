import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_scanner/models/dir_scan.dart';
import 'package:file_scanner/screen/image_gallery_screen.dart';
import 'package:disks_desktop/disks_desktop.dart';
import 'package:file_scanner/utilities/constants.dart';

class DirectoryExplorer extends StatefulWidget {
  const DirectoryExplorer({super.key});
  @override
  DirectoryExplorerState createState() => DirectoryExplorerState();
}

class DirectoryExplorerState extends State<DirectoryExplorer> {
  //list to store directories
  List<DirScan> _scans = [];
  //flag to check if directories are loading
  bool _isScanning = false;

  String _currentDisk = '';

  String _currentDir = '';

  int _folderCount = 0;
  int _folderCountFinal = 0;

  int _diskCount = 0;
  ScanType _scanType = ScanType.none;

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  bool _sortAsc = false;

  final TextStyle _textSyle = const TextStyle(color: kColorWhite);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          backgroundColor: kColorGrey,
          title: Text(
              'Directory Explorer${_isScanning ? ' | (Scanning)' : _scans.isNotEmpty ? ' | Searched:($_diskCount) Disks | ($_folderCountFinal) Folders & Found (${_scans.length}) folders containing (${_getFileCount()}) matches' : ''}'),
          actions: [
            if (_scans.isNotEmpty)
              Row(
                children: [
                  Text('Sort:'),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _sortAsc = !_sortAsc;
                      });
                      _sortScans();
                    },
                    icon: Icon(
                      _sortAsc ? Icons.arrow_upward : Icons.arrow_downward,
                      color: kColorWhite,
                    ),
                  ),
                ],
              ),
            if (_isSearching)
              Row(
                children: [
                  IconButton(
                    onPressed: () => _findDirectories(
                      ScanType.custom,
                      match: _searchController.text.split(' '),
                      exclude: ['Program Files'],
                    ),
                    icon: Icon(Icons.search),
                  ),
                  SizedBox(
                    height: 50,
                    width: 100,
                    child: TextField(
                      controller: _searchController,
                    ),
                  ),
                ],
              ),
            IconButton(
              onPressed: () => setState(() {
                _isSearching = !_isSearching;
              }),
              icon: Icon(_isSearching ? Icons.close : Icons.search),
            ),
            IconButton(
              onPressed: () => _findDirectories(
                ScanType.text,
                match: kScanMatches[ScanType.text]!,
                exclude: ['Program Files'],
              ),
              icon: const Icon(Icons.text_fields),
            ),
            IconButton(
              onPressed: () => _findDirectories(
                ScanType.image,
                match: kScanMatches[ScanType.image]!,
                exclude: ['Program Files'],
              ),
              icon: const Icon(Icons.image_search),
            ),
            IconButton(
              onPressed: () {
                _findDirectories(
                  ScanType.video,
                  match: kScanMatches[ScanType.video]!,
                  exclude: ['Program Files'],
                );
              },
              icon: const Icon(Icons.video_file_sharp),
            )
          ],
        ),
        body: _isScanning
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.find_in_page,
                    color: kColorGrey,
                    size: 100,
                  ),
                  Text(
                    'Scanning:',
                    style: _textSyle,
                  ),
                  Text(
                    'Disk:  $_currentDisk',
                    style: _textSyle,
                  ),
                  Text(
                    _currentDir,
                    style: _textSyle,
                  ),
                  Text(
                    'Searched $_folderCount folders',
                    style: _textSyle,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: kColorGrey,
                      ),
                    ),
                  ),
                ],
              )
            : _scans.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: const [
                      Icon(
                        Icons.find_in_page,
                        size: 50,
                        color: kColorGrey,
                      ),
                    ],
                  )
                : ListView.builder(
                    // gridDelegate:
                    //     const SliverGridDelegateWithFixedCrossAxisCount(
                    //   crossAxisCount: 6,
                    //   childAspectRatio: 1,
                    // ),
                    itemCount: _scans.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(
                          Icons.folder,
                          color: Colors.blue,
                        ),
                        title: Text(
                          _scans[index].directory.path.split('/').last,
                          style: _textSyle,
                        ),
                        subtitle: Row(
                          children: [
                            const Icon(
                              Icons.file_present,
                              color: kColorGrey,
                            ),
                            Text(
                              _scans[index].files.length.toString(),
                              style: _textSyle,
                            ),
                          ],
                        ),
                        onTap: () {
                          _onDirectorySelected(_scans[index]);
                        },
                      );
                    },
                  ),
      ),
    );
  }

  void _findDirectories(
    ScanType scanType, {
    List<String> match = const [''],
    List<String> exclude = const [],
  }) async {
    try {
      setState(() {
        _isScanning = true;
        _folderCount = 0;
        _diskCount = 0;
        _scanType = scanType;
      });

      /// Get all disks
      final repository = DisksRepository();
      final disks = await repository.query;
      List<DirScan> dirList = [];
      List<String> errorPaths = [];

      /// Loop over disks
      for (var disk in disks) {
        setState(() {
          _diskCount++;
          _currentDisk = disk.mountpoints[0].path;
        });

        /// Stream all directories
        final Stream<FileSystemEntity> dirs =
            Directory(disk.mountpoints[0].path)
                .list(recursive: true, followLinks: false)
                .handleError(
          (e) {
            errorPaths.add((e as FileSystemException).path ?? '');
          },
          test: (e) => e is FileSystemException,
        );

        /// Loop over directories to search for files
        var folders =
            dirs.where((element) => element is Directory).cast<Directory>();
        await for (final Directory folder in folders) {
          setState(() {
            _currentDir = folder.path;
            _folderCount++;
          });

          /// Handle Excludes
          if (errorPaths.contains(folder.path) ||
              (exclude.isNotEmpty &&
                  exclude
                      .any((exclusion) => folder.path.contains(exclusion)))) {
            continue;
          }

          /// Stream all files in folder
          final Stream<FileSystemEntity> fileList =
              folder.list(followLinks: false).handleError(
                    (e) => print('Ignoring error: $e'),
                    test: (e) => e is FileSystemException,
                  );

          /// Get matches for meta data
          var files = await fileList
              .where((entity) => entity is File)
              .cast<File>()
              .where((f) => match.contains(f.path.split('.').last))
              .toList();

          if (files.isNotEmpty) {
            /// Add directory to list
            dirList.add(DirScan(folder, files: files));
          }
        }

        dirList.sort((a, b) => b.files.length.compareTo(a.files.length));

        setState(() {
          _scans = dirList;
          _isScanning = false;
          _currentDir = '';
          _currentDisk = '';
          _folderCountFinal = _folderCount;
        });
      }
    } on Exception catch (e) {
      setState(() {
        _isScanning = false;
        _isScanning = false;
        _currentDir = '';
        _currentDisk = '';
      });
    }
  }

  int _getFileCount() {
    int count = 0;
    for (var scan in _scans) {
      count += scan.files.length;
    }
    return count;
  }

  void _sortScans() {
    setState(() {
      _scans.sort(((a, b) => _sortAsc
          ? a.files.length.compareTo(b.files.length)
          : b.files.length.compareTo(a.files.length)));
      // _scans = _scans;
    });
  }

  void _onDirectorySelected(DirScan scan) {
    // perform an action when a directory is selected
    // for example, you can navigate to a new screen to display the contents of the selected directory
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ImageGalleryScreen(scan: scan)));
  }
}

enum ScanType { custom, text, image, video, audio, none }

const Map<ScanType, List<String>> kScanMatches = {
  ScanType.text: ['txt', 'rtf'],
  ScanType.image: ['png', 'jpg', 'jpeg', 'gif', 'cr2'],
  ScanType.video: ['mv4', 'mov', 'avi', 'mkv'],
  ScanType.audio: ['wav', 'mp3', 'mp4', 'aiff', 'flac'],
};
