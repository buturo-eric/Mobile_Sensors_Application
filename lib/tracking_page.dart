import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:sensors_application/main.dart';
import 'package:sensors_application/Components/consts.dart';
import 'package:sensors_application/welcome.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Location _locationController = Location();
  Set<String> notifiedGeofences = {};

  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  static const LatLng _pGooglePlex = LatLng(37.4223, -122.0848);
  static const LatLng _pApplePark = LatLng(37.3346, -122.0090);
  LatLng? _currentP;

  Map<PolylineId, Polyline> polylines = {};
  Set<Circle> circles = {};

  @override
  void initState() {
    super.initState();
    getLocationUpdates().then(
      (_) {
        getPolylinePoints().then((coordinates) {
          generatePolyLineFromPoints(coordinates);
          // Add circles (geofences)
          addCircles();
          // Start monitoring geofences
          startGeofenceMonitoring();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Google Map Location',
          style: TextStyle(color: Color.fromARGB(255, 186, 229, 15)),
        ),
        backgroundColor: Color.fromARGB(255, 7, 50, 85),
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => MyWelcomeApp(),
              ),
            );
          },
        ),
      ),
      body: _currentP == null
          ? const Center(
              child: Text("Refreshing..."),
            )
          : GoogleMap(
              onMapCreated: ((GoogleMapController controller) =>
                  _mapController.complete(controller)),
              initialCameraPosition: CameraPosition(
                target: _pGooglePlex,
                zoom: 13,
              ),
              markers: {
                Marker(
                  markerId: MarkerId("_currentLocation"),
                  icon: BitmapDescriptor.defaultMarker,
                  position: _currentP!,
                ),
                Marker(
                    markerId: MarkerId("_sourceLocation"),
                    icon: BitmapDescriptor.defaultMarker,
                    position: _pGooglePlex),
                Marker(
                    markerId: MarkerId("_destinationLocation"),
                    icon: BitmapDescriptor.defaultMarker,
                    position: _pApplePark),
              },
              polylines: Set<Polyline>.of(polylines.values),
              circles: circles,
            ),
    );
  }

  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition _newCameraPosition = CameraPosition(
      target: pos,
      zoom: 13,
    );
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(_newCameraPosition),
    );
  }

  Future<void> getLocationUpdates() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _locationController.serviceEnabled();
    if (_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
    } else {
      return;
    }

    _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationController.onLocationChanged
        .listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          _currentP =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
          _cameraToPosition(_currentP!);
        });

        // Check if the device is inside any geofences
        checkGeofences(currentLocation.latitude!, currentLocation.longitude!);
      }
    });
  }

  Future<List<LatLng>> getPolylinePoints() async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      GOOGLE_MAPS_API_KEY,
      PointLatLng(_pGooglePlex.latitude, _pGooglePlex.longitude),
      PointLatLng(_pApplePark.latitude, _pApplePark.longitude),
      travelMode: TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }
    return polylineCoordinates;
  }

  void generatePolyLineFromPoints(List<LatLng> polylineCoordinates) async {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.black,
        points: polylineCoordinates,
        width: 8);
    setState(() {
      polylines[id] = polyline;
    });
  }

  void addCircles() {
    // Add circles (geofences)
    circles.add(
      Circle(
        circleId: CircleId('Home'),
        center: LatLng(-1.957528, 30.130109),
        radius: 800,
        fillColor: Colors.green.withOpacity(0.3),
        strokeColor: Colors.green,
        strokeWidth: 2,
      ),
    );
    circles.add(
      Circle(
        circleId: CircleId('Work'),
        center: LatLng(-1.954590, 30.093602),
        radius: 600,
        fillColor: Colors.blue.withOpacity(0.3),
        strokeColor: Colors.blue,
        strokeWidth: 2,
      ),
    );
    circles.add(
      Circle(
        circleId: CircleId('School'),
        center: LatLng(-1.956135, 30.104433),
        radius: 600,
        fillColor: Colors.red.withOpacity(0.3),
        strokeColor: Colors.red,
        strokeWidth: 2,
      ),
    );
    setState(() {});
  }

  void startGeofenceMonitoring() {
    _locationController.onLocationChanged
        .listen((LocationData currentLocation) {
      // Check if the device is inside any geofences
      checkGeofences(currentLocation.latitude!, currentLocation.longitude!);
    });
  }

  void checkGeofences(double latitude, double longitude) {
    // Define the coordinates of geofences
    Map<String, LatLng> geofences = {
      'Home': LatLng(-1.957528, 30.130109),
      'Work': LatLng(-1.954590, 30.093602),
      'School': LatLng(-1.956135, 30.104433),
    };

    // Check if the device is inside any geofence
    for (String key in geofences.keys) {
      double distance = calculateDistance(
        latitude,
        longitude,
        geofences[key]!.latitude,
        geofences[key]!.longitude,
      );

      // If the distance is less than the radius of the geofence (in meters), the device is inside the geofence
      if (distance <= 600) {
        if (!notifiedGeofences.contains(key)) {
          // Trigger action/notification for entering geofence
          print('Entered $key Geofence');
          _triggerInSideNotification(
              key); // Notify that user entered the geofence
          notifiedGeofences
              .add(key); // Add the geofence to the set of notified geofences
        }
      } else {
        if (notifiedGeofences.contains(key)) {
          // Trigger action/notification for exiting geofence
          print('Exited $key Geofence');
          _triggerOutSideNotification(
              key); // Notify that user exited the geofence
          notifiedGeofences.remove(
              key); // Remove the geofence from the set of notified geofences
        }
      }
    }
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000.0; // Earth radius in meters

    // Convert degrees to radians
    double lat1Rad = degreesToRadians(lat1);
    double lon1Rad = degreesToRadians(lon1);
    double lat2Rad = degreesToRadians(lat2);
    double lon2Rad = degreesToRadians(lon2);

    // Compute the distance
    double dlon = lon2Rad - lon1Rad;
    double dlat = lat2Rad - lat1Rad;

    double a = (pow(sin(dlat / 2), 2) +
            cos(lat1Rad) * cos(lat2Rad) * pow(sin(dlon / 2), 2))
        .abs();
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }

  double degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }
}

void _triggerInSideNotification(String Message) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'Map_channel',
    'Map Notifications',
    importance: Importance.max,
    priority: Priority.high,
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    0,
    'Geofence Alert!',
    'Inside Geographical Boundaries of $Message',
    platformChannelSpecifics,
  );
  print('Inside geofence notification sent');
}

void _triggerOutSideNotification(String Message) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'Map_channel',
    'Map Notifications',
    importance: Importance.max,
    priority: Priority.high,
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    0,
    'Geofence Alert!',
    'Outside Geographical Boundaries of $Message',
    platformChannelSpecifics,
  );
  print('Inside geofence notification sent');
}





// import 'dart:async';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';

// class OrderTrackingPage extends StatefulWidget {
//   const OrderTrackingPage({Key? key}) : super(key: key);

//   @override
//   State<OrderTrackingPage> createState() => _OrderTrackingPageState();
// }

// class _OrderTrackingPageState extends State<OrderTrackingPage> {
//   final Completer<GoogleMapController> _controller = Completer();

//   LocationData? currentLocation;
//   LocationData? initialLocation;
//   late Location location;
//   late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
//   bool isInsideGeofence = false; // Track whether inside or outside the geofence
//   static const double geofenceRadius = 1000.0; // Geofence radius in meters

//   void initializeNotifications() {
//     flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//     var initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//     var initializationSettings =
//         InitializationSettings(android: initializationSettingsAndroid);
//     flutterLocalNotificationsPlugin.initialize(initializationSettings);
//   }

//   @override
//   void initState() {
//     super.initState();
//     location = Location();
//     initializeNotifications();
//     getCurrentLocation();
//   }

//   void getCurrentLocation() async {
//     bool _serviceEnabled;
//     PermissionStatus _permissionGranted;

//     _serviceEnabled = await location.serviceEnabled();
//     if (!_serviceEnabled) {
//       _serviceEnabled = await location.requestService();
//       if (!_serviceEnabled) {
//         return;
//       }
//     }

//     _permissionGranted = await location.hasPermission();
//     if (_permissionGranted == PermissionStatus.denied) {
//       _permissionGranted = await location.requestPermission();
//       if (_permissionGranted != PermissionStatus.granted) {
//         return;
//       }
//     }

//     location.getLocation().then((LocationData loc) {
//       setState(() {
//         currentLocation = loc;
//         initialLocation = loc; // Set the initial location for geofencing
//       });
//       if (_controller.isCompleted) {
//         _controller.future.then((mapController) {
//           mapController.animateCamera(
//             CameraUpdate.newCameraPosition(
//               CameraPosition(
//                 target: LatLng(loc.latitude!, loc.longitude!),
//                 zoom: 15.0,
//               ),
//             ),
//           );
//         });
//       }
//     });

//     location.onLocationChanged.listen((LocationData newLoc) {
//       setState(() {
//         currentLocation = newLoc;
//       });
//       checkGeofence(newLoc);
//     });
//   }

//   void checkGeofence(LocationData loc) {
//     if (initialLocation == null) return;

//     double distance = calculateDistance(loc.latitude!, loc.longitude!,
//         initialLocation!.latitude!, initialLocation!.longitude!);
//     if (distance < geofenceRadius && !isInsideGeofence) {
//       sendNotification("Entered dynamic geofence area");
//       isInsideGeofence = true;
//     } else if (distance > geofenceRadius && isInsideGeofence) {
//       sendNotification("Exited dynamic geofence area");
//       isInsideGeofence = false;
//     }
//   }

//   double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
//     var p = 0.017453292519943295; // Pi/180
//     var c = cos; // Trigonometric function cosine
//     var a = 0.5 -
//         c((lat2 - lat1) * p) / 2 +
//         c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
//     return 12742 * asin(sqrt(a)); // 2*R*asin...
//   }

//   void sendNotification(String message) {
//     var androidDetails = AndroidNotificationDetails('channelId', 'channelName',
//         channelDescription: 'Notification channel for location tracking');
//     var generalNotificationDetails =
//         NotificationDetails(android: androidDetails);
//     flutterLocalNotificationsPlugin.show(
//         0, 'Geofence Alert', message, generalNotificationDetails);
//   }

//   @override
//   Widget build(BuildContext context) {
//     LatLng initialPosition = currentLocation != null
//         ? LatLng(currentLocation!.latitude!, currentLocation!.longitude!)
//         : LatLng(0.0,
//             0.0); // Default to a neutral position if no location data is available

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Color.fromARGB(255, 7, 50, 85),
//         title: Center(
//             child: Text("GPS TRACKER",
//                 style: TextStyle(
//                     color: Color.fromARGB(255, 186, 229, 15), fontSize: 23))),
//       ),
//       body: GoogleMap(
//         initialCameraPosition:
//             CameraPosition(target: initialPosition, zoom: 15.0),
//         markers: {
//           if (currentLocation != null)
//             Marker(
//                 markerId: const MarkerId("currentLocation"),
//                 position: LatLng(
//                     currentLocation!.latitude!, currentLocation!.longitude!)),
//         },
//         onMapCreated: (GoogleMapController controller) {
//           _controller.complete(controller);
//         },
//       ),
//     );
//   }
// }

//Good Condition but had a default set location

// import 'dart:async';
// import 'dart:math'; // Import the math library
// import 'package:location/location.dart';
// import 'package:flutter/material.dart';
// import 'package:sensors_application/Components/constants.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class OrderTrackingPage extends StatefulWidget {
//   const OrderTrackingPage({Key? key}) : super(key: key);

//   @override
//   State<OrderTrackingPage> createState() => _OrderTrackingPageState();
// }

// class _OrderTrackingPageState extends State<OrderTrackingPage> {
//   final Completer<GoogleMapController> _controller = Completer();

//   // Using Kigali International Airport as a reference location
//   static const LatLng kigaliAirport = LatLng(-1.962535, 30.130143);

//   List<LatLng> polylineCoordinates = [];
//   LocationData? currentLocation;

//   late Location location;
//   late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

//   bool isInsideGeofence = false; // Track whether inside or outside the geofence

//   void initializeNotifications() {
//     flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//     var initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//     var initializationSettings =
//         InitializationSettings(android: initializationSettingsAndroid);
//     flutterLocalNotificationsPlugin.initialize(initializationSettings);
//   }

//   @override
//   void initState() {
//     super.initState();
//     location = Location();
//     initializeNotifications();
//     getCurrentLocation();
//   }

//   void getCurrentLocation() async {
//     bool _serviceEnabled;
//     PermissionStatus _permissionGranted;

//     _serviceEnabled = await location.serviceEnabled();
//     if (!_serviceEnabled) {
//       _serviceEnabled = await location.requestService();
//       if (!_serviceEnabled) {
//         return;
//       }
//     }

//     _permissionGranted = await location.hasPermission();
//     if (_permissionGranted == PermissionStatus.denied) {
//       _permissionGranted = await location.requestPermission();
//       if (_permissionGranted != PermissionStatus.granted) {
//         return;
//       }
//     }

//     location.onLocationChanged.listen((LocationData currentLoc) {
//       setState(() {
//         currentLocation = currentLoc;
//       });

//       checkGeofence(currentLoc, kigaliAirport, "Kigali Airport");
//     });
//   }

//   void checkGeofence(LocationData loc, LatLng boundary, String placeName) {
//     double distance = calculateDistance(
//         loc.latitude!, loc.longitude!, boundary.latitude, boundary.longitude);
//     if (distance < 1000 && !isInsideGeofence) {
//       // Less than 1000 meters, considered inside the geofence
//       sendNotification("Entered $placeName");
//       isInsideGeofence = true;
//     } else if (distance > 1000 && isInsideGeofence) {
//       // More than 1000 meters, considered outside the geofence
//       sendNotification("Exited $placeName");
//       isInsideGeofence = false;
//     }
//   }

//   double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
//     var p = 0.017453292519943295; // Pi/180
//     var c = cos; // Trigonometric function cosine
//     var a = 0.5 -
//         c((lat2 - lat1) * p) / 2 +
//         c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
//     return 12742 * asin(sqrt(a)); // 2*R*asin...
//   }

//   void sendNotification(String message) {
//     var androidDetails = AndroidNotificationDetails('channelId', 'channelName',
//         channelDescription: 'Notification channel for location tracking');
//     var generalNotificationDetails =
//         NotificationDetails(android: androidDetails);
//     flutterLocalNotificationsPlugin.show(
//         0, 'Geofence Alert', message, generalNotificationDetails);
//   }

//   Set<Circle> circles = Set.from([
//     Circle(
//       circleId: CircleId("kigaliAirportGeofence"),
//       center: kigaliAirport,
//       radius: 1000, // Geofence radius in meters
//       fillColor: Colors.blue.withOpacity(0.5),
//       strokeColor: Colors.blue,
//       strokeWidth: 1,
//     )
//   ]);

//   @override
//   Widget build(BuildContext context) {
//     LatLng initialPosition = currentLocation != null
//         ? LatLng(currentLocation!.latitude!, currentLocation!.longitude!)
//         : kigaliAirport;

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Color.fromARGB(255, 7, 50, 85),
//         title: Center(
//             child: Text("GPS TRACKER",
//                 style: TextStyle(
//                     color: Color.fromARGB(255, 186, 229, 15), fontSize: 23))),
//       ),
//       body: GoogleMap(
//         initialCameraPosition:
//             CameraPosition(target: initialPosition, zoom: 13.5),
//         markers: {
//           if (currentLocation != null)
//             Marker(
//                 markerId: const MarkerId("currentLocation"),
//                 position: LatLng(
//                     currentLocation!.latitude!, currentLocation!.longitude!)),
//           Marker(markerId: MarkerId("airport"), position: kigaliAirport),
//         },
//         circles: circles,
//         onMapCreated: (GoogleMapController controller) {
//           _controller.complete(controller);
//         },
//       ),
//     );
//   }
// }