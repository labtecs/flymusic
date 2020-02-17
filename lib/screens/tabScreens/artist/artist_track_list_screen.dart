import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flymusic/database/model/song.dart';
import 'package:flymusic/main.dart';
import 'package:flymusic/screens/drawerScreens/player_screen.dart';
import 'package:flymusic/screens/popupScreens/songPopup_screen.dart';

import '../../main_screen.dart';

class ArtistTrackListScreen extends StatefulWidget {
  final String artistName;
  final int artistID;

  ArtistTrackListScreen({Key key, this.artistName, this.artistID})
      : super(key: key);

  @override
  _ArtistTrackListScreenState createState() => _ArtistTrackListScreenState();
}

class _ArtistTrackListScreenState extends State<ArtistTrackListScreen> {
  List<Song> songs = List();

  Widget _buildRow(Song song) {
    return ListTile(
      leading: CircleAvatar(
        child: StartScreen.getArt(song.artId),
        backgroundColor: Colors.transparent,
      ),
      title: Text(song.title),
      trailing: SongPopup(),
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => PlayerScreen()));
      },
      onLongPress: () {
        Fluttertoast.showToast(
          msg: "${song.title}",
        );
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: //Icon(Icons.play_arrow),
            Text(widget.artistName),
      ),
      floatingActionButton: SpeedDial(
        child: Icon(Icons.add),
        onOpen: () => print('OPENING DIAL'),
        onClose: () => print('DIAL CLOSED'),
        children: [
          SpeedDialChild(
              child: Icon(Icons.play_arrow),
              backgroundColor: Colors.blue,
              label: 'Abspielen',
              labelStyle: TextStyle(fontSize: 18.0),
              onTap: () => print('FIRST CHILD')),
          SpeedDialChild(
            child: Icon(Icons.playlist_add),
            backgroundColor: Colors.blue,
            label: 'Warteschlange',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => print('SECOND CHILD'),
          ),
        ],
      ),
      body: FutureBuilder<List<Song>>(
        future: database.songDao.findSongsByArtistId(widget.artistID),
        builder: (BuildContext context, AsyncSnapshot<List<Song>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return _buildRow(snapshot.data[index]);
              },
            );
          } else {
            return Text("no data");
          }
        },
      ),
    );
  }
}