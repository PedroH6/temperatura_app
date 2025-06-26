import 'package:app_temperatura/models/weather_model.dart';
import 'package:app_temperatura/services/weather_services.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  //Api key
  final _WeatherService = WeatherServices('231a9e84e19ee43e501d95edaec5364b');
  WeatherModel? _weatherModel;

  //Buscar previsão do tempo
  _fetchWeather() async {
    //obter a cidade atual
    String cityName = await _WeatherService.getCurrentCity();

    //obter previsão do tempo para cidade
    try {
      final weather = await _WeatherService.getWeather(cityName);
      setState(() {
        _weatherModel = weather;
      });
    }
    //quaisquer erros
    catch (e) {
      print(e);
    }
  }

  //Animação do clima
  String getWeatherAnimattion(String? mainCondition) {
    if (mainCondition == null) return 'assets/sunny.json';

    switch (mainCondition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'assets/cloud.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/rainy.json';
      case 'thunderstorm':
        return 'assets/thunder.json';
      case 'clear':
        return 'assets/sunny.json';
      default:
        return 'assets/sunny.json';
    }
  }

  //init state
  @override
  void initState() {
    super.initState();

    //buscar previsão do tempo na inicialização
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[400],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //city name
            Text(_weatherModel?.cityName ?? "loading city..."),

            // animation
            Lottie.asset(getWeatherAnimattion(_weatherModel?.mainCondition)),

            //temperatura
            Text('${_weatherModel?.temperature.round().toString()}°c'),

            //weather condition
            Text(_weatherModel?.mainCondition ?? ""),
          ],
        ),
      ),
    );
  }
}
