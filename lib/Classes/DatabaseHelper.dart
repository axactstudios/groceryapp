import 'package:groceryapp/Classes/Products.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final _databaseName = "cartdb.db";
  static final _databaseVersion = 1;

  static final table = 'Cart';

  static final columnId = 'id';
  static final columnProductName = 'name';
  static final columnImageUrl = 'imageUrl';
  static final columnPrice = 'price';
  static final columnQuantity = 'qty';
  static final columnDesc = 'desc';

  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnProductName TEXT NOT NULL,
            $columnImageUrl TEXT NOT NULL,
            $columnPrice TEXT NOT NULL,
            $columnDesc TEXT NOT NULL,
            $columnQuantity INTEGER NOT NULL
          )
          ''');
  }

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(Products item) async {
    Database db = await instance.database;
    return await db.insert(table, {
      'name': item.name,
      'imageUrl': item.imageUrl,
      'price': item.price,
      'qty': item.qty,
      'desc': item.desc
    });
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  // Queries rows based on the argument received
  Future<List<Map<String, dynamic>>> queryRows(name) async {
    Database db = await instance.database;
    return await db.query(table, where: "$columnProductName LIKE '%$name%'");
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(Products item) async {
    Database db = await instance.database;
    String productName = item.toMap()['name'];
    return await db.update(table, item.toMap(),
        where: '$columnProductName = ?', whereArgs: [productName]);
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(String name) async {
    Database db = await instance.database;
    return await db
        .delete(table, where: '$columnProductName = ?', whereArgs: [name]);
  }

  Future<int> empty() async {
    Database db = await instance.database;
    return await db.delete(table);
  }
}
