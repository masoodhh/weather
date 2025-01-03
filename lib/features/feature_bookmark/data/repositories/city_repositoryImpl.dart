
import 'package:weather/core/resourses/data_state.dart';
import 'package:weather/features/feature_bookmark/data/data_sources/local/city_dao.dart';
import 'package:weather/features/feature_bookmark/domain/entities/city_entity.dart';
import 'package:weather/features/feature_bookmark/domain/repositories/city_repository.dart';

class CityRepositoryImpl extends CityRepository{
  CityDao1 cityDao;
  CityRepositoryImpl(this.cityDao);


  /// call save city to DB and set status
  @override
  Future<DataState<City>> saveCityToDB(String cityName) async{
    try{

      // check city exist or not
      final City? checkCity = await cityDao.findCityByName(cityName);
      if(checkCity != null){
        return DataFailed("$cityName has Already exist");
      }

      // insert city to database
      final City city = City(name: cityName);
      await cityDao.insertCity(city);
      return DataSuccess(city);

    }catch(e){
      return DataFailed(e.toString());
    }
  }

  /// call get All city from DB and set status
  @override
  Future<DataState<List<City>>> getAllCityFromDB() async {
    try{
      final List<City> cities =  await cityDao.getAllCity();
      return DataSuccess(cities);
    }catch(e){
      return DataFailed(e.toString());
    }
  }

  /// call  get city by name from DB and set status
  @override
  Future<DataState<City?>> findCityByName(String name) async {
    try{
      final City? city =  await cityDao.findCityByName(name);
      return DataSuccess(city);
    }catch(e){
      return DataFailed(e.toString());
    }
  }

  @override
  Future<DataState<String>> deleteCityByName(String name) async {
    try{
      await cityDao.deleteCityByName(name);
      return DataSuccess(name);
    }catch(e){
      return DataFailed(e.toString());
    }
  }


}
