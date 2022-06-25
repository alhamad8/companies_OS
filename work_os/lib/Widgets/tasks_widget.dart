import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:work_os/services/global_methods.dart';

import '../constants/constant.dart';
import '../screens/task_details.dart';

class TaskWidget extends StatefulWidget {
  String? taskTitle;
  String? taskDescription;
  String? taskID;
  String? uploadedBy;
  final bool isDone;

  TaskWidget({
    Key? key,
    required this.taskTitle,
    required this.taskDescription,
    required this.taskID,
    required this.uploadedBy,
    required this.isDone,
  }) : super(key: key);

  @override
  State<TaskWidget> createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: ListTile(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>  TaskDetailsScreen(
                  taskID: widget.taskID,
                  uploadedBy: widget.uploadedBy,
                ),
              ));
        },
        onLongPress: () {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    actions: [
                      TextButton(
                          onPressed: () {
                            User? user = _auth.currentUser;
                            String _uid = user!.uid;
                            if (_uid == widget.uploadedBy) {
                              FirebaseFirestore.instance
                                  .collection('tasks')
                                  .doc(widget.taskID)
                                  .delete();
                              Navigator.pop(context);
                            } else {
                              GlobalMethods.showError(
                                  error:
                                      'You dont have access to delete this task',
                                  context: context);
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.delete,
                                color: Constant.red,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                "Delete",
                                style: TextStyle(color: Constant.red),
                              )
                            ],
                          ))
                    ],
                  ));
        },
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        leading: Container(
          padding: const EdgeInsets.only(right: 15),
          decoration: BoxDecoration(
              border: Border(right: BorderSide(width: 1, color: Constant.red))),
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius:
                20, //https://cdn-icons-png.flaticon.com/128/3095/3095036.png
            child: Image.network(widget.isDone
                ? "https://cdn-icons-png.flaticon.com/128/390/390973.png"
                : 'https://cdn-icons-png.flaticon.com/128/3095/3095036.png'), //https://cdn-icons-png.flaticon.com/128/190/190411.png
          ),
        ),
        title: Text(
          widget.taskTitle!,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.linear_scale,
              color: Constant.red,
            ),
            Text(
              widget.taskDescription!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 18),
            )
          ],
        ),
        trailing: Icon(
          Icons.keyboard_arrow_right,
          size: 30,
          color: Constant.red,
        ),
      ),
    );
  }
}
