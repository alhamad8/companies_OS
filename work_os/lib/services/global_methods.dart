
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../users_state.dart';

class GlobalMethods {

 static void showError({required String error,required BuildContext context}) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(
              children: const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.logout_sharp,
                    size: 25,
                    color: Colors.blue,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Error",
                    style: TextStyle(color: Colors.blue),
                  ),
                )
              ],
            ),
            content: Text(error,
                style: const TextStyle(
                    color: Colors.blue, fontWeight: FontWeight.bold)),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.canPop(context) ? Navigator.pop(context) : null;
                  },
                  child: const Text("Ok", style: TextStyle(color: Colors.red))),
            ],
          );
        });
  }

  static  void logOut(context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(
              children: const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.logout_sharp,
                    size: 25,
                    color: Colors.blue,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Sign Out",
                    style: TextStyle(color: Colors.blue),
                  ),
                )
              ],
            ),
            content: const Text("Do you want to sign out?",
                style:
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.canPop(context) ? Navigator.pop(context) : null;
                  },
                  child: const Text("Cancel")),
              TextButton(
                  onPressed: ()async {
                   await _auth.signOut();
                    Navigator.canPop(context) ? Navigator.pop(context) : null;
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => UsersState(),
                    ));
                  },
                  child: const Text("Ok", style: TextStyle(color: Colors.red))),
            ],
          );
        });
  }

}