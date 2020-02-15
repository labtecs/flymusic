import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flymusic/database/model/art.dart';
import 'package:flymusic/music/music_finder.dart';
import 'package:flymusic/screens/album_list_screen.dart';
import 'package:flymusic/screens/artist_screen.dart';
import 'package:flymusic/screens/drawer_screen.dart';
import 'package:flymusic/screens/queue_screen.dart';
import 'package:flymusic/screens/track_list_screen.dart';
import 'package:folder_picker/folder_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../main.dart';

class StartScreen extends StatefulWidget {
  @override
  _StartScreenState createState() => _StartScreenState();

  static FutureBuilder getArt(int artId) {
    return FutureBuilder<Art>(
        future: database.artDao.findArtById(artId),
        builder: (BuildContext context, AsyncSnapshot<Art> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return Image.file(File(snapshot.data.path));
          } else {
            return Image(image: AssetImage("asset/images/placeholder.jpg"));
          }
        });
  }
}

class _StartScreenState extends State<StartScreen>
    with SingleTickerProviderStateMixin {
  Directory externalDirectory;
  TabController _tabController;
  int _page = 0;

  /*
  Tab Liste
   */
  static const _ktabs = <Tab>[
    Tab(
      icon: Icon(Icons.audiotrack),
    ),
    Tab(icon: Icon(Icons.album)),
    Tab(icon: Icon(Icons.person)),
    Tab(icon: Icon(Icons.queue_music)),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _ktabs.length,
      vsync: this,
    );
    _tabController.addListener(() {
      setState(() {
        _page = _tabController.index;
      });
    });
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
        title: Text(getTitle()),
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
          onTap: onTapped,
          tabs: _ktabs,
          controller: _tabController,
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
              MusicFinder.instance.readFolderIntoDatabase(folder);
            });
      }));
    }
  }

  Future<void> getStorage() async {
    final directory =
        await getExternalStorageDirectories(type: StorageDirectory.music);
    setState(() => externalDirectory = directory[1]);
  }

  String getTitle() {
    switch (_page) {
      case 0:
        return 'Lied Liste';
      case 1:
        return 'Alben';
      case 2:
        return 'Künstler';
      case 3:
        return 'Warteschlange';
      default:
        return '';
    }
  }

  void onTapped(index) {
    setState(() {
      _page = index;
    });
  }
}
