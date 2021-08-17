import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:group_button/group_button.dart';
import 'package:toast/toast.dart';
import 'package:tutorlink/Pages/register_login/verify_email.dart';
import 'package:tutorlink/api/api_request.dart';
import 'package:tutorlink/extra/theme_data.dart';
import 'package:tutorlink/widgets/input_fields.dart';

class UserRegister extends StatefulWidget {
  @override
  _UserRegisterState createState() => _UserRegisterState();
}

class _UserRegisterState extends State<UserRegister> {
  TextEditingController emailAddressController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController repeatPasswordController = TextEditingController();

  bool errorPhone = false;
  bool errorEmail = false;
  bool errorPassword = false;
  bool errorRepeatPassword = false;
  bool loading = false;
  String errorMessagePassword = "Required";
  String errorEmailMessage = "Required";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: appsMainColor),
        title: Text(
          'Create Account',
          style: TextStyle(color: Colors.black87),
        ),
      ),
      body: loading
          ? loaderMaterial
          :  SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(left: 15, right: 15),
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Container(
                width: 120,
                height: 70,
                child: Image.asset(
                  "assets/images/ustad_logo.png",
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 5),
                child: Text(
                  "Register",
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  top: 10,
                ),
                child: InputField1(
                  hintText: "example@gmail.com",
                  lableText: "Username",
                  controller: emailAddressController,
                  obSecure: false,
                  errorText: errorEmail ? errorEmailMessage : null,
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  top: 10,
                ),
                child: TextField(
                  keyboardType: TextInputType.text,
                  autofocus: false,
                  autocorrect: false,
                  textInputAction: TextInputAction.done,
                  maxLength: 9,
                  maxLengthEnforced: true,
                  decoration: InputDecoration(
                    hintText: "Phone",
                    labelText: "Phone",
                    prefix: Text("07  "),
                    errorText: errorPhone ? 'Required' : null,
                    labelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: appsMainColor, width: 2)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                      color: appsMainColor,
                    )),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: appsMainColor,
                        )),
                    contentPadding:
                        EdgeInsets.only(left: 15, bottom: 0, top: 0, right: 15),
                  ),
                  controller: phoneController,
                ),
              ),
              Container(
                  margin: EdgeInsets.only(
                    top: 10,
                  ),
                  child: InputField1(
                    hintText: "Create Password",
                    controller: passwordController,
                    obSecure: true,
                    errorText: errorPassword ? errorMessagePassword : null,
                  )),
              Container(
                  margin: EdgeInsets.only(
                    top: 10,
                  ),
                  child: InputField1(
                    hintText: "Confirm Password",
                    controller: repeatPasswordController,
                    obSecure: true,
                    errorText:
                        errorRepeatPassword ? errorMessagePassword : null,
                  )),

              SizedBox(
                height: 20,
              ),
              Container(
                margin: EdgeInsets.only(left: 5, right: 5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: appsMainColor),
                child: Row(
                  children: [
                    Expanded(
                      child: FlatButton(
                          padding: EdgeInsets.only(right: 20, left: 20),
                          onPressed: () {
                            registerNow();
                          },
                          child: Row(
                            children: [
                              Expanded(
                                  child: Text(
                                "Continue",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    letterSpacing: .5),
                              )),
                              Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                              )
                            ],
                          )),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool validateData() {
    bool validate = true;
    if (phoneController.text.isEmpty) {
      errorPhone = true;
      validate = false;
    } else {
      errorPhone = false;
    }

    if (emailAddressController.text.isEmpty) {
      errorEmail = true;
      errorEmailMessage = "Valid Email Required";
      validate = false;
    } else {
      String email = emailAddressController.text.trim();
      if (validateEmail(email)) {
        errorEmail = false;
      } else {
        errorEmailMessage = "Valid Email Required !";
        errorEmail = true;
        validate = false;
      }
    }

    if (passwordController.text.length < 6) {
      errorPassword = true;
      errorMessagePassword = "Passwords must be at least 6 Characters.";
      validate = false;
    } else {
      errorPassword = false;
    }

    if (passwordController.text != repeatPasswordController.text) {
      errorRepeatPassword = true;
      errorMessagePassword = "Password Didn't Match";
      validate = false;
    } else {
      errorRepeatPassword = false;
    }
    setState(() {});
    return validate;
  }

  void registerNow() async {
    if (!validateData()) {
      return;
    }
    var formData = jsonEncode({
      'username': emailAddressController.text.replaceAll(" ", ""),
      'password': passwordController.text.replaceAll(" ", ""),
      'language': "en_GB",
      'email': emailAddressController.text.replaceAll(" ", ""),
      "profile": {
        "phone": "07" + phoneController.text.toString(),
        "email": emailAddressController.text.replaceAll(" ", "")
      }
    });
    setState(() {
      loading = true;
    });

    await ApiRequest(context)
        .postRegisterData(formData)
        .then((value) {
      setState(() {
        loading = false;
      });
      print(value.responseCode);
      if (value.responseCode == 409) {
        errorEmail = true;
        errorEmailMessage = "Email Already Exist !";
        setState(() {});
        return;
      } else if (value.responseCode == 201) {
        Get.to(()=> VerifyEmail(
                      emailAddress: emailAddressController.text,));
      } else {
        Toast.show('Something Error . Please Try Again Later ', context);
      }
    });
  }

  bool validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    return (!regex.hasMatch(value)) ? false : true;
  }
}
