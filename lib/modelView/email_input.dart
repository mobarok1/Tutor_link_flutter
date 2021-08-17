import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:tutorlink/api/api_request.dart';
import 'package:tutorlink/extra/theme_data.dart';
import 'package:http/http.dart' as http;
import 'package:tutorlink/modelView/password_reset.dart';

class EmailInputDialogModel extends StatefulWidget {
  @override
  _EmailInputDialogModelState createState() => _EmailInputDialogModelState();
}

class _EmailInputDialogModelState extends State<EmailInputDialogModel> {
  TextEditingController controller = TextEditingController();
  bool emailError = false,confirming = false,loading = false;
  String email = "";
  @override
  Widget build(BuildContext context) {
    return loading?Container(
        height: 200,
        width: 300,
        child: loader
    ):confirming?ChangePassword(
      userName: email.trim(),
    ):Container(
      height: 200,
      width: 300,
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              keyboardType: TextInputType.emailAddress,
              autofocus: false,
              autocorrect: false,
              textInputAction: TextInputAction.done,
              onChanged: (str){
                setState(() {
                  email = str;
                });
              },
              decoration: new InputDecoration(
                hintText: "Email",
                labelText: "Email",
                errorText: emailError?"Invalid Email":null,
                labelStyle: TextStyle(
                    color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: appsMainColor, width: 2)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: appsMainColor,
                    )),
                contentPadding:
                EdgeInsets.only(left: 15, bottom: 0, top: 0, right: 15),
              ),
              controller: controller,
            ),
            Container(
              margin: EdgeInsets.only(
                top: 10
              ),
              child: FlatButton(
                  color: appsMainColor,
                  disabledColor: Colors.grey,
                  textColor: email.length==0?Colors.black:Colors.white,
                  onPressed: email.length==0?null:(){
                    sendResetCode();
                  },
                  child: Text("Submit")),
            ),
            Container(
              margin: EdgeInsets.only(
                  top: 10
              ),
              child: FlatButton(
                  color: subColor,
                  textColor: Colors.white,
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text("Close")),
            )

          ],
        ),
      ),
    );
  }
  bool validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    return (!regex.hasMatch(value)) ? false : true;
  }
  sendResetCode() async{
    if(!validateEmail(email)){
      setState(() {
        emailError = true;
      });
    }else{
      setState(() {
        loading = true;
      });
      bool response = await ApiRequest(context).sendPasswordResetCode(email.trim());
      setState(() {
        loading = false;
      });
      if(response){
        Toast.show('Please Check Your Email', context, duration: 2, backgroundColor: Colors.green, textColor: Colors.black);
        setState(() {
          confirming = true;
        });
      }else{
        Toast.show('Failed to Send Code', context, duration: 2, backgroundColor: Colors.yellow, textColor: Colors.black);
      }
    }
  }

}
