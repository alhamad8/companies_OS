import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:work_os/constants/constant.dart';
import 'package:work_os/screens/addTask.dart';
import 'package:work_os/screens/all_workers.dart';
import 'package:work_os/screens/login.dart';
import 'package:work_os/screens/profile.dart';
import 'package:work_os/screens/tasks.dart';
import 'package:work_os/services/global_methods.dart';
import 'package:work_os/users_state.dart';

import 'listTile.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(children: [
        DrawerHeader(
            decoration: const BoxDecoration(color: Colors.cyan),
            child: Column(
              children: [
                Flexible(
                    child: Image.network(
                        'https://cdn-icons-png.flaticon.com/128/3095/3095036.png')),
                const SizedBox(
                  height: 20,
                ),
                Flexible(
                    child: Text(
                  "Work os",
                  style: TextStyle(
                      color: Constant.darkBlue,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic),
                ))
              ],
            )),
        const SizedBox(
          height: 30,
        ),
        CustomListTile(
            label: "All Tasks",
            onTapfun: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TasksScreen(),
                  ));
            },
            icon: Icons.task_outlined),
        CustomListTile(
            label: "My Account",
            onTapfun: () {
                final FirebaseAuth _auth = FirebaseAuth.instance;
                final User? user =_auth.currentUser;
                final uid = user!.uid;

              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>  ProfileScreen(userId:uid ),
                  ));
            },
            icon: Icons.settings_outlined),
        CustomListTile(
            label: "Registered Workers",
            onTapfun: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AllWorkers(),
                  ));
            },
            icon: Icons.workspaces_outline),
        CustomListTile(
            label: "Add Task",
            onTapfun: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddTaskScreen(),
                  ));
            },
            icon: Icons.add_task_outlined),
        const Divider(
          thickness: 1,
        ),
        CustomListTile(
          label: "Log out",
          onTapfun: () {
           GlobalMethods.logOut(context);
          },
          icon: Icons.logout_outlined,
        )
      ]),
    );
  }

 
}
