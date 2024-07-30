import 'dart:async';
import 'package:flutter/material.dart';
import 'package:after_layout/after_layout.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with AfterLayoutMixin<Home> {
  double humidity = 0, temperature = 0;
  bool isLoading = false;
  bool isManualLoading = false;

  @override
  void afterFirstLayout(BuildContext context) async {
    await getData();
    Timer.periodic(Duration(seconds: 30), (timer) {
      getData();
    });
  }

  Future<void> getData() async {
    setState(() {
      isLoading = true;
    });
    final ref = FirebaseDatabase.instance.ref();
    final temp = await ref.child("Living Room/temperature/value").get();
    final humi = await ref.child("Living Room/humidity/value").get();
    if (temp.exists && humi.exists) {
      temperature = double.parse(temp.value.toString());
      humidity = double.parse(humi.value.toString());
    } else {
      temperature = -1;
      humidity = -1;
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> manualRefresh() async {
    setState(() {
      isManualLoading = true;
    });
    await getData();
    setState(() {
      isManualLoading = false;
    });
  }

  Widget temperatureMessage(double temperature) {
    if (temperature < 0) {
      return Text('Hace frío', style: TextStyle(color: Colors.blue));
    } else if (temperature <= 30) {
      return Text('Temperatura agradable',
          style: TextStyle(color: Colors.green));
    } else {
      return Text('Temperatura muy alta', style: TextStyle(color: Colors.red));
    }
  }

  Widget humidityMessage(double humidity) {
    if (humidity < 0) {
      return Text('Tiempo seco', style: TextStyle(color: Colors.brown));
    } else if (humidity < 50) {
      return Text('Humedad media', style: TextStyle(color: Colors.yellow));
    } else {
      return Text('Humedad alta', style: TextStyle(color: Colors.purple));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gauges'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () async {
              await manualRefresh();
            },
          ),
        ],
      ),
      body: Center(
        child: isManualLoading
            ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              Text('Cargando...', style: TextStyle(fontSize: 20)),
              SizedBox(height: 10),
            ],
          ),
        )
            : isLoading
            ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              Text('Cargando...', style: TextStyle(fontSize: 20)),
              SizedBox(height: 10),
            ],
          ),
        )
            : ListView(
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: SfRadialGauge(
                axes: <RadialAxis>[
                  RadialAxis(
                    minimum: -30,
                    maximum: 50,
                    ranges: <GaugeRange>[
                      GaugeRange(
                          startValue: -30,
                          endValue: 0,
                          color: Colors.blueAccent),
                      GaugeRange(
                          startValue: 0,
                          endValue: 30,
                          color: Colors.greenAccent),
                      GaugeRange(
                          startValue: 30,
                          endValue: 50,
                          color: Colors.redAccent),
                    ],
                    pointers: <GaugePointer>[
                      NeedlePointer(value: temperature)
                    ],
                    annotations: <GaugeAnnotation>[
                      GaugeAnnotation(
                        widget: Text(
                          '$temperature°C',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        angle: 90,
                        positionFactor: 0.5,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(child: temperatureMessage(temperature)),
            ),
            const Divider(height: 1),
            GHume(humidity: humidity),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(child: humidityMessage(humidity)),
            ),
            const Divider(height: 1),
          ],
        ),
      ),
    );
  }
}

class GHume extends StatelessWidget {
  final double humidity;

  GHume({required this.humidity});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.4,
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
            minimum: -10,
            maximum: 100,
            ranges: <GaugeRange>[
              GaugeRange(startValue: -10, endValue: 0, color: Colors.brown),
              GaugeRange(startValue: 0, endValue: 50, color: Colors.yellow),
              GaugeRange(startValue: 50, endValue: 100, color: Colors.purple),
            ],
            pointers: <GaugePointer>[NeedlePointer(value: humidity)],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                widget: Text(
                  '$humidity%',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                angle: 90,
                positionFactor: 0.5,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
