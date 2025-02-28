
import 'package:flutter/material.dart';
// import 'package:healthcare_app/screens/appointment_screen.dart';
import 'package:healthcare_app/screens/splash_screen.dart';
// import 'package:healthcare_app/screens/home_screen.dart';
// import 'package:healthcare_app/screens/doctors_screen.dart';
// import 'package:healthcare_app/screens/patient_screen.dart';
// import 'package:healthcare_app/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:healthcare_app/providers/auth_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Healthcare App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const SplashScreen(), // Set SplashScreen as initial route     //  home: const HomeScreen(),
        // home: AppointmentScreen(),
        //  home: DoctorsScreen(),
        //  home: HomeScreen(),
        // home: PatientScreen(),
      ),
    );
  }
}