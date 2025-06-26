import 'dart:convert';

import 'package:app_temperatura/models/weather_model.dart';
import 'package:http/http.dart' as http;

class WeatherServices {
  static const BASE_URL = "http://api.openweathermap.org/data/3.0/weather";

  final String apiKey;

  WeatherServices(this.apiKey);

  Future<WeatherModel> getWeather(String cityName) async {
    final response = await http.get(
      Uri.parse('$BASE_URL?q=$cityName&appid=$apiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      return WeatherModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Fracassada');
    }
  }
}
