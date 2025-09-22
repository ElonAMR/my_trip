import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const _apiKey = 'PASTE_YOUR_OPENWEATHER_API_KEY_HERE';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _cityCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  _WeatherData? _data;

  @override
  void initState() {
    super.initState();
    _loadLastCity();
  }

  Future<void> _loadLastCity() async {
    final sp = await SharedPreferences.getInstance();
    final last = sp.getString('weather_city');
    if (last != null && last.isNotEmpty) {
      _cityCtrl.text = last;
      _fetchWeather(last);
    }
  }

  Future<void> _saveLastCity(String city) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('weather_city', city);
  }

  Future<void> _fetchWeather(String city) async {
    if (_apiKey == 'PASTE_YOUR_OPENWEATHER_API_KEY_HERE') {
      setState(() => _error = 'שים מפתח API של OpenWeather בקובץ weather_page.dart');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final uri = Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$_apiKey&units=metric&lang=he');
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final j = jsonDecode(res.body) as Map<String, dynamic>;
        final d = _WeatherData.fromJson(j);
        setState(() => _data = d);
        _saveLastCity(city);
      } else {
        setState(() => _error = 'עיר לא נמצאה או בעיית שרת (${res.statusCode})');
      }
    } catch (_) {
      setState(() => _error = 'שגיאת רשת. בדוק חיבור אינטרנט.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _cityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _cityCtrl,
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    labelText: 'שם עיר',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (v) {
                    final c = v.trim();
                    if (c.isNotEmpty) _fetchWeather(c);
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _loading
                    ? null
                    : () {
                  final c = _cityCtrl.text.trim();
                  if (c.isNotEmpty) _fetchWeather(c);
                },
                child: _loading
                    ? const SizedBox(
                    width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('חפש'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (_error != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),

          if (_data != null) _WeatherCard(data: _data!),
        ],
      ),
    );
  }
}

class _WeatherData {
  final String city;
  final double temp;
  final double? tempMin;
  final double? tempMax;
  final String description;
  final String icon;

  _WeatherData({
    required this.city,
    required this.temp,
    required this.description,
    required this.icon,
    this.tempMin,
    this.tempMax,
  });

  factory _WeatherData.fromJson(Map<String, dynamic> j) {
    final main = j['main'] as Map<String, dynamic>;
    final weatherArr = (j['weather'] as List).cast<Map<String, dynamic>>();
    final w = weatherArr.isNotEmpty ? weatherArr.first : <String, dynamic>{};
    return _WeatherData(
      city: j['name'] as String? ?? '',
      temp: (main['temp'] as num).toDouble(),
      tempMin: main['temp_min'] != null ? (main['temp_min'] as num).toDouble() : null,
      tempMax: main['temp_max'] != null ? (main['temp_max'] as num).toDouble() : null,
      description: (w['description'] as String? ?? '').trim(),
      icon: (w['icon'] as String? ?? '').trim(),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  final _WeatherData data;
  const _WeatherCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final hasMinMax = data.tempMin != null && data.tempMax != null;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (data.icon.isNotEmpty)
              Image.network(
                'https://openweathermap.org/img/wn/${data.icon}@2x.png',
                width: 64,
                height: 64,
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.city, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text('${data.temp.toStringAsFixed(1)}°C — ${data.description}'),
                  if (hasMinMax) ...[
                    const SizedBox(height: 4),
                    Text('מינ׳: ${data.tempMin!.toStringAsFixed(1)}°  ·  מקס׳: ${data.tempMax!.toStringAsFixed(1)}°'),
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
