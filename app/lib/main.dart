import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';
import 'dart:async';

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

class HoldableButton extends StatefulWidget {
  final VoidCallback onTapDownRepeat;
  final Color backgroundColor;
  final Icon icon;

  const HoldableButton({
    required this.onTapDownRepeat,
    required this.icon,
    this.backgroundColor = const Color.fromARGB(255, 232, 242, 255),
    super.key,
  });

  @override
  State<HoldableButton> createState() => _HoldableButtonState();
}

class _HoldableButtonState extends State<HoldableButton> {
  Timer? _timer;

  void _startRepeatAction() {
    widget.onTapDownRepeat(); // Call once immediately
    _timer = Timer.periodic(Duration(milliseconds: 20), (_) {
      widget.onTapDownRepeat(); // Call repeatedly
    });
  }

  void _stopRepeatAction() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _startRepeatAction(),
      onTapUp: (_) => _stopRepeatAction(),
      onTapCancel: _stopRepeatAction,
      child: Container(
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Center(child: widget.icon),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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

  double widthButton = 100;
  double heightButton = 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("HM-05 Bluetooth")),
      body: Center(
          child: Row(
        children: [
          // Movement controller
          Expanded(
            child: Column(
              children: [
                // UP
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                          width: widthButton,
                          height: heightButton,
                          child: HoldableButton(
                              onTapDownRepeat: () => sendData("U\n"),
                              icon: Icon(Icons.keyboard_arrow_up_rounded))),
                    ],
                  ),
                ),
                // LEFT and RIGHT
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          SizedBox(
                            width: widthButton,
                            height: heightButton,
                            child: HoldableButton(
                                onTapDownRepeat: () => sendData("L\n"),
                                icon: Icon(Icons.keyboard_arrow_left_rounded)),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          SizedBox(
                            width: widthButton,
                            height: heightButton,
                            child: HoldableButton(
                                onTapDownRepeat: () => sendData("R\n"),
                                icon: Icon(Icons.keyboard_arrow_right_rounded)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // DOWN
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        width: widthButton,
                        height: heightButton,
                        child: HoldableButton(
                            onTapDownRepeat: () => sendData("D\n"),
                            icon: Icon(Icons.keyboard_arrow_down_rounded)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Connect Bluetooth part
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: connectToHM05,
                  icon: Icon(Icons.bluetooth),
                  label: Text('Connect to HM-05'),
                ),
                if (isConnected)
                  Text(
                    "Bluetooth Connected",
                    style: TextStyle(
                      color: Colors.green,
                    ),
                  )
                else
                  Text(
                    "Bluetooth Disconnected",
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  )
              ],
            ),
          ),

          // Control lift
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        width: widthButton,
                        height: heightButton,
                        child: HoldableButton(
                            onTapDownRepeat: () => sendData("L_U\n"),
                            icon: Icon(Icons.arrow_upward_sharp)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        width: widthButton,
                        height: heightButton,
                        child: HoldableButton(
                            onTapDownRepeat: () => sendData("L_D\n"),
                            icon: Icon(Icons.arrow_downward_sharp)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      )),
    );
  }
}
