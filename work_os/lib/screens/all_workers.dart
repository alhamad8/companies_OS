import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../Widgets/all_workers_widget.dart';
import '../Widgets/drawer.dart';
import '../Widgets/tasks_widget.dart';
import '../constants/constant.dart';

class AllWorkers extends StatelessWidget {
  const AllWorkers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
        drawer: const DrawerWidget(),
        appBar: AppBar(
          leading: Builder(
            builder: (ctx) => IconButton(
                onPressed: () {
                  Scaffold.of(ctx).openDrawer();
                },
                icon: Icon(
                  Icons.menu_outlined,
                  color: Constant.red,
                )),
          ),
          title: Text(
            "All Workers",
            style: TextStyle(color: Constant.red),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.data!.docs.isNotEmpty) {
                return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: ((context, index) {
                      return  AllWorkersWidget(
                        userId:snapshot.data!.docs[index]['id'] ,
                        userName:snapshot.data!.docs[index]['name'] ,
                        userEmail:snapshot.data!.docs[index]['email'] ,
                        userImageurl:snapshot.data!.docs[index]['userImageUrl'] ,
                        positionInCompany:snapshot.data!.docs[index]['positionInCompany'], 
                        phoneNumber: snapshot.data!.docs[index]['phoneNumber'], 
                      );
                    }));
              }
            } else {
              return const Center(
                child: Text("No users found"),
              );
            }
              return const Center(
                child: Text("Some thing went wrong "),
              );
          },
        )
        );
  }
}
