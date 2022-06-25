import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../Widgets/drawer.dart';
import '../Widgets/tasks_widget.dart';
import '../constants/constant.dart';

class TasksScreen extends StatefulWidget {
  TasksScreen({Key? key}) : super(key: key);

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String? TaskCategory;
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
          actions: [
            IconButton(
                onPressed: () {
                  showTaskCategory(context, size);
                },
                icon: Icon(
                  Icons.filter_list_outlined,
                  color: Constant.red,
                ))
          ],
          title: Text(
            "Tasks",
            style: TextStyle(color: Constant.red),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('tasks')
              .where('taskCategory', isEqualTo: TaskCategory).orderBy('createdAt',descending: true)
              .snapshots(),
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
                      return TaskWidget(
                        taskTitle: snapshot.data!.docs[index]['taskTitle'],
                        taskDescription: snapshot.data!.docs[index]
                            ['taskDescription'],
                        uploadedBy: snapshot.data!.docs[index]['uploadedBy'],
                        taskID: snapshot.data!.docs[index]['taskID'],
                        isDone: snapshot.data!.docs[index]['isDone'],
                      );
                    }));
              }
            } else {
              return const Center(
                child: Text("No tasks has been uploaded "),
              );
            }
            return const Center(
              child: Text("No tasks has been uploaded "),
            );
          },
        ));
  }

  showTaskCategory(BuildContext context, Size size) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                "Task category",
                style: TextStyle(color: Constant.red, fontSize: 20),
              ),
              content: Container(
                width: size.width * 0.9,
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: Constant.taskCategories.length,
                    itemBuilder: ((context, index) => InkWell(
                          onTap: () {
                            print(Constant.taskCategories[index]);
                            setState(() {
                              TaskCategory = Constant.taskCategories[index];
                            });
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: Constant.red,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  Constant.taskCategories[index],
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                        ))),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.canPop(context) ? Navigator.pop(context) : null;
                    },
                    child: const Text("close")),
                TextButton(
                    onPressed: () {
                      setState(() {
                        TaskCategory = null;
                      });
                      Navigator.canPop(context) ? Navigator.pop(context) : null;
                    },
                    child: const Text("Cancel")),
              ],
            ));
  }
}
