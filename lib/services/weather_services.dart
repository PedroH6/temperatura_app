import 'dart:convert';
import 'package:app_temperatura/models/weather_model.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class WeatherServices {
  // URL base da API HG Brasil
  static const BASE_URL = "https://api.hgbrasil.com/weather";
  
  final String apiKey;
  
  WeatherServices(this.apiKey);
  
  // Buscar clima por nome da cidade
  Future<WeatherModel> getWeather(String cityName) async {
    try {
      // Construindo a URL com os parâmetros corretos da HG Brasil
      final url = '$BASE_URL?key=$apiKey&city_name=$cityName&format=json-cors';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Verificar se a API retornou erro
        if (data['valid_key'] == false) {
          throw Exception('Chave de API inválida');
        }
        
        if (data['results'] == null) {
          throw Exception('Cidade não encontrada');
        }
        
        return WeatherModel.fromJson(data);
      } else {
        throw Exception('Falha na requisição: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar dados meteorológicos: $e');
    }
  }
  
  // Buscar clima por coordenadas (lat, lon)
  Future<WeatherModel> getWeatherByCoordinates(double lat, double lon) async {
    try {
      final url = '$BASE_URL?key=$apiKey&lat=$lat&lon=$lon&format=json-cors';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['valid_key'] == false) {
          throw Exception('Chave de API inválida');
        }
        
        if (data['results'] == null) {
          throw Exception('Localização não encontrada');
        }
        
        return WeatherModel.fromJson(data);
      } else {
        throw Exception('Falha na requisição: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar dados meteorológicos: $e');
    }
  }
  
  // Obter clima da localização atual
  Future<WeatherModel> getCurrentLocationWeather() async {
    try {
      Position position = await _getCurrentPosition();
      return await getWeatherByCoordinates(position.latitude, position.longitude);
    } catch (e) {
      throw Exception('Erro ao obter clima da localização atual: $e');
    }
  }
  
  // Obter permissão do usuário e localização atual
  Future<String> getCurrentCity() async {
    try {
      Position position = await _getCurrentPosition();
      
      // Converter a localização em uma lista de objetos de marcadores
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      // Extrair o nome da cidade do primeiro marcador
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
  
  // Método auxiliar para obter posição atual
  Future<Position> _getCurrentPosition() async {
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
    
    // Buscar a localização atual
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100
      ),
    );
  }
}