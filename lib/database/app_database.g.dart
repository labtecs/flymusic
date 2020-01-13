part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String name;

  final List<Migration> _migrations = [];

  Callback _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final database = _$AppDatabase();
    database.database = await database.open(
      name ?? ':memory:',
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String> listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  SongDao _songDaoInstance;

  FolderDao _folderDaoInstance;

  Future<sqflite.Database> open(String name, List<Migration> migrations,
      [Callback callback]) async {
    final path = join(await sqflite.getDatabasesPath(), name);

    return sqflite.openDatabase(
      path,
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Song` (`id` INTEGER, `artist` TEXT, `title` TEXT, `album` TEXT, `albumId` INTEGER, `duration` INTEGER, `uri` TEXT, `albumArt` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Folder` (`id` INTEGER, `name` TEXT, `path` TEXT, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
  }

  @override
  SongDao get songDao {
    return _songDaoInstance ??= _$SongDao(database, changeListener);
  }

  @override
  FolderDao get folderDao {
    return _folderDaoInstance ??= _$FolderDao(database, changeListener);
  }
}

class _$SongDao extends SongDao {
  _$SongDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _songInsertionAdapter = InsertionAdapter(
            database,
            'Song',
            (Song item) => <String, dynamic>{
                  'id': item.id,
                  'artist': item.artist,
                  'title': item.title,
                  'album': item.album,
                  'albumId': item.albumId,
                  'duration': item.duration,
                  'uri': item.uri,
                  'albumArt': item.albumArt
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _songMapper = (Map<String, dynamic> row) => Song(
      row['id'] as int,
      row['artist'] as String,
      row['title'] as String,
      row['album'] as String,
      row['albumId'] as int,
      row['duration'] as int,
      row['uri'] as String,
      row['albumArt'] as String);

  final InsertionAdapter<Song> _songInsertionAdapter;

  @override
  Future<List<Song>> findAllSongs() async {
    return _queryAdapter.queryList('SELECT * FROM Songs', mapper: _songMapper);
  }

  @override
  Future<Song> findSongById(int id) async {
    return _queryAdapter.query('SELECT * FROM Songs WHERE id = ?',
        arguments: <dynamic>[id], mapper: _songMapper);
  }

  @override
  Future<void> insertSong(Song song) async {
    await _songInsertionAdapter.insert(song, sqflite.ConflictAlgorithm.abort);
  }
}

class _$FolderDao extends FolderDao {
  _$FolderDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _folderInsertionAdapter = InsertionAdapter(
            database,
            'Folder',
            (Folder item) => <String, dynamic>{
                  'id': item.id,
                  'name': item.name,
                  'path': item.path
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _folderMapper = (Map<String, dynamic> row) =>
      Folder(row['id'] as int, row['name'] as String, row['path'] as String);

  final InsertionAdapter<Folder> _folderInsertionAdapter;

  @override
  Future<List<Folder>> findAllFolders() async {
    return _queryAdapter.queryList('SELECT * FROM Folders',
        mapper: _folderMapper);
  }

  @override
  Future<Folder> findFolderById(int id) async {
    return _queryAdapter.query('SELECT * FROM Folders WHERE id = ?',
        arguments: <dynamic>[id], mapper: _folderMapper);
  }

  @override
  Future<void> insertFolder(Folder folder) async {
    await _folderInsertionAdapter.insert(
        folder, sqflite.ConflictAlgorithm.abort);
  }
}
