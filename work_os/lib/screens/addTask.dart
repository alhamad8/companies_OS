// ignore: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';
import 'package:work_os/Widgets/drawer.dart';
import 'package:work_os/constants/constant.dart';
import 'package:work_os/services/global_methods.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({Key? key}) : super(key: key);

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  late final TextEditingController _categoryController =
      TextEditingController(text: 'Task Category');
  late final TextEditingController _titleController = TextEditingController();
  late final TextEditingController _discreptionController =
      TextEditingController();
  late final TextEditingController _dateController =
      TextEditingController(text: 'Pick up a date');
  final _uploadKey = GlobalKey<FormState>();
  DateTime? picked;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Timestamp? deadLineDateTimeStamp;
  bool _isLoading = false;

  @override
  void dispose() {
    _categoryController.dispose();
    _titleController.dispose();
    _discreptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void uploadFunc() async {
    User? user = _auth.currentUser;
    String _uid = user!.uid;
    final isValid = _uploadKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (isValid) {
      if (_dateController.text == 'Pick up a date' ||
          _categoryController.text == 'Task Category') {
        GlobalMethods.showError(
            context: context, error: "please pick up every thing");
        return;
      }
      setState(() {
        _isLoading = true;
      });
      final taskID = Uuid().v4();
      try {
        CollectionReference tasks =
            await FirebaseFirestore.instance.collection('tasks');
        tasks.doc(taskID).set({
          'taskID': taskID,
          'uploadedBy': _uid,
          'taskTitle': _titleController.text,
          'taskDescription': _discreptionController.text,
          'deadLineDate': _dateController.text,
          'deadLineDateTimeStamp': deadLineDateTimeStamp,
          'taskCategory': _categoryController.text,
          'taskComments': [],
          'isDone': false,
          'createdAt': Timestamp.now(),
        });
        Fluttertoast.showToast(
            msg: "Task has been uploaded successfuly",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            fontSize: 14.0);
        _discreptionController.clear();
        _titleController.clear();
        setState(() {
          _categoryController.text = 'Task Category';
          _dateController.text = 'Pick up a date';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Constant.darkBlue),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      drawer: const DrawerWidget(),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      "All fields are required",
                      style: TextStyle(
                        fontSize: 25,
                        color: Constant.darkBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const Divider(
                  thickness: 1,
                ),
                Form(
                    key: _uploadKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(textLAbel: "Task category"),
                        CustomTextFormField(
                            valueKey: 'Task Category',
                            controllerr: _categoryController,
                            enabledd: false,
                            fct: () {
                              showTaskCategory(context, size);
                            },
                            maxLengthh: 100),
                        CustomText(textLAbel: "Task title"),
                        CustomTextFormField(
                            valueKey: 'Task title',
                            controllerr: _titleController,
                            enabledd: true,
                            fct: () {},
                            maxLengthh: 100),
                        CustomText(textLAbel: "Task Description"),
                        CustomTextFormField(
                            valueKey: 'TaskDescription',
                            controllerr: _discreptionController,
                            enabledd: true,
                            fct: () {},
                            maxLengthh: 1000),
                        CustomText(textLAbel: "Task deadline date*"),
                        CustomTextFormField(
                            valueKey: 'Task Deadline Date',
                            controllerr: _dateController,
                            enabledd: false,
                            fct: () {
                              pickedDate();
                            },
                            maxLengthh: 100),
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Center(
                            child: _isLoading
                                ? const CircularProgressIndicator()
                                : MaterialButton(
                                    onPressed: uploadFunc,
                                    color: Constant.red,
                                    elevation: 10,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        side: BorderSide.none),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                          child: Text(
                                            "Upload",
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Constant.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Icon(
                                          Icons.upload_file_outlined,
                                          color: Constant.white,
                                        )
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                          height: 10,
                        )
                      ],
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  void pickedDate() async {
    picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 10)),
        lastDate: DateTime(2200));
    if (picked != null) {
      setState(() {
        deadLineDateTimeStamp = Timestamp.fromMicrosecondsSinceEpoch(
            picked!.microsecondsSinceEpoch);
        _dateController.text =
            "${picked!.year}-${picked!.month}-${picked!.day}";
      });
    }
  }

  showTaskCategory(context, Size size) {
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
                            setState(() {
                              _categoryController.text =
                                  Constant.taskCategories[index];
                            });
                            Navigator.pop(context);
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
              ],
            ));
  }

  // ignore: non_constant_identifier_names
  CustomTextFormField(
      {required String valueKey,
      required TextEditingController controllerr,
      required bool enabledd,
      required Function fct,
      required int maxLengthh}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          fct();
        },
        child: TextFormField(
          controller: controllerr,
          validator: (value) {
            if (value!.isEmpty) {
              return "Field is missing";
            }
            return null;
          },
          enabled: enabledd,
          key: ValueKey(valueKey),
          style: TextStyle(
              color: Constant.darkBlue,
              fontWeight: FontWeight.bold,
              fontSize: 18),
          maxLines: valueKey == 'TaskDescription' ? 3 : 1,
          maxLength: maxLengthh,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
              focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red.shade700)),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Constant.white)),
              filled: true,
              fillColor: Theme.of(context).scaffoldBackgroundColor,
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Constant.red)),
              errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red.shade700))),
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  CustomText({String? textLAbel}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        textLAbel!,
        style: TextStyle(
          fontSize: 18,
          color: Constant.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
