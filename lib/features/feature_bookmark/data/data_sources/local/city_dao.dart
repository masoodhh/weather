import 'package:floor/floor.dart';
import 'package:weather/features/feature_bookmark/domain/entities/city_entity.dart';

@dao
abstract class CityDao1 {
  @Query('SELECT * FROM city')
  Future<List<City>> getAllCity();

  @Query('SELECT * FROM city WHERE name= :name')
  Future<City?> findCityByName(String name);

  @insert
  Future<void> insertCity(City city);

  @Query("DELETE FROM city WHERE name = :name")
  Future<void> deleteCityByName(String name);
}
