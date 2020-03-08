import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flymusic/database/model/album.dart';
import 'package:flymusic/database/model/song.dart';
import 'package:flymusic/main.dart';
import 'package:flymusic/screens/player/player_screen.dart';
import 'package:flymusic/screens/popupScreens/song_popup_screen.dart';
import 'package:flymusic/util/art_util.dart';

class AlbumTrackListScreen extends StatefulWidget {
  final Album album;

  AlbumTrackListScreen({Key key, this.album}) : super(key: key);

  @override
  _AlbumTrackListScreenState createState() => _AlbumTrackListScreenState();
}

class _AlbumTrackListScreenState extends State<AlbumTrackListScreen> {
  List<Song> songs = List();

  Widget _buildRow(Song song, int idx) {
    return ListTile(
      leading: CircleAvatar(
        child: Text("$idx"),
        backgroundColor: Colors.black54,
      ),
      title: Text(song.title),
      subtitle: Text("00:00"),
      //Todo korrekte Zeit
      trailing: SongPopup(song),
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
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: false,
              //    bottom: PreferredSize(
              //      preferredSize: const Size.fromHeight(48.0),
              //     child: Chip(label: Text("Dfsdf")),
              //  ),
              backgroundColor: Colors.black54,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(widget.album.name,
                    style: TextStyle(color: Colors.white, fontSize: 16.0)),
                background: ArtUtil.getArtFromAlbum(widget.album),
              ),
            ),
          ];
        },
        body: Center(
          child: FutureBuilder<List<Song>>(
            future: database.songDao.findSongsByAlbumId(widget.album.id),
            builder:
                (BuildContext context, AsyncSnapshot<List<Song>> snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    return _buildRow(
                      snapshot.data[index],
                      index + 1,
                    );
                  },
                );
              } else {
                return Text("no data, or loading");
              }
            },
          ),
        ),
      ),
    );
  }
}
