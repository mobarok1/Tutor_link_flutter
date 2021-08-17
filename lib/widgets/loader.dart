import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tutorlink/extra/theme_data.dart';

class ProgressLoader{
  static show() {
    Get.defaultDialog(
      title: "Loading",
      radius: 10,
      content: Container(
        padding: EdgeInsets.only(left: 20,right: 20),
        child: LinearProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(appsMainColor),
          backgroundColor: appsMainColor.withOpacity(.4),
        ),
      ),
      titleStyle: TextStyle(
        fontSize: 15
      )
    );
  }
  static close(){
    Get.back();
  }
}