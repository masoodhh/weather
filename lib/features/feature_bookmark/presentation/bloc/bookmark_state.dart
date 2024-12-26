part of 'bookmark_bloc.dart';

enum Status { initial, loading, completed, error }

class BookmarkState {
  final Status status;
  final List<City> cities;
  final String? error;

  BookmarkState({
    required this.status,
    required this.cities,
    this.error,
  });

  factory BookmarkState.initial() => BookmarkState(
        status: Status.initial,
        cities: [],
      );

  BookmarkState copyWith({
    Status? newStatus,
    List<City>? newCities,
    String? newError,
  }) {
    return BookmarkState(
      status: newStatus ?? status,
      cities: newCities ?? cities,
      error: newError,
    );
  }
}
