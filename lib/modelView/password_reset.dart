import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:tutorlink/api/api_request.dart';
import 'package:tutorlink/extra/theme_data.dart';
import 'package:tutorlink/widgets/input_fields.dart';

class ChangePassword extends StatefulWidget {
  String userName;
  ChangePassword({this.userName});
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  TextEditingController codeController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController repeatPasswordController = TextEditingController();
  bool codeError = false,passwordError = false,rePasswordError = false,loading = false;
  @override
  Widget build(BuildContext context) {
    return loading ?Container(
      height: 200,
      width: 300,
      child: loader,
    ):SingleChildScrollView(
      child: Column(
        children: [
          InputField1(hintText: "Code",
              controller: codeController,
              obSecure: false,
              errorText: codeError?"required":null,
          ),
          SizedBox(
            height: 10,
          ),
          InputField1(hintText: "New Password",
              controller: passwordController,
              obSecure: true,
            errorText: passwordError?"required":null,
          ),
          SizedBox(
            height: 10,
          ),
          InputField1(hintText: "Re-type Password",
              controller: repeatPasswordController,
              obSecure: true,
              errorText: rePasswordError?"didn't match":null,
          ),
          SizedBox(
            height: 10,
          ),
          FlatButton(
            color: appsMainColor,
              textColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 25,vertical: 10),
              onPressed: (){
                changePasswordToServer();
              },
              child:Text("Change")
          )
        ],
      ),
    );
  }
  validateData(){
    bool validate = true;
    if(codeController.text.isEmpty){
      codeError = true;
      validate = false;
    }else{
      codeError = false;
    }
    if(passwordController.text.isEmpty){
      passwordError = true;
      validate = false;
    }else{
      passwordError = false;
    }
    if(repeatPasswordController.text != passwordController.text){
      rePasswordError = true;
      validate = false;
    }else{
      rePasswordError = false;
    }
    return validate;
  }
  changePasswordToServer() async{
    if(!validateData()){
      setState(() {

      });
      return;
    }
    setState(() {
      loading = true;
    });
    bool response  = await ApiRequest(context).changePassword(widget.userName, passwordController.text.trim(), codeController.text.trim());
    if(response){
      Toast.show("Changed Successful", context, backgroundColor: Colors.green, textColor: Colors.white);
      Navigator.pop(context);
    }else{
      Toast.show("Failed to change password", context, backgroundColor: Colors.red, textColor: Colors.white);
    }
    setState(() {
      loading = false;
    });
  }
}
