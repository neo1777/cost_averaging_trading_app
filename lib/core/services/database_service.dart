import 'package:cost_averaging_trading_app/core/models/trade.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:cost_averaging_trading_app/core/error/error_handler.dart';

class DatabaseService {
  static Database? _database;
  static DatabaseService? _instance;

  DatabaseService._();

  static Future<DatabaseService> getInstance() async {
    if (_instance == null) {
      _instance = DatabaseService._();
      await _instance!._initDatabase();
    }
    return _instance!;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      if (!kIsWeb) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }

      String path = join(await getDatabasesPath(), 'cost_averaging_trading.db');
      //deleteDatabase(path);
      return await openDatabase(
        path,
        version: 2,
        onCreate: _createDb,
        onUpgrade: _upgradeDb,
      );
    } catch (e, stackTrace) {
      ErrorHandler.logError('Failed to initialize database', e, stackTrace);
      throw Exception('Impossibile inizializzare il database');
    }
  }

  Future<void> _createDb(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE trades(
          id TEXT PRIMARY KEY,
          symbol TEXT,
          amount REAL,
          price REAL,
          timestamp INTEGER
        )
      ''');

      await db.execute('''
        CREATE TABLE portfolio(
          id TEXT PRIMARY KEY,
          assets TEXT,
          totalValue REAL
        )
      ''');

      await db.execute('''
        CREATE TABLE strategy_parameters(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          symbol TEXT,
          investmentAmount REAL,
          intervalDays INTEGER,
          targetProfitPercentage REAL,
          stopLossPercentage REAL
        )
      ''');

      await db.execute('''
      CREATE TABLE strategy_status(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        status TEXT
      )
    ''');
    } catch (e, stackTrace) {
      ErrorHandler.logError('Failed to create database tables', e, stackTrace);
      throw Exception('Impossibile creare le tabelle del database');
    }
  }

  Future<void> _upgradeDb(Database db, int oldVersion, int newVersion) async {
    try {
      if (oldVersion < 2) {
        await db.execute('''
          CREATE TABLE strategy_parameters(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            symbol TEXT,
            investmentAmount REAL,
            intervalDays INTEGER,
            targetProfitPercentage REAL,
            stopLossPercentage REAL
          )
        ''');
      }
    } catch (e, stackTrace) {
      ErrorHandler.logError('Failed to upgrade database', e, stackTrace);
      throw Exception('Impossibile aggiornare il database');
    }
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    try {
      Database db = await database;
      return await db.insert(table, data,
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e, stackTrace) {
      ErrorHandler.logError('Failed to insert data into $table', e, stackTrace);
      throw Exception('Impossibile inserire i dati nella tabella $table');
    }
  }

  Future<List<Map<String, dynamic>>> query(String table) async {
    try {
      Database db = await database;
      final result = await db.query(table);
      return result;
    } catch (e) {
      throw Exception('Failed to query $table: $e');
    }
  }

  Future<int> update(String table, Map<String, dynamic> data) async {
    try {
      Database db = await database;
      String id = data['id'];
      return await db.update(table, data, where: 'id = ?', whereArgs: [id]);
    } catch (e, stackTrace) {
      ErrorHandler.logError('Failed to update data in $table', e, stackTrace);
      throw Exception('Impossibile aggiornare i dati nella tabella $table');
    }
  }

  Future<int> delete(String table, String id) async {
    try {
      Database db = await database;
      return await db.delete(table, where: 'id = ?', whereArgs: [id]);
    } catch (e, stackTrace) {
      ErrorHandler.logError('Failed to delete data from $table', e, stackTrace);
      throw Exception('Impossibile eliminare i dati dalla tabella $table');
    }
  }

  Future<List<Map<String, dynamic>>> getRecentTrades(
      String symbol, DateTime since) async {
    try {
      Database db = await database;
      return await db.query(
        'trades',
        where: 'symbol = ? AND timestamp > ?',
        whereArgs: [symbol, since.millisecondsSinceEpoch],
      );
    } catch (e, stackTrace) {
      ErrorHandler.logError('Failed to get recent trades', e, stackTrace);
      throw Exception('Impossibile ottenere i trade recenti');
    }
  }

  Future<List<Map<String, dynamic>>> getTodayTrades(String symbol) async {
    try {
      Database db = await database;
      var startOfDay = DateTime.now().subtract(Duration(
          hours: DateTime.now().hour,
          minutes: DateTime.now().minute,
          seconds: DateTime.now().second,
          milliseconds: DateTime.now().millisecond,
          microseconds: DateTime.now().microsecond));
      return await db.query(
        'trades',
        where: 'symbol = ? AND timestamp > ?',
        whereArgs: [symbol, startOfDay.millisecondsSinceEpoch],
      );
    } catch (e, stackTrace) {
      ErrorHandler.logError('Failed to get today\'s trades', e, stackTrace);
      throw Exception('Impossibile ottenere i trade di oggi');
    }
  }

  Future<CoreTrade?> getLastTrade(String symbol) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'trades',
      where: 'symbol = ?',
      whereArgs: [symbol],
      orderBy: 'timestamp DESC',
      limit: 1,
    );

    if (result.isNotEmpty) {
      return CoreTrade.fromJson(result.first);
    }
    return null;
  }
}
