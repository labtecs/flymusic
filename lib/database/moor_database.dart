import 'package:moor/moor.dart';
import 'package:moor/moor_web.dart';
import 'package:moor_flutter/moor_flutter.dart';

part 'moor_database.g.dart';

//flutter packages pub run build_runner watch
//TODO pagination
// This annotation tells the code generator which tables this DB works with
@UseMoor(
    tables: [Songs, Albums, Artists, Arts, QueueItems],
    daos: [SongDao, AlbumDao, ArtistDao, ArtDao, QueueItemDao])
// _$AppDatabase is the name of the generated class
class AppDatabase extends _$AppDatabase {
  AppDatabase()
      // Specify the location of the database file
      : super((FlutterQueryExecutor.inDatabaseFolder(
          path: 'db.sqlite',
          // Good for debugging - prints SQL in the console
          logStatements: true,
        )));

  AppDatabase.connect(DatabaseConnection connection)
      : super.connect(connection);

  // Bump this when changing tables and columns.
  // Migrations will be covered in the next part.
  @override
  int get schemaVersion => 1;
}

@UseDao(tables: [Songs])
class SongDao extends DatabaseAccessor<AppDatabase> with _$SongDaoMixin {
  final AppDatabase db;

  // Called by the AppDatabase class
  SongDao(this.db) : super(db);

  Future insert(Song song) =>
      into(songs).insert(song, mode: InsertMode.insertOrIgnore);

  Future insertAll(List<Song> songList) => db.batch(
      (b) => b.insertAll(songs, songList, mode: InsertMode.insertOrIgnore));

  Stream<List<Song>> findAllSongs() => (select(songs)
        ..orderBy(
          ([
            // Primary sorting by due date
            (s) => OrderingTerm(expression: s.title, mode: OrderingMode.asc)
          ]),
        ))
      .watch();

  Future<Song> findSongByPath(String path) =>
      (select(songs)..where((s) => s.path.equals(path))).getSingle();

  Future<List<Song>> findSongsByArtist(Artist artist) =>
      (select(songs)..where((s) => s.artistName.equals(artist.name))).get();

  Future<List<Song>> findSongsByAlbum(Album album) =>
      (select(songs)..where((s) => s.albumName.equals(album.name))).get();

  Future<List<Song>> findSongIdsByAlbumId(int id) => select(songs).get();
}

@UseDao(tables: [Albums])
class AlbumDao extends DatabaseAccessor<AppDatabase> with _$AlbumDaoMixin {
  final AppDatabase db;

  // Called by the AppDatabase class
  AlbumDao(this.db) : super(db);

  Future insert(Album album) =>
      into(albums).insert(album, mode: InsertMode.insertOrIgnore);

  Future updateAlbum(Album album) => update(albums).replace(album);

  Stream<List<Album>> findAllAlbums() => (select(albums)
        ..orderBy(
          ([
            // Primary sorting by due date
            (a) => OrderingTerm(expression: a.name, mode: OrderingMode.asc)
          ]),
        ))
      .watch();

  Future<Album> findAlbumByName(String name) =>
      (select(albums)..where((a) => a.name.equals(name))).getSingle();
}

@UseDao(tables: [Artists])
class ArtistDao extends DatabaseAccessor<AppDatabase> with _$ArtistDaoMixin {
  final AppDatabase db;

  // Called by the AppDatabase class
  ArtistDao(this.db) : super(db);

  Future insert(Artist artist) =>
      into(artists).insert(artist, mode: InsertMode.insertOrIgnore);

  Stream<List<Artist>> findAllArtists() => (select(artists)
        ..orderBy(
          ([
            // Primary sorting by due date
            (a) => OrderingTerm(expression: a.name, mode: OrderingMode.asc)
          ]),
        ))
      .watch();

  Future<Artist> findArtistByName(String name) =>
      (select(artists)..where((a) => a.name.equals(name))).getSingle();
}

@UseDao(tables: [Arts])
class ArtDao extends DatabaseAccessor<AppDatabase> with _$ArtDaoMixin {
  final AppDatabase db;

  // Called by the AppDatabase class
  ArtDao(this.db) : super(db);

  Future insert(Art art) =>
      into(arts).insert(art, mode: InsertMode.insertOrIgnore);

  Future<Art> findArtByCrc(String crc) =>
      (select(arts)..where((a) => a.crc.equals(crc))).getSingle();
}

@UseDao(tables: [QueueItems])
class QueueItemDao extends DatabaseAccessor<AppDatabase>
    with _$QueueItemDaoMixin {
  final AppDatabase db;

  // Called by the AppDatabase class
  QueueItemDao(this.db) : super(db);

  Future insert(QueueItem queueItem) =>
      into(queueItems).insert(queueItem, mode: InsertMode.insertOrIgnore);

  Future insertAll(List<QueueItem> queueItemList) => db.batch((b) =>
      b.insertAll(queueItems, queueItemList, mode: InsertMode.insertOrIgnore));

  Future deleteQueueItem(QueueItem queueItem) =>
      delete(queueItems).delete(queueItem);

  Stream<List<QueueItem>> findAllQueueItems() => (select(queueItems)
        ..orderBy(
          ([
            // Primary sorting by due date
            (a) => OrderingTerm(expression: a.position, mode: OrderingMode.asc)
          ]),
        ))
      .watch();

  Future<QueueItem> getNextItem(int currentPosition) => (select(queueItems)
        ..orderBy(
          ([
            // Primary sorting by due date
            (a) => OrderingTerm(expression: a.position, mode: OrderingMode.asc)
          ]),
        )
        ..where((q) => q.position.isBiggerThanValue(currentPosition)))
      .getSingle();

  Future<QueueItem> getPreviousItem(int currentPosition) => (select(queueItems)
        ..orderBy(
          ([
            // Primary sorting by due date
            (a) => OrderingTerm(expression: a.position, mode: OrderingMode.asc)
          ]),
        )
        ..where((q) => q.position.isSmallerThanValue(currentPosition)))
      .getSingle();

  Future<QueueItem> getLastItem() => (select(queueItems)
        ..orderBy(
          ([
            // Primary sorting by due date
            (a) => OrderingTerm(expression: a.position, mode: OrderingMode.desc)
          ]),
        ))
      .getSingle();

  Future<void> moveItemsDownBy(int move) =>
      customUpdate('UPDATE QueueItems SET position = position + $move');
}

class Songs extends Table {
  @override
  Set<Column> get primaryKey => {path};

  TextColumn get path => text().withLength(min: 0)();

  TextColumn get title => text().withLength(min: 0)();

  TextColumn get artist => text().withLength(min: 0)();

  IntColumn get duration => integer()();

  TextColumn get artCrc =>
      text().nullable().customConstraint('NULL REFERENCES Art(crc)')();

  TextColumn get albumName =>
      text().nullable().customConstraint('NULL REFERENCES Album(name)')();

  TextColumn get artistName =>
      text().nullable().customConstraint('NULL REFERENCES Artist(name)')();
}

class Albums extends Table {
  @override
  Set<Column> get primaryKey => {name};

  //Album name ist unique, kommt nur einmal vor (deshalb primary key)
  TextColumn get name => text().withLength(min: 1)();

  TextColumn get artCrc =>
      text().nullable().customConstraint('NULL REFERENCES Art(crc)')();
}

class Artists extends Table {
  @override
  Set<Column> get primaryKey => {name};

  //Artist name ist unique, kommt nur einmal vor (deshalb primary key)
  TextColumn get name => text().withLength(min: 1)();
}

class Arts extends Table {
  @override
  Set<Column> get primaryKey => {crc};

  TextColumn get path => text().withLength(min: 1)();

  TextColumn get crc => text().withLength(min: 1)();
}

class QueueItems extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get position => integer()();

  TextColumn get songPath =>
      text().nullable().customConstraint('NULL REFERENCES Song(id)')();
}