// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:flutter_compass/flutter_compass.dart';

// class CompassPage extends StatefulWidget {
//   const CompassPage({super.key});

//   @override
//   State<CompassPage> createState() => _CompassPageState();
// }

// class _CompassPageState extends State<CompassPage> {
//   //let's set the compass
//   double? heading = 0;

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     FlutterCompass.events!.listen((event) {
//       setState(() {
//         heading = event.heading;
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Color.fromARGB(255, 7, 50, 85),
//         centerTitle: true,
//         title: Text("Compass Navigation"),
//         foregroundColor: Color.fromARGB(255, 186, 229, 15),
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Text(
//             "${heading!.ceil()}°",
//             style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 26.0,
//                 fontWeight: FontWeight.bold),
//           ),
//           SizedBox(
//             height: 50.0,
//           ),

//           //Let's show the compass
//           Padding(
//             padding: EdgeInsets.all(18.0),
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 Image.asset("assets/cadrant.png"),
//                 Transform.rotate(
//                   angle: ((heading ?? 0) * (pi / 180) * -1),
//                   child: Image.asset(
//                     "assets/compass.png",
//                     scale: 1.1,
//                   ),
//                 ),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';

class CompassPage extends StatefulWidget {
  const CompassPage({super.key});

  @override
  State<CompassPage> createState() => _CompassPageState();
}

class _CompassPageState extends State<CompassPage> {
  //let's set the compass
  double? heading = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FlutterCompass.events!.listen((event) {
      setState(() {
        heading = event.heading;
      });
    });
  }

  String getDirection(double heading) {
    String direction = "N"; // Default direction
    if (heading >= 22.5 && heading < 67.5) {
      direction = "NE";
    } else if (heading >= 67.5 && heading < 112.5) {
      direction = "E";
    } else if (heading >= 112.5 && heading < 157.5) {
      direction = "SE";
    } else if (heading >= 157.5 && heading < 202.5) {
      direction = "S";
    } else if (heading >= 202.5 && heading < 247.5) {
      direction = "SW";
    } else if (heading >= 247.5 && heading < 292.5) {
      direction = "W";
    } else if (heading >= 292.5 && heading < 337.5) {
      direction = "NW";
    }
    return direction;
  }

  @override
  Widget build(BuildContext context) {
    String direction = getDirection(heading ?? 0);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 7, 50, 85),
        centerTitle: true,
        title: Text("Compass Navigation"),
        foregroundColor: Color.fromARGB(255, 186, 229, 15),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "${heading!.ceil()}° $direction",
            style: TextStyle(
                color: Colors.white,
                fontSize: 26.0,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 50.0,
          ),

          //Let's show the compass
          Padding(
            padding: EdgeInsets.all(18.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset("assets/cadrant.png"),
                Transform.rotate(
                  angle: ((heading ?? 0) * (pi / 180) * -1),
                  child: Image.asset(
                    "assets/compass.png",
                    scale: 1.1,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
