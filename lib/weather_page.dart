import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherPage extends StatefulWidget {
  final double lat;
  final double lon;

  const WeatherPage({super.key, required this.lat, required this.lon});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  late double currentLat;
  late double currentLon;
  final TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentLat = widget.lat;
    currentLon = widget.lon;
  }

  // City Name se Lat/Lon nikalne ke liye (Geocoding)
  Future<void> searchCity(String cityName) async {
    final url = Uri.parse("https://geocoding-api.open-meteo.com/v1/search?name=$cityName&count=1&language=en&format=json");
    final response = await http.get(url);
    final data = jsonDecode(response.body);

    if (data['results'] != null) {
      setState(() {
        currentLat = data['results'][0]['latitude'];
        currentLon = data['results'][0]['longitude'];
      });
    }
  }

  Future<Map<String, dynamic>> getWeatherData() async {
    final url = Uri.parse(
        "https://api.open-meteo.com/v1/forecast?latitude=$currentLat&longitude=$currentLon&current_weather=true&daily=temperature_2m_max,rain_sum,windspeed_10m_max&timezone=auto");
    final response = await http.get(url);
    return jsonDecode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade100, // Look behtar karne ke liye
      appBar: AppBar(title: const Text("Weather Forecast"), elevation: 0),
      body: Column(
        children: [
          // City Search Bar
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextField(
              controller: _cityController,
              decoration: InputDecoration(
                hintText: "City ka naam likhein (e.g. Karachi)",
                filled: true,
                fillColor: Colors.white,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => searchCity(_cityController.text),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
              onSubmitted: (value) => searchCity(value),
            ),
          ),



          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: getWeatherData(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                var current = snapshot.data!['current_weather'];
                var daily = snapshot.data!['daily'];

                return ListView(
                  padding: const EdgeInsets.all(15),
                  children: [
                    // Main Big Temperature Display (Bilkul System jaisa)flutter upgrade
                    Center(
                      child: Column(
                        children: [
                          Text("${current['temperature']}°",
                              style: const TextStyle(fontSize: 80, fontWeight: FontWeight.w300, color: Colors.white)),
                          const Text("Partly Cloudy", style: TextStyle(fontSize: 20, color: Colors.white)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Daily Cards
                    weatherCard("Yesterday", daily, 0, Colors.white.withValues(alpha: 0.8)),  // ✅ Sahi
                    weatherCard("Today",     daily, 1, Colors.white) ,                   // ✅ Sahi
                    weatherCard("Tomorrow",  daily, 2, Colors.orange.shade50) ,          // ✅ Sahi
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget weatherCard(String title, dynamic daily, int index, Color color) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Hawa: ${daily['windspeed_10m_max'][index]} km/h \nBaarish: ${daily['rain_sum'][index]} mm"),
        trailing: Text("${daily['temperature_2m_max'][index]}°C", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ),
    );
  }
}