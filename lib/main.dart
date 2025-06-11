import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vsga/pages/auth_page.dart';
import 'package:vsga/pages/home_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Request permissions
  await _requestPermissions();
  
  runApp(MyApp());
}

Future<void> _requestPermissions() async {
  await Permission.location.request();
  await Permission.locationWhenInUse.request();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location Tracker App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AuthScreen(),
      routes: {
        '/home': (context) => HomeScreen(),
        '/auth': (context) => AuthScreen(),
      },
    );
  }
}