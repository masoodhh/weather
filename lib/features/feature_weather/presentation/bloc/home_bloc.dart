import 'package:bloc/bloc.dart';
import 'package:weather/core/params/ForecastParams.dart';
import 'package:weather/core/resourses/data_state.dart';
import 'package:weather/features/feature_weather/domain/use_cases/get_current_weather_use_case.dart';
import 'package:weather/features/feature_weather/domain/use_cases/get_forecast_weather_usecase.dart';
import 'package:weather/features/feature_weather/presentation/bloc/cw_status.dart';
import 'package:weather/features/feature_weather/presentation/bloc/fw_status.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetCurrentWeatherUseCase getCurrentWeatherUseCase;
  final GetForecastWeatherUseCase _getForecastWeatherUseCase;

  Logger logger = Logger();
  HomeBloc(this.getCurrentWeatherUseCase, this._getForecastWeatherUseCase)
      : super(HomeState(cwStatus: CwLoading(), fwStatus: FwLoading())) {
    on<LoadCwEvent>((event, emit) async {
      emit(state.copyWith(newCwStatus: CwLoading()));
      final DataState dataState = await getCurrentWeatherUseCase(event.cityName);
      if (dataState is DataSuccess) {
        logger.w('DataSuccess');
        emit(state.copyWith(newCwStatus: CwCompleted(dataState.data)));
      } else if (dataState is DataFailed) {
        logger.w('DataFailed');
        emit(state.copyWith(newCwStatus: CwError(dataState.error!)));
      }
    });

    /// load 7 days Forecast weather for city Event
    on<LoadFwEvent>((event, emit) async {
      /// emit State to Loading for just Fw
      emit(state.copyWith(newFwStatus: FwLoading()));

      final DataState dataState =
          await _getForecastWeatherUseCase(event.forecastParams);

      /// emit State to Completed for just Fw
      if (dataState is DataSuccess) {
        emit(state.copyWith(newFwStatus: FwCompleted(dataState.data)));
      }

      /// emit State to Error for just Fw
      if (dataState is DataFailed) {
        emit(state.copyWith(newFwStatus: FwError(dataState.error)));
      }
    });
  }
}
