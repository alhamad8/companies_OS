import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:work_os/Widgets/drawer.dart';
import 'package:work_os/services/global_methods.dart';

import '../constants/constant.dart';
import '../users_state.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;
  const ProfileScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;
  String? phonenumber;
  String? email;
  String? name;
  String? job;
  String? imageUrl;
  String? joinedAt;
  bool _isSameUSer = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void getUserData() async {
    _isLoading = true;
    try {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();
      if (userDoc == null) {
        return;
      } else {
        setState(() {
          email = userDoc.get('email');
          name = userDoc.get('name');
          phonenumber = userDoc.get('phoneNumber');
          job = userDoc.get('positionInCompany');
          imageUrl = userDoc.get('userImageUrl');
          Timestamp joinedAtTimeStamp = userDoc.get('createdAt');
          var joinedDate = joinedAtTimeStamp.toDate();
          joinedAt = '${joinedDate.year}-${joinedDate.month}-${joinedDate.day}';
        });
        User? user = _auth.currentUser;
        String _uid = user!.uid;
        setState(() {
          _isSameUSer = _uid == widget.userId;
        });
      }
    } catch (e) {
      GlobalMethods.showError(error: '$e', context: context);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      drawer: const DrawerWidget(),
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Stack(
            children: [
              Card(
                margin: const EdgeInsets.all(30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 80,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          name == null ? " " : name!,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.normal),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          "$job since $joinedAt",
                          style: TextStyle(
                              color: Constant.darkBlue,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.normal),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      const Divider(
                        thickness: 2,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      const Text(
                        "Contact info",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.normal),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      socialInfo(label: "Email: ", content: "$email"),
                      const SizedBox(
                        height: 10,
                      ),
                      socialInfo(
                          label: "Phone number: ", content: "$phonenumber"),
                      const SizedBox(
                        height: 30,
                      ),
                       _isSameUSer?Container():   Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          socialButton(
                              color: Colors.green,
                              icon: FontAwesomeIcons.whatsapp,
                              fct: openWhatsapp),
                          socialButton(
                              color: Colors.red,
                              icon: Icons.mail_outline,
                              fct: mailTo),
                          socialButton(
                              color: Colors.purple,
                              icon: Icons.call_outlined,
                              fct: callPhoneNumber),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                     _isSameUSer?Container(): const Divider(
                        thickness: 2,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                     !_isSameUSer?Container():   Center(
                        child: MaterialButton(
                          onPressed: () {
                            GlobalMethods.logOut(context);
                            // await _auth.signOut();
                            // Navigator.canPop(context)
                            //     ? Navigator.pop(context)
                            //     : null;
                            // Navigator.of(context)
                            //     .pushReplacement(MaterialPageRoute(
                            //   builder: (context) => UsersState(),
                            // ));
                          },
                          color: Constant.red,
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide.none),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.logout_outlined,
                                color: Constant.white,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  "Logout",
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Constant.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: size.width * 0.26,
                    height: size.height * 0.12,
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 5,
                            color: Theme.of(context).scaffoldBackgroundColor),
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: NetworkImage(
                          imageUrl == null
                              ? "https://cdn-icons-png.flaticon.com/128/3135/3135715.png"
                              : imageUrl!,
                        ))),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void openWhatsapp() async {
    var url =
        'https://api.whatsapp.com/send/?phone=$phonenumber&text=Helloahmad&app_absent=0';
    if (await canLaunchUrl(Uri.parse(
      url,
    ))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Error occured ccould\'t open link';
    }
  }

  void mailTo() async {
    String email = 'ahmadalhamad242@yahoo.com';
    var url = 'mailto:$email';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(
        Uri.parse(url),
      );
    } else {
      throw 'Error occured ccould\'t open link';
    }
  }

  void callPhoneNumber() async {
    var phoneUrl = 'tel:$phonenumber';
    if (await canLaunchUrl(Uri.parse(phoneUrl))) {
      await launchUrl(Uri.parse(phoneUrl));
    } else {
      throw 'Error in phone number';
    }
  }

  Widget socialInfo({required String label, required String content}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.normal),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              content,
              style: TextStyle(
                  color: Constant.darkBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.normal),
            ),
          ),
        ],
      ),
    );
  }

  CircleAvatar socialButton(
      {required Color color, required IconData icon, required Function fct}) {
    return CircleAvatar(
      backgroundColor: color,
      radius: 25,
      child: CircleAvatar(
        backgroundColor: Colors.white,
        radius: 22,
        child: IconButton(
            icon: Icon(icon, color: color),
            onPressed: () {
              fct();
            }),
      ),
    );
  }
}
