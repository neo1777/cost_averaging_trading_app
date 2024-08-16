import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:cost_averaging_trading_app/features/strategy/models/strategy_parameters.dart';

class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'trading_strategy_1777_41.db';
  static const int _databaseVersion = 4;

  Future<void> initDatabase() async {
    if (_database != null) return;
    String path = join(await getDatabasesPath(), _databaseName);
    _database = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDb,
      onUpgrade: _upgradeDb,
      onConfigure: _configureDb,
    );
  }

  Future<Database> get database async {
    if (_database == null) {
      await initDatabase();
    }
    return _database!;
  }

  Future<void> _configureDb(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE trades(
        id TEXT PRIMARY KEY,
        symbol TEXT NOT NULL,
        amount REAL NOT NULL,
        price REAL NOT NULL,
        timestamp INTEGER NOT NULL,
        type TEXT NOT NULL,
        isVariableInvestment INTEGER NOT NULL,
        reinvestedProfit REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE strategy_parameters(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        symbol TEXT NOT NULL,
        investmentAmount REAL NOT NULL,
        intervalDays INTEGER NOT NULL,
        targetProfitPercentage REAL NOT NULL,
        stopLossPercentage REAL NOT NULL,
        purchaseFrequency INTEGER NOT NULL,
        maxInvestmentSize REAL NOT NULL,
        useAutoMinTradeAmount INTEGER NOT NULL,
        manualMinTradeAmount REAL NOT NULL,
        isVariableInvestmentAmount INTEGER NOT NULL,
        variableInvestmentPercentage REAL NOT NULL,
        reinvestProfits INTEGER NOT NULL
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

    await db.execute('''
      CREATE TABLE portfolio (
        id TEXT PRIMARY KEY,
        assets TEXT NOT NULL,
        totalValue REAL NOT NULL,
        lastUpdated INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE portfolio_value (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        value REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE active_strategy (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        strategy_parameters TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_trades_symbol ON trades(symbol)
    ''');

    await db.execute('''
      CREATE INDEX idx_price_history_symbol_timestamp ON price_history(symbol, timestamp)
    ''');
  }

  Future<void> _upgradeDb(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
          'ALTER TABLE trades ADD COLUMN isVariableInvestment INTEGER NOT NULL DEFAULT 0');
      await db.execute('ALTER TABLE trades ADD COLUMN reinvestedProfit REAL');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS portfolio (
          id TEXT PRIMARY KEY,
          assets TEXT NOT NULL,
          totalValue REAL NOT NULL,
          lastUpdated INTEGER NOT NULL
        )
      ''');
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS portfolio_value (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL,
          value REAL NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS active_strategy (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          strategy_parameters TEXT NOT NULL
        )
      ''');
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

  Future<void> performMaintenance() async {
    Database db = await database;
    await db.execute('VACUUM');
    await db.execute('ANALYZE');
  }

  Future<bool> isDatabaseHealthy() async {
    try {
      Database db = await database;
      await db.rawQuery('SELECT 1');
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> backupDatabase() async {
    Database db = await database;
    String path = db.path;
    String backupPath = '$path.backup';
    await db.rawQuery('VACUUM INTO ?', [backupPath]);
  }

  Future<void> checkAndCleanupOldData() async {
    Database db = await database;
    final thirtyDaysAgo = DateTime.now()
        .subtract(const Duration(days: 30))
        .millisecondsSinceEpoch;

    await db.delete('price_history',
        where: 'timestamp < ?', whereArgs: [thirtyDaysAgo]);
    await db
        .delete('trades', where: 'timestamp < ?', whereArgs: [thirtyDaysAgo]);
  }

  Future<void> optimizeDatabasePerformance() async {
    Database db = await database;
    await db.execute('PRAGMA optimize');
  }

  Future<StrategyParameters?> getActiveStrategy() async {
    final db = await database;
    final results = await db.query('active_strategy', limit: 1);
    if (results.isNotEmpty) {
      final json = results.first['strategy_parameters'] as String;
      return StrategyParameters.fromJson(jsonDecode(json));
    }
    return null;
  }

  Future<double> getPortfolioValueForDate(DateTime date) async {
    final db = await database;
    final results = await db.query(
      'portfolio_value',
      where: 'date = ?',
      whereArgs: [date.toIso8601String().split('T')[0]],
      limit: 1,
    );
    if (results.isNotEmpty) {
      return results.first['value'] as double;
    }
    return 0.0;
  }

  Future<void> savePortfolioValue(DateTime date, double value) async {
    final db = await database;
    await db.insert(
      'portfolio_value',
      {
        'date': date.toIso8601String().split('T')[0],
        'value': value,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
