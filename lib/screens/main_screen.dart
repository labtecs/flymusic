import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flymusic/screens/album_list_screen.dart';
import 'package:flymusic/screens/artist_screen.dart';
import 'package:flymusic/screens/drawer_screen.dart';
import 'package:flymusic/screens/queue_screen.dart';
import 'package:flymusic/screens/track_list_screen.dart';
import 'package:folder_picker/folder_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../music/music_finder.dart';

class StartScreen extends StatefulWidget {
  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
    with SingleTickerProviderStateMixin{
  Directory externalDirectory;
  TabController _tabController;


  /*
  Tab Liste
   */
  static const _ktabs = <Tab> [
    Tab(text: 'Lieder'),
    Tab(text: 'Alben'),
    Tab(text: 'Künstler'),
    Tab(icon: Icon(Icons.queue_music)),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _ktabs.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerScreen(),
      appBar: AppBar(
        title: Text("FlyMusic"),
      ),
      //body: TrackList(),
      body: TabBarView(
        children: <Widget>[
          TrackList(),
          AlbumList(),
          ArtistScreen(),
          QueueScreen(),
        ],
        controller: _tabController,
      ),
      bottomNavigationBar: Material(
        color: Colors.blue,
        child: TabBar(
          tabs: _ktabs,
          controller:  _tabController,

        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            chooseFolder();
          },
          child: Icon(Icons.folder)),
    );
  }

  Future<void> chooseFolder() async {
    var result =
        await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    if (result[PermissionGroup.storage] == PermissionStatus.granted) {
    //  await getStorage();
      Navigator.of(context).push<FolderPickerPage>(
          MaterialPageRoute(builder: (BuildContext context) {
        return FolderPickerPage(
            rootDirectory: Directory("/storage/emulated/0/"),
            /// a [Directory] object
            action: (BuildContext context, Directory folder) async {
              Navigator.of(context).pop();
              MusicFinder.readFolderIntoDatabase(folder);
            });
      }));
    }
  }

  Future<void> getStorage() async {
    final directory =
        await getExternalStorageDirectories(type: StorageDirectory.music);
    setState(() => externalDirectory = directory[1]);
  }
}
