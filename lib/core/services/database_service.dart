import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:cost_averaging_trading_app/features/strategy/models/strategy_parameters.dart';

class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'trading_strategy_1777_47.db';
  static const int _databaseVersion = 1;

  Future<void> initDatabase() async {
    if (_database != null) return;
    String path = join(await getDatabasesPath(), _databaseName);
    try {
      print("Attempting to open database at $path");
      _database = await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _createDb,
        onUpgrade: _upgradeDb,
        onConfigure: _configureDb,
      );
      print("Database opened successfully");
    } catch (e) {
      print("Error initializing database: $e");
      print("Attempting to delete and recreate database");
      await deleteDatabase(path);
      _database = await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _createDb,
        onUpgrade: _upgradeDb,
        onConfigure: _configureDb,
      );
    }
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
    print("Creating new database...");

    await _createTableIfNotExists(db, 'trades', '''
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

    await _createTableIfNotExists(db, 'strategy_parameters', '''
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

    await _createTableIfNotExists(db, 'strategy_status', '''
      CREATE TABLE strategy_status(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        status TEXT NOT NULL
      )
    ''');

    await _createTableIfNotExists(db, 'price_history', '''
      CREATE TABLE price_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        symbol TEXT NOT NULL,
        price REAL NOT NULL,
        timestamp INTEGER NOT NULL
      )
    ''');

    await _createTableIfNotExists(db, 'portfolio', '''
      CREATE TABLE portfolio (
        id TEXT PRIMARY KEY,
        assets TEXT NOT NULL,
        totalValue REAL NOT NULL,
        lastUpdated INTEGER NOT NULL
      )
    ''');

    await _createTableIfNotExists(db, 'portfolio_value', '''
      CREATE TABLE portfolio_value (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp INTEGER NOT NULL,
        value REAL NOT NULL
      )
    ''');

    await _createTableIfNotExists(db, 'active_strategy', '''
      CREATE TABLE active_strategy (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        strategy_parameters TEXT NOT NULL
      )
    ''');

    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_trades_symbol ON trades(symbol)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_price_history_symbol_timestamp ON price_history(symbol, timestamp)');

    print("Database creation completed");
  }

  Future<void> _createTableIfNotExists(
      Database db, String tableName, String createTableSql) async {
    print("Checking if table $tableName exists...");
    var tableExists = await _checkIfTableExists(db, tableName);
    if (!tableExists) {
      print("Creating table $tableName");
      await db.execute(createTableSql);
      print("Table $tableName created successfully");
    } else {
      print("Table $tableName already exists");
    }
  }

  Future<bool> _checkIfTableExists(Database db, String tableName) async {
    var result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
        [tableName]);
    return result.isNotEmpty;
  }

  Future<void> _upgradeDb(Database db, int oldVersion, int newVersion) async {
    print("Upgrading database from $oldVersion to $newVersion");
    // Add upgrade logic here if needed in the future
  }

  Future<void> savePortfolioValue(DateTime date, double value) async {
    final db = await database;
    await db.insert(
      'portfolio_value',
      {
        'timestamp': date.millisecondsSinceEpoch,
        'value': value,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<double> getPortfolioValueForDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final List<Map<String, dynamic>> result = await db.query(
      'portfolio_value',
      where: 'timestamp >= ? AND timestamp < ?',
      whereArgs: [
        startOfDay.millisecondsSinceEpoch,
        endOfDay.millisecondsSinceEpoch
      ],
      orderBy: 'timestamp DESC',
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first['value'] as double;
    } else {
      // Invece di lanciare un'eccezione, restituiamo 0.0
      return 0.0;
    }
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
    final db = await database;
    return db.query(
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

  // Future<void> _createDb(Database db, int version) async {
  //   print("Creating new database...");
  //   await db.execute('''
  //     CREATE TABLE IF NOT EXISTS trades(
  //       id TEXT PRIMARY KEY,
  //       symbol TEXT NOT NULL,
  //       amount REAL NOT NULL,
  //       price REAL NOT NULL,
  //       timestamp INTEGER NOT NULL,
  //       type TEXT NOT NULL,
  //       isVariableInvestment INTEGER NOT NULL,
  //       reinvestedProfit REAL
  //     )
  //   ''');

  //   await db.execute('''
  //     CREATE TABLE strategy_parameters(
  //       id INTEGER PRIMARY KEY AUTOINCREMENT,
  //       symbol TEXT NOT NULL,
  //       investmentAmount REAL NOT NULL,
  //       intervalDays INTEGER NOT NULL,
  //       targetProfitPercentage REAL NOT NULL,
  //       stopLossPercentage REAL NOT NULL,
  //       purchaseFrequency INTEGER NOT NULL,
  //       maxInvestmentSize REAL NOT NULL,
  //       useAutoMinTradeAmount INTEGER NOT NULL,
  //       manualMinTradeAmount REAL NOT NULL,
  //       isVariableInvestmentAmount INTEGER NOT NULL,
  //       variableInvestmentPercentage REAL NOT NULL,
  //       reinvestProfits INTEGER NOT NULL
  //     )
  //   ''');

  //   await db.execute('''
  //     CREATE TABLE strategy_status(
  //       id INTEGER PRIMARY KEY AUTOINCREMENT,
  //       status TEXT NOT NULL
  //     )
  //   ''');

  //   await db.execute('''
  //     CREATE TABLE price_history (
  //       id INTEGER PRIMARY KEY AUTOINCREMENT,
  //       symbol TEXT NOT NULL,
  //       price REAL NOT NULL,
  //       timestamp INTEGER NOT NULL
  //     )
  //   ''');

  //   await db.execute('''
  //     CREATE TABLE portfolio (
  //       id TEXT PRIMARY KEY,
  //       assets TEXT NOT NULL,
  //       totalValue REAL NOT NULL,
  //       lastUpdated INTEGER NOT NULL
  //     )
  //   ''');

  //   await db.execute('''
  //     CREATE TABLE IF NOT EXISTS portfolio_value (
  //       id INTEGER PRIMARY KEY AUTOINCREMENT,
  //       timestamp INTEGER NOT NULL,
  //       value REAL NOT NULL
  //     )
  //   ''');

  //   await db.execute('''
  //     CREATE TABLE active_strategy (
  //       id INTEGER PRIMARY KEY AUTOINCREMENT,
  //       strategy_parameters TEXT NOT NULL
  //     )
  //   ''');

  //   await db.execute('''
  //     CREATE INDEX idx_trades_symbol ON trades(symbol)
  //   ''');

  //   await db.execute('''
  //     CREATE INDEX idx_price_history_symbol_timestamp ON price_history(symbol, timestamp)
  //   ''');

  //   await db.execute('''
  //     CREATE TABLE portfolio_value (
  //       id INTEGER PRIMARY KEY AUTOINCREMENT,
  //       timestamp INTEGER NOT NULL,
  //       value REAL NOT NULL
  //     )
  //   ''');
  //   await _createPortfolioValueTable(db);
  // }

  Future<void> _createPortfolioValueTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS portfolio_value (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp INTEGER NOT NULL,
        value REAL NOT NULL
      )
    ''');
  }

  // Future<void> _upgradeDb(Database db, int oldVersion, int newVersion) async {
  //   if (oldVersion < 2) {
  //     await db.execute(
  //         'ALTER TABLE trades ADD COLUMN isVariableInvestment INTEGER NOT NULL DEFAULT 0');
  //     await db.execute('ALTER TABLE trades ADD COLUMN reinvestedProfit REAL');
  //   }
  //   if (oldVersion < 3) {
  //     await db.execute('''
  //       CREATE TABLE IF NOT EXISTS portfolio (
  //         id TEXT PRIMARY KEY,
  //         assets TEXT NOT NULL,
  //         totalValue REAL NOT NULL,
  //         lastUpdated INTEGER NOT NULL
  //       )
  //     ''');
  //   }
  //   if (oldVersion < 4) {
  //     await _createPortfolioValueTable(db);
  //   }
  //   if (oldVersion < 5) {
  //     // Assicuriamoci che la tabella portfolio_value abbia la struttura corretta
  //     await db.execute('''
  //       CREATE TABLE IF NOT EXISTS portfolio_value (
  //         id INTEGER PRIMARY KEY AUTOINCREMENT,
  //         timestamp INTEGER NOT NULL,
  //         value REAL NOT NULL
  //       )
  //     ''');
  //   }
  // }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    Database db = await database;
    return await db.insert(table, data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Future<List<Map<String, dynamic>>> query(
  //   String table, {
  //   bool? distinct,
  //   List<String>? columns,
  //   String? where,
  //   List<Object?>? whereArgs,
  //   String? groupBy,
  //   String? having,
  //   String? orderBy,
  //   int? limit,
  //   int? offset,
  // }) async {
  //   Database db = await database;
  //   return await db.query(
  //     table,
  //     distinct: distinct,
  //     columns: columns,
  //     where: where,
  //     whereArgs: whereArgs,
  //     groupBy: groupBy,
  //     having: having,
  //     orderBy: orderBy,
  //     limit: limit,
  //     offset: offset,
  //   );
  // }

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

  // Future<double> getPortfolioValueForDate(DateTime date) async {
  //   final db = await database;
  //   final results = await db.query(
  //     'portfolio_value',
  //     where: 'date = ?',
  //     whereArgs: [date.toIso8601String().split('T')[0]],
  //     limit: 1,
  //   );
  //   if (results.isNotEmpty) {
  //     return results.first['value'] as double;
  //   }
  //   return 0.0;
  // }

  // Future<void> savePortfolioValue(DateTime date, double value) async {
  //   final db = await database;
  //   await db.insert(
  //     'portfolio_value',
  //     {
  //       'date': date.toIso8601String().split('T')[0],
  //       'value': value,
  //     },
  //     conflictAlgorithm: ConflictAlgorithm.replace,
  //   );
  // }
}
