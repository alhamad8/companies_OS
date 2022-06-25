import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/constant.dart';
import '../screens/profile.dart';

class AllWorkersWidget extends StatefulWidget {
  final String? userId;
  final String? userName;
  final String? userEmail;
  final String? positionInCompany;
  final String? userImageurl;
  final String? phoneNumber;
  const AllWorkersWidget({
    Key? key,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.positionInCompany,
    required this.userImageurl,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  State<AllWorkersWidget> createState() => _AllWorkersWidgetState();
}

class _AllWorkersWidgetState extends State<AllWorkersWidget> {
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
                    builder: (context) =>  ProfileScreen(userId:widget.userId ),
                  ));
          },
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          leading: Container(
            padding: const EdgeInsets.only(right: 15),
            decoration: BoxDecoration(
                border:
                    Border(right: BorderSide(width: 1, color: Constant.red))),
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              radius:
                  20, //https://cdn-icons-png.flaticon.com/128/3095/3095036.png
              child: Image.network(widget.userImageurl == null
                  ? "https://cdn-icons-png.flaticon.com/128/3135/3135715.png"
                  : widget
                      .userImageurl!), //https://cdn-icons-png.flaticon.com/128/190/190411.png
            ),
          ),
          title: Text(
            widget.userName!,
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
                "${widget.positionInCompany}/${widget.phoneNumber}",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 18),
              )
            ],
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.mail,
              size: 30,
              color: Constant.red,
            ),
            onPressed: mailTo,
          )),
    );
  }

  void mailTo() async {
    var url = 'mailto:${widget.userEmail}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(
        Uri.parse(url),
      );
    } else {
      throw 'Error occured ccould\'t open link';
    }
  }
}
