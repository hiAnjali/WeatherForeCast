import 'dart:convert';

import 'package:weather/constants.dart';
import 'package:http/http.dart' as http;
import 'package:weather/model.dart';

class weatherApi{
  final String baseURL = "http://api.weatherapi.com/v1/current.json";

  Future<ApiResponse> getCurrentWeather(String location) async{
    String ApiUrl = "$baseURL?key=$APIKey&q=$location";
    try {
      final response = await http.get(Uri.parse(ApiUrl));
      if (response.statusCode == 200) {
        return ApiResponse.fromJson(jsonDecode(response.body));
      }else{
        throw Exception("Failed to load weather");
      }
    } catch (e) {
      throw Exception("Failed to load weather");
    }
  }

  getCurrentWeatherByCoordinates(double latitude, double longitude) {}
}