import 'dart:convert'; // Para converter JSON em objetos Dart
import 'package:app_temperatura/models/weather_model.dart'; // Modelo de dados personalizado para representar informações meteorológicas
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart'; // ✅ Import correto
import 'package:http/http.dart' as http; // Para fazer requisições HTTP

class WeatherServices {
  //URL base da API do OpenWeatherMap
  static const BASE_URL = "http://api.openweathermap.org/data/2.5/weather";
  
  final String apiKey; //Chave de API necessária para autenticação
  
  WeatherServices(this.apiKey);
  
  Future<WeatherModel> getWeather(String cityName) async {
    try {
      //Fazendo a requisição
      final response = await http.get(
        Uri.parse('$BASE_URL?q=$cityName&appid=$apiKey&units=metric'),
      );
      
      //Se a requisição foi bem-sucedida (código 200), converte o JSON em um objeto
      if (response.statusCode == 200) {
        return WeatherModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Falha na requisição: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar dados meteorológicos: $e');
    }
  }
  
  // obter permissão do usuário e localização atual
  Future<String> getCurrentCity() async { // ✅ Corrigido: getCurrentCity (não getCurrentCirty)
    try {
      // Verifica permissão atual
      LocationPermission permission = await Geolocator.checkPermission();
      
      // Se negada, solicita permissão
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      // Se ainda negada ou negada permanentemente, lança exceção
      if (permission == LocationPermission.denied || 
          permission == LocationPermission.deniedForever) {
        throw Exception('Permissão de localização negada');
      }
      
      // Verifica se o serviço de localização está habilitado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Serviço de localização desabilitado');
      }
      
      //buscar a localização atual
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100
        ),
      );
      
      //converter a localização em uma lista de objetos de marcadores
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      //extrair o nome da cidade do primeiro marcador
      if (placemarks.isNotEmpty) {
        String? city = placemarks[0].locality;
        return city ?? placemarks[0].subAdministrativeArea ?? "Cidade desconhecida";
      } else {
        throw Exception('Não foi possível determinar a cidade');
      }
      
    } catch (e) {
      throw Exception('Erro ao obter localização: $e');
    }
  }
}