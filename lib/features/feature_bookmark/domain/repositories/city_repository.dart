import 'package:weather/core/resourses/data_state.dart';
import 'package:weather/features/feature_bookmark/domain/entities/city_entity.dart';

abstract class CityRepository {
  Future<DataState<City>> saveCityToDB(String name);
  Future<DataState<List<City>>> getAllCityFromDB();
  Future<DataState<City?>> findCityByName(String name);
  Future<DataState<String>> deleteCityByName(String name);
}
