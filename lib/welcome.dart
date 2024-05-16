import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sensors_application/main.dart';

class MyWelcomeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoginActive = true; // Variable to track the active button

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'WELCOME TO',
                  style: TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 7, 50, 85),
                  ),
                ),
                Text(
                  'Mobile Sensors',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 7, 50, 85),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Where great things happen!',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Container(
            width: 800, // Adjust the width as needed
            height: 400, // Adjust the height as needed
            child: Center(
              child:
                  Lottie.asset('lib/Components/Animation - 1715793665856.json'),
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoginActive = true;
                  });
                  // Add your login button logic here
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => MyApp(),
                    ),
                  );
                },
                style: isLoginActive
                    ? ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 7, 50, 85),
                      )
                    : null,
                child: Text(
                  'Start Now',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 20),
            ],
          ),
        ],
      ),
    );
  }
}
