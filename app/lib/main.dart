import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BluetoothPage(),
    );
  }
}

class BluetoothPage extends StatefulWidget {
  @override
  _BluetoothPageState createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  BluetoothConnection? connection;
  bool isConnected = false;
  BluetoothDevice? _device;
  final FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;

  @override
  void initState() {
    super.initState();
    requestBluetoothPermissions(); // Request Bluetooth permissions
  }

  // Request Bluetooth permissions
  Future<void> requestBluetoothPermissions() async {
    await Permission.bluetooth.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
    await Permission.location.request();
  }

  // Scan and connect to the Bluetooth device
  void connectToHM05() async {
    // Find paired devices
    final List<BluetoothDevice> devices = await bluetooth.getBondedDevices();

    BluetoothDevice? hm05 = devices.firstWhere(
      (d) => d.name == "HC-05" || d.name == "HM-05",
      orElse: () => devices.first,
    );

    // Connect to the HM-05 device
    BluetoothConnection.toAddress(hm05.address).then((conn) {
      setState(() {
        connection = conn;
        isConnected = true;
      });
      print('Connected to: ${hm05.address}');
    }).catchError((e) {
      print("Cannot connect to Bluetooth device: $e");
    });
  }

  // Send data to the connected HM-05
  void sendData(String data) {
    if (connection != null && connection!.isConnected) {
      connection!.output.add(Uint8List.fromList(data.codeUnits));
    }
  }

  @override
  void dispose() {
    connection?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("HM-05 Bluetooth")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: connectToHM05,
              child: Text('Connect to HM-05'),
            ),
            if (isConnected)
              ElevatedButton(
                onPressed: () => sendData("Hello Arduino\n"),
                child: Text('Send Data'),
              ),
            if (!isConnected) Text("Not Connected"),
          ],
        ),
      ),
    );
  }
}
