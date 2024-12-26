import 'package:bloc/bloc.dart';
import 'package:logger/logger.dart';
import 'package:weather/core/resourses/data_state.dart';
import 'package:weather/core/use_case/use_case.dart';
import 'package:weather/features/feature_bookmark/domain/usecases/delete_city_usecase.dart';
import 'package:weather/features/feature_bookmark/domain/usecases/get_all_city_usecase.dart';
import 'package:weather/features/feature_bookmark/domain/usecases/get_city_usecase.dart';
import 'package:weather/features/feature_bookmark/domain/usecases/save_city_usecase.dart';
import 'package:meta/meta.dart';

import '../../../../locator.dart';
import '../../domain/entities/city_entity.dart';

part 'bookmark_event.dart';

part 'bookmark_state.dart';

class BookmarkBloc extends Bloc<BookmarkEvent, BookmarkState> {
  final GetCityUseCase getCityUseCase = locator();
  final SaveCityUseCase saveCityUseCase = locator();
  final GetAllCityUseCase getAllCityUseCase = locator();
  final DeleteCityUseCase deleteCityUseCase = locator();
  Logger logger = Logger();

  BookmarkBloc() : super(BookmarkState.initial()) {
    on<DeleteCityEvent>(_onDeleteCity);
    on<GetAllCityEvent>(_onGetAllCity);
    // on<GetCityByNameEvent>(_onGetCityByName);
    on<SaveCwEvent>(_onSaveCity);
    on<SaveCityInitialEvent>(_onSaveCityInitial);
  }

  Future<void> _onDeleteCity(DeleteCityEvent event, Emitter<BookmarkState> emit) async {
    emit(state.copyWith(newStatus: Status.loading));
    // emit(state.copyWith(newDeleteCityStatus: DeleteCityLoading()));

    final DataState dataState = await deleteCityUseCase(event.name);

    if (dataState is DataSuccess) {
      final DataState dataState2 = await getAllCityUseCase(NoParams());
      if (dataState2 is DataSuccess) {
        emit(state.copyWith(newStatus: Status.completed, newCities: dataState2.data));
        // emit(state.copyWith(newGetAllCityStatus: GetAllCityCompleted(dataState.data)));
      } else if (dataState2 is DataFailed) {
        emit(state.copyWith(newStatus: Status.error, newError: dataState2.error));
        // emit(state.copyWith(newGetAllCityStatus: GetAllCityError(dataState.error)));
      }
      // emit(state.copyWith(newDeleteCityStatus: DeleteCityCompleted(dataState.data)));
    } else if (dataState is DataFailed) {
      emit(state.copyWith(newStatus: Status.error, newError: dataState.error));
      // emit(state.copyWith(newDeleteCityStatus: DeleteCityError(dataState.error)));
    }
  }

  Future<void> _onGetAllCity(GetAllCityEvent event, Emitter<BookmarkState> emit) async {
    emit(state.copyWith(newStatus: Status.loading));
    // emit(state.copyWith(newGetAllCityStatus: GetAllCityLoading()));

    final DataState dataState = await getAllCityUseCase(NoParams());

    if (dataState is DataSuccess) {
      emit(state.copyWith(newStatus: Status.completed, newCities: dataState.data));
      // emit(state.copyWith(newGetAllCityStatus: GetAllCityCompleted(dataState.data)));
    } else if (dataState is DataFailed) {
      emit(state.copyWith(newStatus: Status.error, newError: dataState.error));
      // emit(state.copyWith(newGetAllCityStatus: GetAllCityError(dataState.error)));
    }
  }

/*
  Future<void> _onGetCityByName(GetCityByNameEvent event, Emitter<BookmarkState> emit) async {
    emit(state.copyWith(newStatus: Status.loading));
    // emit(state.copyWith(newCityStatus: GetCityLoading()));

    final DataState dataState = await getCityUseCase(event.cityName);

    if (dataState is DataSuccess) {
      emit(state.copyWith(newStatus: Status.completed,newCities: dataState.data));
      // emit(state.copyWith(newCityStatus: GetCityCompleted(dataState.data)));
    } else if (dataState is DataFailed) {
      emit(state.copyWith(newStatus: Status.error,newError:dataState.error ));
      // emit(state.copyWith(newCityStatus: GetCityError(dataState.error)));
    }
  }
*/

  Future<void> _onSaveCity(SaveCwEvent event, Emitter<BookmarkState> emit) async {
    emit(state.copyWith(newStatus: Status.loading));
    // emit(state.copyWith(newSaveStatus: SaveCityLoading()));

    final DataState dataState = await saveCityUseCase(event.name);

    if (dataState is DataSuccess) {
      logger.i(dataState.data);
      final List<City> cities = state.cities;
      cities.add(dataState.data);
      emit(state.copyWith(newStatus: Status.completed, newCities: cities));
      // emit(state.copyWith(newSaveStatus: SaveCityCompleted(dataState.data)));
    } else if (dataState is DataFailed) {
      logger.i(dataState.error);
      emit(state.copyWith(newStatus: Status.error, newError: dataState.error));
      // emit(state.copyWith(newSaveStatus: SaveCityError(dataState.error)));
    }
  }

  void _onSaveCityInitial(SaveCityInitialEvent event, Emitter<BookmarkState> emit) {
    emit(state.copyWith(newStatus: Status.initial));
    // emit(state.copyWith(newSaveStatus: SaveCityInitial()));
  }
}
