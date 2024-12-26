import 'dart:async';
import 'package:floor/floor.dart';
import 'package:weather/features/feature_bookmark/data/data_sources/local/city_dao.dart';
import 'package:weather/features/feature_bookmark/domain/entities/city_entity.dart';
import 'package:sqflite/sqflite.dart' as sqflite;



part 'database.g.dart';

@Database(version: 1, entities: [City])
abstract class AppDatabase extends FloorDatabase {
  CityDao1 get CityDao;
}
