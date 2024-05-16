import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';

class LightSensorPage extends StatefulWidget {
  const LightSensorPage({Key? key}) : super(key: key);

  @override
  State<LightSensorPage> createState() => _LightSensorPageState();
}

class _LightSensorPageState extends State<LightSensorPage> {
  static const platform =
      MethodChannel('com.example.sensors_application.sensors/lightsensor');
  double _lightReading = 0.0; // Start with 0 to represent no light
  double maxLightLevel = 3000.0; // Adjust based on expected max light level
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    initializeNotifications();
    _getLightLevel();
    _enableRealTimeUpdates();
  }

  void initializeNotifications() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _getLightLevel() async {
    try {
      final double result = await platform.invokeMethod('getLightLevel');
      setState(() {
        _lightReading = result;
      });
      checkLuxLevelAndNotify(
          result); // Check light level and notify if above 1000 lux
    } on PlatformException {
      _lightReading = 0.0; // Handle failure or default state
    }
  }

  void checkLuxLevelAndNotify(double lux) {
    if (lux > 500) {
      sendNotification(lux); // Updated to send the current lux level
    }
  }

  void sendNotification(double lux) {
    String message = "ALERT! Light level Detected is at $lux lux!";
    var androidDetails = AndroidNotificationDetails('channelId', 'channelName',
        channelDescription: 'Channel for light sensor notifications');
    var generalNotificationDetails =
        NotificationDetails(android: androidDetails);

    flutterLocalNotificationsPlugin.show(
        0, 'Light Sensor Alert', message, generalNotificationDetails);
  }

  void _enableRealTimeUpdates() {
    platform.setMethodCallHandler((call) async {
      if (call.method == 'updateLightLevel') {
        final double updatedLevel = call.arguments;
        setState(() {
          _lightReading = updatedLevel;
        });
        checkLuxLevelAndNotify(
            updatedLevel); // Automate light adjustments on real-time updates
      }
    });
  }

  void _resetLightReading() {
    setState(() {
      _lightReading = 0.0; // Reset light reading to 0
    });
  }

  @override
  Widget build(BuildContext context) {
    double progress = (_lightReading / maxLightLevel).clamp(0.0, 1.0);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 7, 50, 85),
        title: Center(
          child: Text(
            'Light Sensor',
            style: TextStyle(
              color: Color.fromARGB(255, 186, 229, 15),
              fontSize: 23,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.blueGrey,
              Color.fromARGB(255, 7, 50, 85),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Light Level: ${_lightReading.toStringAsFixed(2)} lux',
                style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 10,
                backgroundColor: Colors.grey,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.yellowAccent),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _getLightLevel,
                icon: Icon(Icons.lightbulb_outline, size: 24),
                label: Text("Detect Light"),
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 56, 172, 10),
                  onPrimary: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _resetLightReading,
                icon: Icon(Icons.refresh, size: 24),
                label: Text("Reset"),
                style: ElevatedButton.styleFrom(
                  primary: Colors.redAccent,
                  onPrimary: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class LightSensorPage extends StatefulWidget {
//   const LightSensorPage({Key? key}) : super(key: key);

//   @override
//   State<LightSensorPage> createState() => _LightSensorPageState();
// }

// class _LightSensorPageState extends State<LightSensorPage> {
//   static const platform =
//       MethodChannel('com.example.sensors_application.sensors/lightsensor');
//   double _lightReading = 0.0; // Start with 0 to represent no light
//   double maxLightLevel = 5000.0; // Adjust based on expected max light level
//   late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

//   @override
//   void initState() {
//     super.initState();
//     initializeNotifications();
//     _getLightLevel();
//     _enableRealTimeUpdates();
//   }

//   void initializeNotifications() {
//     flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//     var initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//     var initializationSettings =
//         InitializationSettings(android: initializationSettingsAndroid);
//     flutterLocalNotificationsPlugin.initialize(initializationSettings);
//   }

//   Future<void> _getLightLevel() async {
//     try {
//       final double result = await platform.invokeMethod('getLightLevel');
//       setState(() {
//         _lightReading = result;
//       });
//       adjustLightsBasedOnLux(
//           result); // Automate light adjustments based on sensor reading
//     } on PlatformException {
//       _lightReading = 0.0; // Handle failure or default state
//     }
//   }

//   void adjustLightsBasedOnLux(double lux) async {
//     var url = 'https://api.yoursmarthome.com/lights/control';
//     var headers = {
//       'Content-Type': 'application/json',
//       'Authorization': 'Bearer your_api_key'
//     };
//     var body = jsonEncode({
//       'device_id': 'your_device_id',
//       'state': lux < 100 ? 'on' : 'off', // Turn on if dark, off if bright
//       'brightness':
//           lux < 100 ? '100' : '10' // Full brightness if dark, low if bright
//     });

//     try {
//       var response =
//           await http.post(Uri.parse(url), headers: headers, body: body);
//       if (response.statusCode == 200) {
//         print('Lights adjusted successfully');
//       } else {
//         print('Failed to adjust lights');
//       }
//     } catch (e) {
//       print('Error adjusting lights: $e');
//     }
//   }

//   void sendNotification(String message) {
//     var androidDetails = AndroidNotificationDetails('channelId', 'channelName',
//         channelDescription: 'Channel for light sensor notifications');
//     var generalNotificationDetails =
//         NotificationDetails(android: androidDetails);

//     flutterLocalNotificationsPlugin.show(
//         0, 'Light Sensor Alert', message, generalNotificationDetails);
//   }

//   void _enableRealTimeUpdates() {
//     platform.setMethodCallHandler((call) async {
//       if (call.method == 'updateLightLevel') {
//         final double updatedLevel = call.arguments;
//         setState(() {
//           _lightReading = updatedLevel;
//         });
//         adjustLightsBasedOnLux(
//             updatedLevel); // Automate light adjustments on real-time updates
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     double progress = (_lightReading / maxLightLevel).clamp(0.0, 1.0);
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Color.fromARGB(255, 7, 50, 85),
//         title: Center(
//           child: Text(
//             'Light Sensor',
//             style: TextStyle(
//               color: Color.fromARGB(255, 186, 229, 15),
//               fontSize: 23,
//             ),
//           ),
//         ),
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topRight,
//             end: Alignment.bottomLeft,
//             colors: [
//               Colors.blueGrey,
//               Color.fromARGB(255, 7, 50, 85),
//             ],
//           ),
//         ),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               Text(
//                 'Light Level',
//                 style: TextStyle(
//                     fontSize: 24,
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 20),
//               CircularProgressIndicator(
//                 value: progress,
//                 strokeWidth: 8,
//                 backgroundColor: Colors.grey,
//                 valueColor: AlwaysStoppedAnimation<Color>(Colors.yellowAccent),
//               ),
//               SizedBox(height: 20),
//               Text(
//                 "${_lightReading.toStringAsFixed(2)} lux",
//                 style: TextStyle(fontSize: 20, color: Colors.white),
//               ),
//               SizedBox(height: 20),
//               ElevatedButton.icon(
//                 onPressed: _getLightLevel,
//                 icon: Icon(Icons.lightbulb_outline, size: 24),
//                 label: Text("Detect Light"),
//                 style: ElevatedButton.styleFrom(
//                   primary: Color.fromARGB(255, 56, 172, 10),
//                   onPrimary: Colors.white, // Text color
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class LightSensorPage extends StatefulWidget {
//   const LightSensorPage({Key? key}) : super(key: key);

//   @override
//   State<LightSensorPage> createState() => _LightSensorPageState();
// }

// class _LightSensorPageState extends State<LightSensorPage> {
//   static const platform =
//       MethodChannel('com.example.sensors_application.sensors/lightsensor');
//   double _lightReading = 0.0;
//   double maxLightLevel = 500.0;

//   @override
//   void initState() {
//     super.initState();
//     _getLightLevel();
//   }

//   Future<void> _getLightLevel() async {
//     try {
//       final double result = await platform.invokeMethod('getLightLevel');
//       setState(() {
//         _lightReading = result;
//       });
//     } on PlatformException {
//       _lightReading = 0.0;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     double progress = (_lightReading / maxLightLevel).clamp(0.0, 1.0);
//     return Scaffold(
//       body: Container(
//         padding: EdgeInsets.symmetric(horizontal: 24),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topRight,
//             end: Alignment.bottomLeft,
//             colors: [
//               Colors.deepPurple,
//               Colors.indigo,
//             ],
//           ),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Spacer(),
//             Text(
//               'Ambient Light Level',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 28,
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//                 letterSpacing: 1.2,
//               ),
//             ),
//             SizedBox(height: 20),
//             LinearProgressIndicator(
//               value: progress,
//               minHeight: 14,
//               backgroundColor: Colors.deepPurple.shade100,
//               valueColor: AlwaysStoppedAnimation<Color>(Colors.amberAccent),
//             ),
//             SizedBox(height: 20),
//             Text(
//               "${_lightReading.toStringAsFixed(2)} lux",
//               style: TextStyle(
//                 fontSize: 22,
//                 color: Colors.white70,
//                 letterSpacing: 1.1,
//               ),
//             ),
//             Spacer(),
//             ElevatedButton.icon(
//               onPressed: _getLightLevel,
//               icon: Icon(Icons.lightbulb_outline, size: 24),
//               label: Text("Refresh"),
//               style: ElevatedButton.styleFrom(
//                 primary: Colors.amber, // Button color
//                 onPrimary: Colors.black, // Text color
//                 padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
//               ),
//             ),
//             SizedBox(height: 40),
//           ],
//         ),
//       ),
//     );
//   }
// }
