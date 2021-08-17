import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:group_button/group_button.dart';
import 'package:toast/toast.dart';
import 'package:tutorlink/Pages/profile_pages/consumer_deatils.dart';
import 'package:tutorlink/Pages/profile_pages/consumer_profile_page.dart';
import 'package:tutorlink/Pages/register_login/user_register.dart';
import 'package:tutorlink/Pages/register_login/verify_email.dart';
import 'package:tutorlink/api/api_request.dart';
import 'package:tutorlink/api/api_response.dart';
import 'package:tutorlink/extra/theme_data.dart';
import 'package:tutorlink/modelClass/my_details_model.dart';
import 'package:tutorlink/modelView/email_input.dart';
import 'package:tutorlink/modelView/password_reset.dart';
import 'package:tutorlink/storage/SharedPrefManager.dart';
import 'package:tutorlink/widgets/input_fields.dart';

class UserLogin extends StatefulWidget {
  int returnCount;
  UserLogin({@required this.returnCount});
  @override
  _UserLoginState createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailAddressController = TextEditingController();
  bool errorEmail = false;
  bool errorPassword = false;
  int loginStatus = 0;

  String userName;
  String password;
  bool isLoading = false;
  bool isSplashLoading = true;

  bool loading = false;

  Color lineColor = Colors.yellow;

  checkLoggedIn() async {
    String userId = await SharedPrefManager.getUserId();
    String email = await SharedPrefManager.getEmail();
    if (userId != null) {
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
              (Route<dynamic> route) => route.isFirst);
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: appsMainColor),
        title: Text(
          'Login',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
      ),
      body: loading
          ? loaderMaterial
          : Container(
              padding: EdgeInsets.only(left: 15, right: 15),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: 140,
                      height: 80,
                      child: Image.asset(
                        "assets/images/ustad_logo.png",
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 5, bottom: 10),
                      child: Text(
                        "Login",
                        style: TextStyle(
                            fontSize: 21, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: InputField1(
                        hintText: "Email Address",
                        controller: emailAddressController,
                        obSecure: false,
                      ),
                    ),
                    Container(
                      child: InputField1(
                        hintText: "Password",
                        controller: passwordController,
                        obSecure: true,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: appsMainColor,
                          borderRadius: BorderRadius.circular(5)),
                      child: FlatButton(
                        onPressed: getLoginSession,
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: Text(
                                  'Login',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            Container(
                              width: 20,
                              margin: EdgeInsets.only(right: 10),
                              child: Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 24,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'New User?',
                          style: TextStyle(color: Colors.black87, fontSize: 12),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => UserRegister()));
                            },
                            child: Text(
                              'Create account',
                              style:
                                  TextStyle(color: appsMainColor, fontSize: 12),
                            )),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Forgot password?',
                          style: TextStyle(color: Colors.black87, fontSize: 12),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        InkWell(
                            onTap: () {
                              getEmailInput();
                            },
                            child: Text(
                              'Reset password',
                              style:
                              TextStyle(color: appsMainColor, fontSize: 12),
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  bool validateData() {
    bool validate = true;
    if (emailAddressController.text.isEmpty) {
      errorEmail = true;
      validate = false;
    } else {
      errorEmail = false;
    }

    if (passwordController.text.length < 6) {
      errorPassword = true;
      validate = false;
    } else {
      errorPassword = false;
    }
    setState(() {});
    return validate;
  }

  void getLoginSession() async {
    setState(() {
      loading = true;
    });
    userName = emailAddressController.text.trim();
    password = passwordController.text.trim();
    var myBody = jsonEncode({'username': userName, 'password': password});

    var value = await ApiRequest(context).postLoginData(myBody);
    if (value.responseCode == 200) {
      ApiResponse response = await ApiRequest(context).getProfileData();
      if(response.responseCode == -1){
        return;
      }
      print(value.response.session_id);
      SharedPrefManager.setToken(value.response.session_id);
      SharedPrefManager.setUserId(value.response.uuid);
      SharedPrefManager.setEmail(emailAddressController.text);
      SharedPrefManager.setType(0);

      var data = json.decode(response.response);
      UserDetailsModel _myDetailsModel = UserDetailsModel.fromJSON(data);
      if(_myDetailsModel.profile.firstName == null ||
          _myDetailsModel.profile.lastName == null ||
          _myDetailsModel.profile.phoneNumber == null){
        int count = 0;
        Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (ctx)=>ConsumerDetails()),(Route<dynamic> route) {
          return count++==widget.returnCount;
        });

      }else{
        int count = 0;
        Navigator.popUntil(context, (Route<dynamic> route) {
          return count++==widget.returnCount;
        });
      }
    } else if (value.responseCode == 417) {
      Toast.show('This Account Not Verified', context, duration: 2, backgroundColor: Colors.yellow, textColor: Colors.black);
      Get.to(()=>VerifyEmail(emailAddress: emailAddressController.text.replaceAll(" ", ""),));
    } else if (value.responseCode == 428) {
      Toast.show('Account Request Pending', context, duration: 2, backgroundColor: Colors.red, textColor: Colors.white);
      getResetPasswordInput();
    } else {
      Toast.show(
        'Either login or password is wrong',
        context,
        duration: 2,
        backgroundColor: Colors.redAccent,
      );
    }

    setState(() {
      loading = false;
    });
  }
  getResetPasswordInput(){
    AlertDialog alertDialog = AlertDialog(
      title: Text("Change Password"),
      content: Container(
        child: ChangePassword(
          userName: emailAddressController.text.trim(),
        )
      ),
    );
    showDialog(
        context: context,
        barrierDismissible: false,
        builder:(ctx)=> alertDialog
    );
  }
  getEmailInput(){
    AlertDialog alert = AlertDialog(
      title: Text("Change Password"),
      content: Container(
          child: EmailInputDialogModel()
      ),
    );
    showDialog(context: context,builder:(ctx)=> alert);
  }
}
