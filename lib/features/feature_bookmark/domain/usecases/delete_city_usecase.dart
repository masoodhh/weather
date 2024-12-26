
import 'package:weather/core/resourses/data_state.dart';
import 'package:weather/core/use_case/use_case.dart';
import 'package:weather/features/feature_bookmark/domain/repositories/city_repository.dart';

class DeleteCityUseCase implements UseCase<DataState<String>, String>{
  final CityRepository _cityRepository;
  DeleteCityUseCase(this._cityRepository);

  @override
  Future<DataState<String>> call(String params) {
    return _cityRepository.deleteCityByName(params);
  }
}
