import 'package:alarm/alarm_info.dart';
import 'package:alarm/chart_info.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

final String tableChart = 'chart';
final String columnId = 'id';
final String columnTitle = 'time';
final String columnDiff = 'diff';


class ChartHelper {
  static Database _database;
  static ChartHelper _chartHelper;

  ChartHelper._createInstance();
  factory ChartHelper() {
    if (_chartHelper == null) {
      _chartHelper = ChartHelper._createInstance();
    }
    return _chartHelper;
  }

  ChartHelper._privateConstructor();
  static final ChartHelper instance = ChartHelper._privateConstructor();

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    var dir = await getDatabasesPath();
    var path = dir + "chart.db";

    var database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          create table $tableChart ( 
          $columnId integer primary key autoincrement, 
          $columnTitle text not null,
          $columnDiff integer)
        ''');

      },
    );
    return database;
  }

  void insertChart(ChartInfo chartInfo) async {
    var db = await this.database;
    var result = await db.insert(tableChart, chartInfo.toMap());
    print('result : $result');
  }

  Future<ChartInfo> getTodo(int id) async {
    var db = await this.database;
    List<Map> maps = await db.query(tableChart,
        columns: [columnId, columnDiff, columnTitle],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return ChartInfo.fromMap(maps.first);
    }
    return null;
  }

  Future<List<ChartInfo>> getChart() async {
    List<ChartInfo> _chart = [];

    var db = await this.database;
    var result = await db.query(tableChart);
    result.forEach((element) {
      var chartInfo = ChartInfo.fromMap(element);
      _chart.add(chartInfo);
    });

    return _chart;
  }



  Future<int> delete(int id) async {
    var db = await this.database;
    return await db.delete(tableChart, where: '$columnId = ?', whereArgs: [id]);
  }

 
}
