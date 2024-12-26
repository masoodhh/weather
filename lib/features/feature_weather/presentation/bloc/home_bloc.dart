import 'package:bloc/bloc.dart';
import 'package:weather/core/params/ForecastParams.dart';
import 'package:weather/core/resourses/data_state.dart';
import 'package:weather/features/feature_weather/domain/use_cases/get_current_weather_use_case.dart';
import 'package:weather/features/feature_weather/domain/use_cases/get_forecast_weather_usecase.dart';
import 'package:weather/features/feature_weather/presentation/bloc/cw_status.dart';
import 'package:weather/features/feature_weather/presentation/bloc/fw_status.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';

import '../../../../locator.dart';

part 'home_event.dart';

part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetCurrentWeatherUseCase getCurrentWeatherUseCase = locator();
  final GetForecastWeatherUseCase _getForecastWeatherUseCase = locator();

  Logger logger = Logger();

  HomeBloc() : super(HomeState.initial()) {
    on<LoadCwEvent>((event, emit) => _loadCurrentWeather(event, emit));
    on<LoadFwEvent>((event, emit) => _loadForecastWeather(event, emit));
  }

  Future<void> _loadCurrentWeather(LoadCwEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(newCwStatus: CwLoading()));

    final DataState dataState = await getCurrentWeatherUseCase(event.cityName);

    if (dataState is DataSuccess) {
      emit(state.copyWith(newCwStatus: CwCompleted(dataState.data)));
    } else if (dataState is DataFailed) {
      emit(state.copyWith(newCwStatus: CwError(dataState.error!)));
    }
  }

  Future<void> _loadForecastWeather(LoadFwEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(newFwStatus: FwLoading()));

    final DataState dataState = await _getForecastWeatherUseCase(event.forecastParams);

    if (dataState is DataSuccess) {
      emit(state.copyWith(newFwStatus: FwCompleted(dataState.data)));
    } else if (dataState is DataFailed) {
      emit(state.copyWith(newFwStatus: FwError(dataState.error)));
    }
  }
}
