import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData.dark(),
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String _weather = 'Loading...';
  String _latitude = '';
  String _longitude = '';
  String _city = '';
  String _iconUrl = '';

  void getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    _updateWeather();
    setState(() {
      _latitude = position.latitude.toString();
      _longitude = position.longitude.toString();
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    _updateWeather();
  }

  Future<void> _updateWeather() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final response = await http.get(Uri.parse(
        'http://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=c36d00a1ade6f97e5f7d9861c3dff92c'));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      String weather = data['weather'][0]['description'];
      setState(() {
        _weather = weather;
        _city = data['name'];
        _iconUrl =
            'http://openweathermap.org/img/w/${data['weather'][0]['icon']}.png';
      });
    } else {
      setState(() {
        _weather = 'Failed to load weather data.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String googleApiKey = 'AIzaSyAVsku3_R5bbF-Vc9dt7fnZgu_iR1BYLUM';
    String mapUrl =
        'https://maps.googleapis.com/maps/api/staticmap?center=$_latitude,$_longitude&zoom=14&size=400x400&key=$googleApiKey';
    if (_weather.isEmpty &&
        _city.isEmpty &&
        _iconUrl.isEmpty &&
        _latitude.isEmpty &&
        _longitude.isEmpty) {
      return const CircularProgressIndicator();
    } else {
      return Scaffold(
          appBar: AppBar(
            title: const Text('Weather App'),
          ),
          body: SingleChildScrollView(
              child: Center(
                  child: Column(children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(style: BorderStyle.solid),
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                color: Colors.white24,
              ),
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.all(15),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 150,
                        child: const Text(
                          "Latitude",
                          style: TextStyle(
                            fontSize: 24,
                          ),
                        ),
                      ),
                      Container(
                        child: const Text(
                          ":",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      Expanded(
                        child: Container(
                            padding: const EdgeInsets.only(left: 15),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _latitude,
                              style: const TextStyle(fontSize: 20),
                            )),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 150,
                        child: const Text(
                          "Longitude",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      Container(
                        child: const Text(
                          ":",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      Expanded(
                        child: Container(
                            padding: const EdgeInsets.only(left: 15),
                            child: Text(
                              _longitude,
                              style: const TextStyle(fontSize: 20),
                            )),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 150,
                        child: const Text(
                          "City",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      Container(
                        child: const Text(
                          ":",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      Expanded(
                        child: Container(
                            padding: const EdgeInsets.only(left: 15),
                            child: Text(
                              _city,
                              style: const TextStyle(fontSize: 20),
                            )),
                      )
                    ],
                  ),
                  Container(
                    height: 50,
                    child: Row(
                      children: [
                        Container(
                          width: 150,
                          child: const Text(
                            "Weather",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        Container(
                          child: const Text(
                            ":",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        Expanded(
                          child: Container(
                              padding: const EdgeInsets.only(left: 15),
                              child: Text(
                                _weather,
                                style: const TextStyle(fontSize: 20),
                              )),
                        ),
                        Image.network(
                          _iconUrl,
                          width: 50,
                          height: 50,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              child: Container(
                height: 200,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Image.network(
                  mapUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ]))));
    }
  }
}
