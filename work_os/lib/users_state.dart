import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:work_os/constants/constant.dart';
import 'package:work_os/screens/login.dart';
import 'package:work_os/screens/tasks.dart';

class UsersState extends StatelessWidget {
  const UsersState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, usersnapshot) {
        // ignore: unnecessary_null_comparison
        if (usersnapshot == null) {
          return const LoginScreen();
        } else if (usersnapshot.hasData) {
          return TasksScreen();
        }
        return LoginScreen();

        // Scaffold(
        //   body: Center(
        //       child: Text(
        //     "Something went wrong",
        //     style: TextStyle(
        //         fontSize: 20, fontWeight: FontWeight.bold, color: Constant.red),
        //   )),
        // );
      },
    );
  }
}
