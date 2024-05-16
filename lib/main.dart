import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sensors_application/compass_page.dart';
import 'package:sensors_application/light_sensor_page.dart';
import 'package:sensors_application/step_counter_page.dart';
import 'package:sensors_application/tracking_page.dart';
import 'package:sensors_application/welcome.dart';

Future<void> main() async {
  runApp(MyWelcomeApp());
  await initNotifications();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainNavigationPage(),
    );
  }
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse:
        (NotificationResponse notificationResponse) async {},
  );
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({Key? key}) : super(key: key);

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  Widget _getWidgetOption(int index) {
    switch (index) {
      case 0:
        return MapPage();
      case 1:
        // Placeholder for a Home page
        return CompassPage();
      case 2:
        // Placeholder for a Profile page
        return StepCounterPage();
      case 3:
        // Placeholder for a Profile page
        return LightSensorPage();
      default:
        // This could be an error page or a default page
        return const Text('Page Not Found');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _getWidgetOption(_selectedIndex),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          // Override the background color of the BottomNavigationBar
          canvasColor: Colors.white, // Or any color you want for the background

          // Override the active color (selected item)
          primaryColor:
              Colors.red, // Or any color you want for the selected item

          // Override the inactive color (unselected items)
          textTheme: Theme.of(context).textTheme.copyWith(
                caption: TextStyle(
                    color:
                        Colors.grey), // Or any color for unselected item labels
              ),

          // Optionally set the splash color
          splashColor: Colors.blue.withOpacity(0.2),

          // Override the color of the BottomNavigationBar itself if needed
          bottomAppBarColor: Colors
              .green, // Or any color for the bottom navigation bar background
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Location',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.compass_calibration),
              label: 'Compass',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.run_circle),
              label: 'Motion Sensor',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.lightbulb),
              label: 'Light Sensor',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Color.fromARGB(246, 23, 144,
              108), // This will be overridden by primaryColor above
          unselectedItemColor:
              Colors.grey, // This directly sets the unselected item color
          onTap: _onItemTapped,
          showUnselectedLabels: true,
        ),
      ),
    );
  }
}
