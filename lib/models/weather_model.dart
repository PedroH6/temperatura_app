class WeatherModel {
  final String cityName;
  final double temperature;
  final String mainCondition;
  final String description;
  final int humidity;
  final String windSpeed;
  final String sunrise;
  final String sunset;
  final String imgId;
  final List<ForecastModel> forecast;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.mainCondition,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.sunrise,
    required this.sunset,
    required this.imgId,
    required this.forecast,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final results = json['results'];
    
    // Processar previsão do tempo
    List<ForecastModel> forecastList = [];
    if (results['forecast'] != null) {
      for (var item in results['forecast']) {
        forecastList.add(ForecastModel.fromJson(item));
      }
    }

    return WeatherModel(
      cityName: results['city_name'] ?? results['city'] ?? 'Desconhecida',
      temperature: (results['temp'] ?? 0).toDouble(),
      mainCondition: results['condition_slug'] ?? 'unknown',
      description: results['description'] ?? 'Sem descrição',
      humidity: results['humidity'] ?? 0,
      windSpeed: results['wind_speedy'] ?? '0 km/h',
      sunrise: results['sunrise'] ?? '',
      sunset: results['sunset'] ?? '',
      imgId: results['img_id'] ?? '01',
      forecast: forecastList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city_name': cityName,
      'temp': temperature,
      'condition_slug': mainCondition,
      'description': description,
      'humidity': humidity,
      'wind_speedy': windSpeed,
      'sunrise': sunrise,
      'sunset': sunset,
      'img_id': imgId,
      'forecast': forecast.map((f) => f.toJson()).toList(),
    };
  }
}

class ForecastModel {
  final String date;
  final String weekday;
  final int max;
  final int min;
  final String description;
  final String condition;
  final String imgId;

  ForecastModel({
    required this.date,
    required this.weekday,
    required this.max,
    required this.min,
    required this.description,
    required this.condition,
    required this.imgId,
  });

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    return ForecastModel(
      date: json['date'] ?? '',
      weekday: json['weekday'] ?? '',
      max: json['max'] ?? 0,
      min: json['min'] ?? 0,
      description: json['description'] ?? '',
      condition: json['condition'] ?? '',
      imgId: json['img_id'] ?? '01',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'weekday': weekday,
      'max': max,
      'min': min,
      'description': description,
      'condition': condition,
      'img_id': imgId,
    };
  }
}