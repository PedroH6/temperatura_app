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
  // Api key
  final _weatherService = WeatherServices('f5c120b9');
  WeatherModel? _weatherModel;
  bool _isLoading = true;
  String? _errorMessage;

  // Buscar previsão do tempo
  _fetchWeather() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Opção 1: Usar localização atual (recomendado)
      final weather = await _weatherService.getCurrentLocationWeather();

      // Opção 2: Ou buscar por cidade específica
      // final weather = await _weatherService.getWeather('São Paulo');
      
      setState(() {
        _weatherModel = weather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      print('Erro ao buscar clima: $e');
    }
  }

  // Animação do clima adaptada para HG Brasil
  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/sunny.json';

    // Condições da HG Brasil
    switch (mainCondition.toLowerCase()) {
      // Nublado/Parcialmente nublado
      case 'cloudly_day':
      case 'cloudly_night':
      case 'partly_cloudly':
      case 'fog':
        return 'assets/cloud.json';
      
      // Chuva
      case 'rain':
      case 'storm':
        return 'assets/rainy.json';
      
      // Tempestade
      case 'thunderstorm':
        return 'assets/thunder.json';
      
      // Ensolarado/Limpo
      case 'clear_day':
      case 'clear_night':
        return 'assets/sunny.json';
      
      // Outras condições
      case 'snow':
        return 'assets/cloud.json'; // Assumindo que você não tem animação de neve
      
      default:
        return 'assets/sunny.json';
    }
  }

  // Ícone do clima baseado no img_id da HG Brasil
  String getWeatherAnimationByImgId(String? imgId) {
    if (imgId == null) return 'assets/sunny.json';

    switch (imgId) {
      case '01': // Ensolarado
      case '02': // Poucas nuvens
        return 'assets/sunny.json';
      case '03': // Parcialmente nublado
      case '04': // Nublado
      case '05': // Neblina
        return 'assets/cloud.json';
      case '06': // Chuva
      case '07': // Pancadas de chuva
      case '08': // Chuva com trovoadas
        return 'assets/rainy.json';
      case '09': // Trovoada
        return 'assets/thunder.json';
      default:
        return 'assets/sunny.json';
    }
  }

  // Traduzir descrição para português (caso venha em inglês)
  String translateDescription(String description) {
    final translations = {
      'clear sky': 'Céu limpo',
      'few clouds': 'Poucas nuvens',
      'scattered clouds': 'Nuvens dispersas',
      'broken clouds': 'Nublado',
      'shower rain': 'Pancadas de chuva',
      'rain': 'Chuva',
      'thunderstorm': 'Tempestade',
      'snow': 'Neve',
      'mist': 'Neblina',
    };

    return translations[description.toLowerCase()] ?? description;
  }

  @override
  void initState() {
    super.initState();
    // Buscar previsão do tempo na inicialização
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[400],
      appBar: AppBar(
        title: const Text('Clima'),
        backgroundColor: Colors.grey[300],
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchWeather),
        ],
      ),
      body: Center(
        child: _isLoading
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Carregando dados do clima..."),
                ],
              )
            : _errorMessage != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar dados:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchWeather,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Nome da cidade
                  Text(
                    _weatherModel?.cityName ?? "Cidade desconhecida",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Animação do clima
                  SizedBox(
                    height: 200,
                    child: Lottie.asset(
                      // Usando o img_id que é mais confiável
                      getWeatherAnimationByImgId(_weatherModel?.imgId),
                      // Alternativa: usar a condição
                      // getWeatherAnimation(_weatherModel?.mainCondition),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Temperatura
                  Text(
                    '${_weatherModel?.temperature.round()}°C',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Descrição do clima
                  Text(
                    translateDescription(_weatherModel?.description ?? ""),
                    style: const TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Informações adicionais
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Umidade:',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                            Text(
                              '${_weatherModel?.humidity}%',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Vento:',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                            Text(
                              _weatherModel?.windSpeed ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (_weatherModel?.sunrise.isNotEmpty == true) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Nascer do sol:',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                _weatherModel?.sunrise ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (_weatherModel?.sunset.isNotEmpty == true) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Pôr do sol:',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                _weatherModel?.sunset ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
