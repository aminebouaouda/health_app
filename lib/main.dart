import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:health_app/globals.dart';
import 'package:health_app/screens/doctor/main_page_doctor.dart';
import 'package:health_app/screens/doctor_or_patient.dart';
import 'package:health_app/screens/firebase_auth.dart';
import 'package:health_app/screens/my_profile.dart';
import 'package:health_app/screens/patient/appointments.dart';
import 'package:health_app/screens/patient/doctor_profile.dart';
import 'package:health_app/screens/patient/main_page_patient.dart';
import 'package:health_app/screens/skip.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase for all platforms(android, ios, web)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Print Realtime Database Collections Schema
  await printRealtimeDatabaseSchema('users');

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? user;

  Future<void> _getUser() async {
    user = _auth.currentUser!;
  }

  @override
  Widget build(BuildContext context) {
    _getUser();
    return MaterialApp(
      initialRoute: '/',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/': (context) => user == null ? const Skip() : const DoctorOrPatient(),
        '/login': (context) => const FireBaseAuth(),
        '/home': (context) =>
            isDoctor ? const MainPageDoctor() : const MainPagePatient(),
        '/profile': (context) => const MyProfile(),
        '/MyAppointments': (context) => const Appointments(),
        '/DoctorProfile': (context) => DoctorProfile(),
      },
      theme: ThemeData(brightness: Brightness.light),
      debugShowCheckedModeBanner: false,
      // home: MainPageDoctor(),
      // home: ChatRoom(
      //   userId: '1234',
      // ),
    );
  }
}

Future<void> printRealtimeDatabaseSchema(String collectionName) async {
  print('Realtime Database Schema for $collectionName:');
  final DatabaseReference ref = FirebaseDatabase.instance.ref(collectionName);

  final DataSnapshot snapshot = await ref.get();

  if (snapshot.exists) {
    Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
    data.forEach((key, value) {
      print('Document ID: $key');
      if (value is Map) {
        
        value.forEach((fieldKey, fieldValue) {
          printFields(fieldValue, '');
        });
      }
    });
  } else {
    print('No data available.');
  }
}

void printFields(dynamic fieldValue, String prefix) {
  if (fieldValue is Map) {
    fieldValue.forEach((innerKey, innerValue) {
      if (innerValue is Map) {
        printFields(innerValue, '$prefix$innerKey/');
      } else {
        print('$prefix$innerKey: ${innerValue.runtimeType}');
      }
    });
  }
}
