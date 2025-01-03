import 'package:dio/dio.dart';
import 'package:weather/core/params/ForecastParams.dart';
import 'package:weather/core/utils/constants.dart';
class ApiProvider {
  final Dio _dio = Dio();
  String apiKey = Constants.apiKey1;
  String apiKey2 = Constants.apiKey2;

  //current weather api call
  Future<dynamic> callCurrentWeather(cityName) async {
    final response = await _dio
        .get("${Constants.baseUrl}/data/2.5/weather", queryParameters: {
      'q': cityName,
      'appid': apiKey,
      'units': "metric",
    },);
    return response;
  }

  /// 7 days forecast api
  Future<dynamic> sendRequest7DaysForcast(ForecastParams params) async {

    final response = await _dio.get(
        "${Constants.baseUrl2}/data/2.5/onecall",
        queryParameters: {
          'lat': params.lat,
          'lon': params.lon,
          'exclude': 'minutely,hourly',
          'appid': apiKey2,
          'units': 'metric',
        },);

    return response;
  }

  /// city name suggest api
  Future<dynamic> sendRequestCitySuggestion(String prefix) async {
    final response = await _dio.get(
        "http://geodb-free-service.wirefreethought.com/v1/geo/cities",
        queryParameters: {'limit': 7, 'offset': 0, 'namePrefix': prefix},);

    return response;
  }
}
