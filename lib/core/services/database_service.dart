import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:cost_averaging_trading_app/features/strategy/models/strategy_parameters.dart';

class DatabaseService {
  static Database? _database;

  Future<void> initDatabase() async {
    if (_database != null) return;
    _database = await _initDatabase();
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'trading_strategy_new2.db');
    //deleteDatabase(path);
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDb,
      onUpgrade: _upgradeDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE trades(
        id TEXT PRIMARY KEY,
        symbol TEXT,
        amount REAL,
        price REAL,
        timestamp INTEGER,
        type TEXT,
        isVariableInvestment INTEGER,
        reinvestedProfit REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE strategy_parameters(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        symbol TEXT,
        investmentAmount REAL,
        intervalDays INTEGER,
        targetProfitPercentage REAL,
        stopLossPercentage REAL,
        purchaseFrequency INTEGER,
        maxInvestmentSize REAL,
        useAutoMinTradeAmount INTEGER,
        manualMinTradeAmount REAL,
        isVariableInvestmentAmount INTEGER,
        variableInvestmentPercentage REAL,
        reinvestProfits INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE strategy_status(
       id INTEGER PRIMARY KEY AUTOINCREMENT,
       status TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE price_history (
       id INTEGER PRIMARY KEY AUTOINCREMENT,
       symbol TEXT NOT NULL,
       price REAL NOT NULL,
       timestamp INTEGER NOT NULL
       )
    ''');
  }

  Future<void> _upgradeDb(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
          'ALTER TABLE trades ADD COLUMN isVariableInvestment INTEGER');
      await db.execute('ALTER TABLE trades ADD COLUMN reinvestedProfit REAL');
    }
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    Database db = await database;
    return await db.insert(table, data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    Database db = await database;
    return await db.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  Future<int> update(String table, Map<String, dynamic> data,
      {String? where, List<Object?>? whereArgs}) async {
    Database db = await database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(String table,
      {String? where, List<Object?>? whereArgs}) async {
    Database db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<void> saveStrategyParameters(StrategyParameters params) async {
    Database db = await database;
    await db.insert(
      'strategy_parameters',
      params.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<StrategyParameters?> getStrategyParameters() async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query('strategy_parameters');
    if (results.isNotEmpty) {
      return StrategyParameters.fromJson(results.first);
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getRecentTrades(int limit) async {
    Database db = await database;
    return await db.query('trades', orderBy: 'timestamp DESC', limit: limit);
  }
}
