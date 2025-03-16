import "package:bobomusic/origin_sdk/origin_types.dart";
import "package:sqflite/sqflite.dart";
import "package:path/path.dart";

class DBName {
  /// 歌单
  static String orderName  = "musicOrder";
}

class TableName {
  /// 本地
  static String musicLocal  = "本地";
  /// 用户自定义歌单都存在一个表里
  static String musicILike  = "我喜欢";
  /// 待播放列表
  static String musicWaitPlay  = "待播放列表";
}

// 基础数据库帮助类
abstract class BaseDatabaseHelper {
  static final Map<String, BaseDatabaseHelper> _instances = {};

  final String databaseName;
  final int version;
  Database? _database;

  BaseDatabaseHelper._internal(this.databaseName, this.version);

  factory BaseDatabaseHelper({
    required String databaseName,
    int version = 1,
  }) {
    final key = "$databaseName:$version";
    if (!_instances.containsKey(key)) {
      _instances[key] = _createInstance(databaseName, version);
    }
    return _instances[key]!;
  }

  // 抽象工厂构造函数，由子类实现
  factory BaseDatabaseHelper.createInstance(String databaseName, int version) =>
      throw UnimplementedError("Subclasses should implement this");

  static BaseDatabaseHelper _createInstance(String databaseName, int version) {
    return BaseDatabaseHelper.createInstance(databaseName, version);
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    try {
      _database = await _initDatabase();
      return _database!;
    } catch (e) {
      print("Database initialization error: $e");
      rethrow;
    }
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), databaseName);
    return await openDatabase(
      path,
      version: version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // 抽象方法，子类需要实现数据库创建逻辑
  Future<void> _onCreate(Database db, int version);

  // 抽象方法，子类需要实现数据库升级逻辑
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion);

  Future<int> insert(String tableName, Map<String, dynamic> row) async {
    try {
      Database db = await database;
      return await db.insert(tableName, row);
    } catch (e) {
      print("Insert error: $e");
      rethrow;
    }
  }

  Future<bool> isTableExists(String tableName) async {
    Database db = await database;
    var result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='$tableName'",
    );
    return result.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> queryAll(String tableName, {String? groupBy = "name"}) async {
    try {
      Database db = await database;
      return await db.rawQuery("""
        SELECT * FROM $tableName
        WHERE id IN (
          SELECT MIN(id) FROM $tableName
          GROUP BY $groupBy
        )
        ORDER BY name DESC
      """);
    } catch (e) {
      print("Query error: $e");
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> queryByParam(String tableName, String param) async {    
    try {
      Database db = await database;
      return await db.rawQuery("""
        SELECT * FROM $tableName
        WHERE id IN (
          SELECT MIN(id) FROM $tableName
          WHERE mid =? OR name LIKE? OR playId=?
          GROUP BY playId
        )
        ORDER BY name DESC
      """, [param, "%$param%", param]);
    } catch (e) {
      print("Update error: $e");
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> queryRandom({required String tableName, int? limit}) async {    
    try {
      Database db = await database;
      return await db.query(
        tableName,
        orderBy: "RANDOM()",
        limit: limit ?? 1,
      );
    } catch (e) {
      print("Update error: $e");
      rethrow;
    }
  }

  Future<int> update(String tableName, Map<String, dynamic> row) async {
    try {
      Database db = await database;
      String mid = row["mid"];
      String playId = row["playId"];
      return await db.update(
        tableName,
        row,
        where: "mid =? OR playId=?",
        whereArgs: [mid, playId],
      );
    } catch (e) {
      print("Update error: $e");
      rethrow;
    }
  }

  Future<int> delete(String tableName, String param) async {
    try {
      Database db = await database;
      return await db.delete(
        tableName,
        where: "mid =? OR name=?",
        whereArgs: [param, param],
      );
    } catch (e) {
      print("Delete error: $e");
      rethrow;
    }
  }

  Future<int> deleteAll(String tableName) async {
    try {
      Database db = await database;
      // 检查表是否存在
      bool isExist = await isTableExists(tableName);

      if (isExist) {
        // 表存在，执行删除操作
        return await db.rawDelete("DELETE FROM $tableName");
      } else {
        // 表不存在，返回 0 表示未删除任何记录
        return 0;
      }
    } catch (e) {
      print("Delete error: $e");
      rethrow;
    }
  }

  Future<void> createTable(String tableName, String createTableSql) async {
    try {
      Database db = await database;
      await db.execute(createTableSql);
    } catch (e) {
      print("Error creating table $tableName: $e");
      rethrow;
    }
  }

  Future<void> updateTableName({required String oldTableName, required String newTableName}) async {
    try {
      Database db = await database;
      await db.execute("ALTER TABLE $oldTableName RENAME TO $newTableName");
    } catch (e) {
      rethrow;
    }
  }

  Future<void> dropTable(String tableName) async {
    try {
      Database db = await database;
      await db.execute("DROP TABLE IF EXISTS $tableName");
    } catch (e) {
      print("Error dropping table $tableName: $e");
      rethrow;
    }
  }
}

class DBOrder extends BaseDatabaseHelper {
  DBOrder({
    int version = 1,
  }) : super._internal(DBName.orderName, version);

  @override
  Future<void> _onCreate(Database db, int version) async {
    /// 本地
    await db.execute(
      "CREATE TABLE ${TableName.musicLocal} (id INTEGER PRIMARY KEY AUTOINCREMENT, mid TEXT, name TEXT, cover TEXT, duration INTEGER, author TEXT, origin TEXT, playId TEXT, localPath TEXT, prev TEXT, next TEXT, orderName TEXT, isFirst TEXT, isLast TEXT)",
    );
    /// 我喜欢
    await db.execute(
      "CREATE TABLE ${TableName.musicILike} (id INTEGER PRIMARY KEY AUTOINCREMENT, mid TEXT, name TEXT, cover TEXT, duration INTEGER, author INTEGER, origin TEXT, playId TEXT, localPath TEXT, prev TEXT, next TEXT, orderName TEXT, isFirst TEXT, isLast TEXT)",
    );
    /// 待播放列表
    await db.execute(
      "CREATE TABLE ${TableName.musicWaitPlay} (id INTEGER PRIMARY KEY AUTOINCREMENT, mid TEXT, name TEXT, cover TEXT, duration INTEGER, author INTEGER, origin TEXT, playId TEXT, localPath TEXT, prev TEXT, next TEXT, orderName TEXT, isFirst TEXT, isLast TEXT)",
    );
  }

  @override
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {}

  Future<void> createOrderTable(String tableName) async {
    try {
      Database db = await database;
      await db.execute(
        "CREATE TABLE $tableName (id INTEGER PRIMARY KEY AUTOINCREMENT, mid TEXT, name TEXT, cover TEXT, duration INTEGER, author TEXT, origin TEXT, playId TEXT, localPath TEXT, prev TEXT, next TEXT, orderName TEXT, isFirst TEXT, isLast TEXT)",
      );
    } catch (e) {
      print("Error creating table $tableName: $e");
      rethrow;
    }
  }
}

Map<String, dynamic> musicItem2Row({required MusicItem music, String? prev, String? next, String? isFirst, String? isLast}) {
  Map<String, dynamic> musicRow = {
    "mid": music.id,
    "name": music.name,
    "cover": music.cover,
    "duration": music.duration,
    "author": music.author,
    "origin": music.origin.value,
    "playId": music.playId,
    "orderName": music.orderName,
    "localPath": music.localPath,
    "prev": prev ?? music.prev,
    "next": next ?? music.next,
    "isFirst": isFirst ?? music.isFirst,
    "isLast": isLast ?? music.isLast,
  };

  return musicRow;
}

MusicItem row2MusicItem({required Map<String, dynamic> dbRow, String? prev, String? next, String? isFirst, String? isLast}) {
  return MusicItem(
    id: dbRow["mid"] as String,
    cover: dbRow["cover"] as String,
    name: dbRow["name"] as String,
    duration: dbRow["duration"] as int,
    author: dbRow["author"] as String,
    origin: OriginType.getByValue(dbRow["origin"]),
    orderName: dbRow["orderName"] as String,
    localPath: dbRow["localPath"] as String,
    playId: dbRow["playId"] as String,
    prev: prev ?? dbRow["prev"] as String,
    next: next ?? dbRow["next"] as String,
    isFirst: isFirst ?? dbRow["isFirst"] as String,
    isLast: isLast ?? dbRow["isLast"] as String,
  );
}

