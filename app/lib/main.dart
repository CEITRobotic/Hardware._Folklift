import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CarControlScreen(),
    );
  }
}

class CarControlScreen extends StatefulWidget {
  @override
  _CarControlScreenState createState() => _CarControlScreenState();
}

class _CarControlScreenState extends State<CarControlScreen> {
  // Example method to simulate car control
  void moveCar(String direction) {
    print("Car moving $direction");
    // Add the logic to control the car based on the direction
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Car Control'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Forward button
            Container(
              width: 200, // Forces the button to be horizontal
              child: ElevatedButton(
                onPressed: () {
                  moveCar("Forward");
                },
                child: Text(
                  'Move Forward',
                  style: TextStyle(fontSize: 18),
                ),
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(
                    EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20), // Space between buttons
            // Backward button
            Container(
              width: 200, // Forces the button to be horizontal
              child: ElevatedButton(
                onPressed: () {
                  moveCar("Backward");
                },
                child: Text(
                  'Move Backward',
                  style: TextStyle(fontSize: 18),
                ),
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(
                    EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
