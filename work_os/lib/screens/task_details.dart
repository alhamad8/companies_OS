import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';

import '../Widgets/comment_widget.dart';
import '../constants/constant.dart';
import '../services/global_methods.dart';

class TaskDetailsScreen extends StatefulWidget {
  String? taskID;
  String? uploadedBy;
  TaskDetailsScreen({
    Key? key,
    required this.taskID,
    required this.uploadedBy,
  }) : super(key: key);
  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  bool isCommintting = false;
  var contentStyle = TextStyle(
      color: Constant.darkBlue, fontSize: 15, fontWeight: FontWeight.bold);
  String? _autherName;
  String? _autherPosition;
  String? taskDescription;
  String? taskTitle;
  bool? _isDone;
  Timestamp? postedDateTimeStamp;
  Timestamp? deadLineDateTimesStamp;
  String? deadLineDate;
  String? postedDate;
  bool isDeadLineAvailable = false;
  String? userImageUrl;
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _commentController = TextEditingController();
  @override
  void dispose() {
    super.dispose();
    _commentController.dispose();
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    try {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uploadedBy)
          .get();
      if (userDoc == null) {
        return;
      } else {
        setState(() {
          _autherName = userDoc.get('name');
          _autherPosition = userDoc.get('positionInCompany');
          userImageUrl = userDoc.get('userImageUrl');
        });
      }
      final DocumentSnapshot taskDataBase = await FirebaseFirestore.instance
          .collection('tasks')
          .doc(widget.taskID)
          .get();
      if (taskDataBase == null) {
        return;
      } else {
        setState(() {
          taskTitle = taskDataBase.get('taskTitle');
          _isDone = taskDataBase.get('isDone');
          taskDescription = taskDataBase.get('taskDescription');
          postedDateTimeStamp = taskDataBase.get('createdAt');
          deadLineDate = taskDataBase.get('deadLineDate');
          deadLineDateTimesStamp = taskDataBase.get('deadLineDateTimeStamp');
          var postDate = postedDateTimeStamp!.toDate();
          postedDate = '${postDate.year}-${postDate.month}-${postDate.day}';
          var date = deadLineDateTimesStamp!.toDate();
          isDeadLineAvailable = date.isAfter(DateTime.now());
        });
      }
    } catch (e) {
      GlobalMethods.showError(error: 'An error occured', context: context);
    } finally {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "Back",
              style: TextStyle(
                  color: Constant.darkBlue,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  fontSize: 25),
            )),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 15,
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Text(
                taskTitle == null ? '' : taskTitle!,
                style: TextStyle(
                    color: Constant.darkBlue,
                    fontSize: 35,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Uploaded by",
                            style: TextStyle(
                                color: Constant.darkBlue,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: NetworkImage(userImageUrl == null
                                        ? 'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_1280.png'
                                        : userImageUrl!),
                                    fit: BoxFit.fill),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.pink.shade800, width: 3)),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_autherName == null ? '' : _autherName!,
                                  style: contentStyle),
                              Text(
                                _autherPosition == null ? '' : _autherPosition!,
                                style: contentStyle,
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Divider(
                        thickness: 2,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Uploaded on:",
                            style: TextStyle(
                                color: Constant.darkBlue,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            postedDate == null ? 'no date' : postedDate!,
                            style: TextStyle(
                                color: Constant.darkBlue,
                                fontSize: 15,
                                fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Deadline date:",
                            style: TextStyle(
                                color: Constant.darkBlue,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            deadLineDate == null ? 'no' : deadLineDate!,
                            style: TextStyle(
                                color: Constant.red,
                                fontSize: 15,
                                fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: Text(
                          isDeadLineAvailable
                              ? 'Still have enough time'
                              : 'No time left',
                          style: TextStyle(
                              color: isDeadLineAvailable
                                  ? Colors.green
                                  : Colors.red,
                              fontSize: 15,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Divider(
                        thickness: 2,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Done state:",
                        style: TextStyle(
                            color: Constant.darkBlue,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Flexible(
                            child: TextButton(
                                onPressed: () {
                                  User? user = _auth.currentUser;
                                  String _uid = user!.uid;
                                  if (_uid == widget.uploadedBy) {
                                    FirebaseFirestore.instance
                                        .collection('tasks')
                                        .doc(widget.taskID)
                                        .update({'isDone': true});
                                    getData();
                                  } else {
                                    GlobalMethods.showError(
                                        error: 'You can\'t perform this action',
                                        context: context);
                                  }
                                },
                                child: Text("Done ",
                                    style: TextStyle(
                                        decoration: _isDone == true
                                            ? TextDecoration.underline
                                            : TextDecoration.none,
                                        color: Constant.darkBlue,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold))),
                          ),
                          Opacity(
                            opacity: _isDone == true ? 1 : 0,
                            child: const Icon(
                              Icons.check_box,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(
                            width: 40,
                          ),
                          Flexible(
                            child: TextButton(
                                onPressed: () {
                                  User? user = _auth.currentUser;
                                  String _uid = user!.uid;
                                  if (_uid == widget.uploadedBy) {
                                    FirebaseFirestore.instance
                                        .collection('tasks')
                                        .doc(widget.taskID)
                                        .update({'isDone': false});
                                    getData();
                                  } else {
                                    GlobalMethods.showError(
                                        error: 'You can\'t perform this action',
                                        context: context);
                                  }
                                },
                                child: Text("Not Done",
                                    style: TextStyle(
                                        decoration: _isDone == false
                                            ? TextDecoration.underline
                                            : TextDecoration.none,
                                        color: Constant.darkBlue,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold))),
                          ),
                          Opacity(
                            opacity: _isDone == false ? 1 : 0,
                            child: const Icon(
                              Icons.check_box,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Divider(
                        thickness: 2,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text("Task description",
                          style: TextStyle(
                              color: Constant.darkBlue,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      Text(taskDescription == null ? '' : taskDescription!,
                          style: TextStyle(
                              color: Constant.darkBlue,
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                              fontStyle: FontStyle.italic)),
                      const SizedBox(
                        height: 20,
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: isCommintting
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Flexible(
                                    flex: 3,
                                    child: TextField(
                                      maxLength: 200,
                                      controller: _commentController,
                                      style:
                                          TextStyle(color: Constant.darkBlue),
                                      keyboardType: TextInputType.text,
                                      maxLines: 6,
                                      decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          enabledBorder:
                                              const UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.white)),
                                          errorBorder:
                                              const UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.red)),
                                          focusedBorder:
                                              const OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.pink))),
                                    ),
                                  ),
                                  Flexible(
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        //mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          MaterialButton(
                                            onPressed: () async {
                                              if (_commentController
                                                      .text.length <
                                                  7) {
                                                GlobalMethods.showError(
                                                    error: 'Comment cant be less than 7 character',
                                                    context: context);
                                              } else {
                                                final _generatedId =
                                                    Uuid().v4();
                                                await FirebaseFirestore.instance
                                                    .collection('tasks')
                                                    .doc(widget.taskID)
                                                    .update({
                                                  'taskComments':
                                                      FieldValue.arrayUnion([
                                                    {
                                                      'userId':
                                                          widget.uploadedBy,
                                                      'commentId': _generatedId,
                                                      'name': _autherName,
                                                      'commentBody':
                                                          _commentController
                                                              .text,
                                                      'time': Timestamp.now(),
                                                      'userImageUrl':userImageUrl
                                                    }
                                                  ]),
                                                });
                                                await Fluttertoast.showToast(
                                                    msg:
                                                        "Task has been uploaded successfuly",
                                                    toastLength:
                                                        Toast.LENGTH_LONG,
                                                    gravity:
                                                        ToastGravity.CENTER,
                                                    fontSize: 16.0);
                                                _commentController.clear();
                                                setState(() {
                                                  
                                                });
                                              }
                                            },
                                            color: Colors.pink,
                                            elevation: 10,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                side: BorderSide.none),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12),
                                              child: Text(
                                                "Post",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Constant.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  isCommintting =
                                                      !isCommintting;
                                                });
                                              },
                                              child: const Text("Cancel"))
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              )
                            : Center(
                                child: MaterialButton(
                                  onPressed: () {
                                    setState(() {
                                      isCommintting = !isCommintting;
                                    });
                                  },
                                  color: Colors.pink,
                                  elevation: 10,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: BorderSide.none),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    child: Text(
                                      "Add comment",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Constant.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                          FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection('tasks')
                                    .doc(widget.taskID)
                                    .get(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else {
                                    if (snapshot.data == null) {
                                      return Container();
                                    }
                                  }
                                  return ListView.separated(
                                    reverse: true,
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemBuilder: (ctx, index) {
                                        return CommentWidget(
                                             commentId:
                                              snapshot.data!['taskComments']
                                                  [index]['commentId'],
                                          commentBody:
                                              snapshot.data!['taskComments']
                                                  [index]['commentBody'],
                                          commenterId:
                                              snapshot.data!['taskComments']
                                                  [index]['userId'],
                                          commenterName:
                                              snapshot.data!['taskComments']
                                                  [index]['name'],
                                          commenterImageUrl:
                                              snapshot.data!['taskComments']
                                                  [index]['userImageUrl'],
                                        );
                                      },
                                      separatorBuilder: (ctx, index) {
                                        return const Divider(
                                          thickness: 1,
                                        );
                                      },
                                      itemCount: snapshot
                                          .data!['taskComments'].length);
                                })
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
