
import 'package:weather/core/resourses/data_state.dart';
import 'package:weather/core/use_case/use_case.dart';
import 'package:weather/features/feature_bookmark/domain/entities/city_entity.dart';
import 'package:weather/features/feature_bookmark/domain/repositories/city_repository.dart';

class GetCityUseCase implements UseCase<DataState<City?>, String>{
  final CityRepository _cityRepository;
  GetCityUseCase(this._cityRepository);

  @override
  Future<DataState<City?>> call(String params) {
      return _cityRepository.findCityByName(params);
  }
}
