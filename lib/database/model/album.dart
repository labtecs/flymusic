import 'package:floor/floor.dart';

@Entity(tableName: 'Album')
class Album {
  @PrimaryKey(autoGenerate: true)
  int id;
  final String name;
  @ColumnInfo(name: 'album_art')
  final String albumArt;

  Album(this.id, this.name, this.albumArt);
}