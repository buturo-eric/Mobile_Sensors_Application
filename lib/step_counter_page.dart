import 'dart:async';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sensors_plus/sensors_plus.dart';

class StepCounterPage extends StatefulWidget {
  @override
  _StepCounterPageState createState() => _StepCounterPageState();
}

class _StepCounterPageState extends State<StepCounterPage> {
  int _stepCount = 0;
  int _lastNotificationStepCount =
      0; // Track the last step count for notifications
  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;
  final int _stepGoal = 1000; // Example step goal
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _startListeningToAccelerometer();
  }

  void _initializeNotifications() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  void dispose() {
    _accelerometerSubscription.cancel();
    super.dispose();
  }

  void _startListeningToAccelerometer() {
    _accelerometerSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      // Apply a threshold for step detection
      if (event.z.abs() > 20.0) {
        // Increment step count only if the change in acceleration is significant
        setState(() {
          _stepCount++;
        });
        _sendStepChangeNotification(); // Send notification on step count change
      }
    });
  }

  void _sendStepChangeNotification() {
    if (_stepCount - _lastNotificationStepCount >= 100) {
      var androidDetails = AndroidNotificationDetails(
          'channelId', 'channelName',
          channelDescription: 'Channel for step counter notifications');
      var generalNotificationDetails =
          NotificationDetails(android: androidDetails);
      flutterLocalNotificationsPlugin.show(
          0,
          'Motion Sensor Alert!',
          'Congratulations! You have reached $_stepCount steps!',
          generalNotificationDetails);
      _lastNotificationStepCount = _stepCount;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double percent =
        _stepCount / _stepGoal; // Calculate the completion percentage

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 7, 50, 85),
        title: Center(
            child: Text("Motion Sensor",
                style: TextStyle(
                    color: Color.fromARGB(255, 186, 229, 15), fontSize: 23))),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Color.fromARGB(255, 7, 50, 85)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Step Count',
                  style:
                      theme.textTheme.headline5!.copyWith(color: Colors.white)),
              SizedBox(height: 8),
              CircularPercentIndicator(
                radius: 120.0,
                lineWidth: 13.0,
                animation: true,
                percent: percent.clamp(0.0, 1.0),
                center: new Text(
                  '$_stepCount steps',
                  style: new TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.white),
                ),
                footer: Text(
                  'Daily Goal: $_stepGoal steps',
                  style: theme.textTheme.headline6!
                      .copyWith(color: Colors.white70),
                ),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: Colors.green,
              ),
              SizedBox(height: 50),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  onPrimary: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                icon: Icon(Icons.refresh),
                label: Text("Reset Steps"),
                onPressed: () {
                  setState(() {
                    _stepCount = 0;
                    _lastNotificationStepCount = 0;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}




// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:sensors_plus/sensors_plus.dart';
// import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';

// class StepCounterPage extends StatefulWidget {
//   @override
//   _StepCounterPageState createState() => _StepCounterPageState();
// }

// class _StepCounterPageState extends State<StepCounterPage> {
//   int _stepCount = 0;
//   late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;
//   final int _stepGoal = 10000; // Example step goal

//   @override
//   void initState() {
//     super.initState();
//     _startListeningToAccelerometer();
//   }

//   @override
//   void dispose() {
//     _accelerometerSubscription.cancel();
//     super.dispose();
//   }

//   void _startListeningToAccelerometer() {
//     _accelerometerSubscription =
//         accelerometerEvents.listen((AccelerometerEvent event) {
//       if (event.z.abs() > 10.0) {
//         setState(() {
//           _stepCount++;
//         });
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Color.fromARGB(255, 7, 50, 85),
//         title: Center(
//             child: Text(
//           "Step Counter",
//           style: TextStyle(
//             color: Color.fromARGB(255, 186, 229, 15),
//             fontSize: 23,
//           ),
//         )),
//         elevation: 0,
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.deepPurple, Colors.purpleAccent],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 'Step Count:',
//                 style: theme.textTheme.headline5!.copyWith(color: Colors.white),
//               ),
//               SizedBox(height: 8),
//               Text(
//                 '$_stepCount',
//                 style: theme.textTheme.headline2!.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//               SizedBox(height: 20),
//               Text(
//                 'Goal: $_stepGoal steps',
//                 style:
//                     theme.textTheme.headline6!.copyWith(color: Colors.white70),
//               ),
//               SizedBox(height: 30),
//               FAProgressBar(
//                 currentValue:
//                     _stepCount.toDouble(), // Assuming _stepCount is an int
//                 maxValue: _stepGoal.toDouble(), // Assuming _stepGoal is an int
//                 size: 30,
//                 progressColor: Colors.white,
//                 backgroundColor: Colors.white24,
//                 displayText: ' steps',
//                 displayTextStyle: TextStyle(color: Colors.white),
//                 changeColorValue:
//                     _stepGoal.round(), // Convert to int if necessary
//                 // Assuming _stepGoal is already an int, no need to convert
//                 changeProgressColor: Colors.green,
//               ),
//               SizedBox(height: 50),
//               ElevatedButton.icon(
//                 style: ElevatedButton.styleFrom(
//                   primary: Colors.white,
//                   onPrimary: Colors.deepPurple,
//                   padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
//                 ),
//                 icon: Icon(Icons.refresh),
//                 label: Text("Reset Steps"),
//                 onPressed: () {
//                   setState(() {
//                     _stepCount = 0;
//                   });
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }




// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:sensors_plus/sensors_plus.dart';

// class StepCounterPage extends StatefulWidget {
//   @override
//   _StepCounterPageState createState() => _StepCounterPageState();
// }

// class _StepCounterPageState extends State<StepCounterPage> {
//   int _stepCount = 0;
//   late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;

//   @override
//   void initState() {
//     super.initState();
//     _startListeningToAccelerometer();
//   }

//   @override
//   void dispose() {
//     _accelerometerSubscription.cancel();
//     super.dispose();
//   }

//   void _startListeningToAccelerometer() {
//     _accelerometerSubscription =
//         accelerometerEvents.listen((AccelerometerEvent event) {
//       if (event.z.abs() > 10.0) {
//         setState(() {
//           _stepCount++;
//         });
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'Step Count:',
//               style: TextStyle(fontSize: 20,color: Colors.black),
//             ),
//             Text(
//               '$_stepCount',
//               style: TextStyle(
//                   fontSize: 40,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }