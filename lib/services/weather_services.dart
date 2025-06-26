import 'dart:convert'; // Para converter JSON em objetos Dart
import 'package:app_temperatura/models/weather_model.dart'; // Modelo de dados personalizado para representar informações meteorológicas
import 'package:http/http.dart' as http; // Para fazer requisições HTTP

class WeatherServices {
  //URL base da API do OpenWeatherMap
  static const BASE_URL = "http://api.openweathermap.org/data/2.5/weather";

  final String apiKey; //Chave de API necessária para autenticação

  WeatherServices(this.apiKey);

  Future<WeatherModel> getWeather(String cityName) async {
    //Fazendo a requisição
    final response = await http.get(
      Uri.parse('$BASE_URL?q=$cityName&appid=$apiKey&units=metric'), 
    );

    //Se a requisição foi bem-sucedida (código 200), converte o JSON em um objeto
    if (response.statusCode == 200) {
      return WeatherModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Fracassada'); //Caso contrário, lança uma exceção ERROR
    }
  }
}
