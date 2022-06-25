import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:work_os/users_state.dart';

import 'screens/login.dart';
import 'screens/profile.dart';
import 'screens/tasks.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(




  );
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  final Future<FirebaseApp> _appInitialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _appInitialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            const MaterialApp(
              home: Scaffold(
                  body: Center(
                child: Text(
                  "App is LOADING",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              )),
            );
          } else if (snapshot.hasError) {
            return const MaterialApp(
              home: Scaffold(
                  body: Center(
                child: Text(
                  "An error has occured",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              )),
            );
          }
          return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFFEDE7DC),
          primarySwatch: Colors.blue),
      home: const UsersState(),
    );
        });
  }
}
