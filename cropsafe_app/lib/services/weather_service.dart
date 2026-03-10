// lib/services/weather_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class WeatherData {
  final double temperature;
  final int humidity;
  final double windSpeed;
  final String condition;
  final String emoji;
  final String city;
  final bool isGoodForFieldWork;

  const WeatherData({
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.condition,
    required this.emoji,
    required this.city,
    required this.isGoodForFieldWork,
  });

  static WeatherData get fallback => const WeatherData(
        temperature: 0,
        humidity: 0,
        windSpeed: 0,
        condition: 'Unavailable',
        emoji: '🌡️',
        city: 'Unknown',
        isGoodForFieldWork: false,
      );
}

class WeatherService {
  // ── Get weather for current GPS location ─────────────────
  Future<WeatherData> fetchWeather() async {
    final position = await _getPosition();
    final lat = position.latitude;
    final lon = position.longitude;

    final weatherFuture = _fetchOpenMeteo(lat, lon);
    final cityFuture    = _reverseGeocode(lat, lon);

    final results = await Future.wait([weatherFuture, cityFuture]);
    final weather = results[0] as Map<String, dynamic>;
    final city    = results[1] as String;

    final current     = weather['current'] as Map<String, dynamic>;
    final temp        = (current['temperature_2m'] as num).toDouble();
    final humidity    = (current['relative_humidity_2m'] as num).toInt();
    final wind        = (current['wind_speed_10m'] as num).toDouble();
    final code        = (current['weather_code'] as num).toInt();

    final condition = _conditionFromCode(code);
    final emoji     = _emojiFromCode(code);
    final goodForWork = code <= 3 || code == 1 || code == 2;

    return WeatherData(
      temperature: temp,
      humidity: humidity,
      windSpeed: wind,
      condition: condition,
      emoji: emoji,
      city: city,
      isGoodForFieldWork: goodForWork,
    );
  }

  // ── Location permission + GPS ─────────────────────────────
  Future<Position> _getPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Location services disabled');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied');
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 10),
      ),
    );
  }

  // ── Open-Meteo weather fetch ──────────────────────────────
  Future<Map<String, dynamic>> _fetchOpenMeteo(double lat, double lon) async {
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$lat&longitude=$lon'
      '&current=temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code'
      '&temperature_unit=celsius&wind_speed_unit=kmh&timezone=auto',
    );
    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) throw Exception('Weather API error');
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // ── Nominatim reverse geocoding for city name ─────────────
  Future<String> _reverseGeocode(double lat, double lon) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?lat=$lat&lon=$lon&format=json',
      );
      final response = await http.get(uri, headers: {
        'User-Agent': 'CropSafeAI-App/1.0',
      }).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>?;
        return address?['city'] ??
            address?['town'] ??
            address?['village'] ??
            address?['county'] ??
            'Your Location';
      }
    } catch (_) {}
    return 'Your Location';
  }

  // ── WMO weather code → readable condition ─────────────────
  String _conditionFromCode(int code) {
    if (code == 0)                       return 'Clear sky';
    if (code == 1)                       return 'Mainly clear';
    if (code == 2)                       return 'Partly cloudy';
    if (code == 3)                       return 'Overcast';
    if (code == 45 || code == 48)        return 'Foggy';
    if (code >= 51 && code <= 55)        return 'Drizzle';
    if (code >= 61 && code <= 65)        return 'Rainy';
    if (code >= 71 && code <= 77)        return 'Snowy';
    if (code >= 80 && code <= 82)        return 'Rain showers';
    if (code == 85 || code == 86)        return 'Snow showers';
    if (code >= 95 && code <= 99)        return 'Thunderstorm';
    return 'Unknown';
  }

  // ── WMO weather code → emoji ───────────────────────────────
  String _emojiFromCode(int code) {
    if (code == 0)                       return '☀️';
    if (code == 1)                       return '🌤️';
    if (code == 2)                       return '⛅';
    if (code == 3)                       return '☁️';
    if (code == 45 || code == 48)        return '🌫️';
    if (code >= 51 && code <= 55)        return '🌦️';
    if (code >= 61 && code <= 65)        return '🌧️';
    if (code >= 71 && code <= 77)        return '🌨️';
    if (code >= 80 && code <= 82)        return '🌧️';
    if (code >= 95 && code <= 99)        return '⛈️';
    return '🌡️';
  }
}
