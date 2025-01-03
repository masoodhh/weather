import 'package:weather/features/feature_bookmark/data/data_sources/local/database.dart';
import 'package:weather/features/feature_bookmark/data/repositories/city_repositoryImpl.dart';
import 'package:weather/features/feature_bookmark/domain/repositories/city_repository.dart';
import 'package:weather/features/feature_bookmark/domain/usecases/delete_city_usecase.dart';
import 'package:weather/features/feature_bookmark/domain/usecases/get_all_city_usecase.dart';
import 'package:weather/features/feature_bookmark/domain/usecases/get_city_usecase.dart';
import 'package:weather/features/feature_bookmark/domain/usecases/save_city_usecase.dart';
import 'package:weather/features/feature_bookmark/presentation/bloc/bookmark_bloc.dart';
import 'package:weather/features/feature_weather/data/data_source/remote/api_provider.dart';
import 'package:weather/features/feature_weather/data/repository/weather_repository_impl.dart';
import 'package:weather/features/feature_weather/domain/repository/weather_repository.dart';
import 'package:weather/features/feature_weather/domain/use_cases/get_current_weather_use_case.dart';
import 'package:weather/features/feature_weather/domain/use_cases/get_forecast_weather_usecase.dart';
import 'package:weather/features/feature_weather/presentation/bloc/home_bloc.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.instance;

setup() async {
  locator.registerSingleton<ApiProvider>(ApiProvider());

  final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  locator.registerSingleton<AppDatabase>(database);

  /// repositories
  locator.registerSingleton<WeatherRepository>(WeatherRepositoryImpl(locator()));
  locator.registerSingleton<CityRepository>(CityRepositoryImpl(database.CityDao));

  /// use case
  locator.registerSingleton<GetCurrentWeatherUseCase>(GetCurrentWeatherUseCase(locator()));
  locator.registerSingleton<GetForecastWeatherUseCase>(GetForecastWeatherUseCase(locator()));
  locator.registerSingleton<GetCityUseCase>(GetCityUseCase(locator()));
  locator.registerSingleton<SaveCityUseCase>(SaveCityUseCase(locator()));
  locator.registerSingleton<GetAllCityUseCase>(GetAllCityUseCase(locator()));
  locator.registerSingleton<DeleteCityUseCase>(DeleteCityUseCase(locator()));

  locator.registerSingleton<HomeBloc>(HomeBloc());
  locator.registerSingleton<BookmarkBloc>(BookmarkBloc());
}
