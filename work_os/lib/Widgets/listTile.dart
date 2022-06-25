
  import 'package:flutter/material.dart';

import '../constants/constant.dart';

// ignore: non_constant_identifier_names
ListTile CustomListTile(
      {required String label,
      required Function onTapfun,
      required IconData icon}) {
    return ListTile(
      onTap: () {
        onTapfun();
      },
      leading: Icon(icon),
      title: Text(
        label,
        style: TextStyle(
            color: Constant.darkBlue,
            fontSize: 20,
            fontStyle: FontStyle.italic),
      ),
    );
  }