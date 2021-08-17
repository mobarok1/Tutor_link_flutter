import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:tutorlink/Pages/profile_pages/consumer_deatils.dart';
import 'package:tutorlink/api/api_request.dart';
import 'package:tutorlink/extra/theme_data.dart';
import 'package:tutorlink/storage/SharedPrefManager.dart';
import 'package:tutorlink/widgets/loader.dart';

class VerifyEmail extends StatefulWidget {
  final String emailAddress;
  final int returnCount;
  VerifyEmail(
      {@required this.emailAddress,this.returnCount});
  @override
  _VerifyEmailState createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  TextEditingController codeController = TextEditingController();
  String code = "";
  String errorMessage = "";
  bool errorOnCode = false, loading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setDataToLocal();
  }
  setDataToLocal() async{
    SharedPrefManager.saveResendCodeInfo(widget.emailAddress.trim());
  }
  @override
  Widget build(BuildContext context) {
    String emailAddress = widget.emailAddress;
    return WillPopScope(
        child:Scaffold(
          appBar: AppBar(
            elevation: 7,
            iconTheme: IconThemeData(color: appsMainColor),
            title: Text(
              'Verify Email Address',
              style: TextStyle(color: Colors.black87),
            ),
          ),
          body: loading
              ? loaderMaterial
              : SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 20, bottom: 5),
                  padding: EdgeInsets.only(
                      left: 20, right: 20, top: 15, bottom: 15),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(
                            color: Colors.black.withOpacity(.5), width: .5),
                        bottom: BorderSide(
                            color: Colors.black.withOpacity(.5), width: .5),
                      )),
                  child: Text(
                    "We've sent your 8-digit code to $emailAddress",
                    style: TextStyle(fontSize: 17),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10, bottom: 5),
                  padding: EdgeInsets.only(
                      left: 20, right: 20, top: 5, bottom: 10),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                            color: Colors.black.withOpacity(.5), width: .5),
                        bottom: BorderSide(
                            color: Colors.black.withOpacity(.5), width: .5),
                      )),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (userCode) {
                      code = userCode;
                      setState(() {});
                    },
                    controller: codeController,
                    decoration: InputDecoration(
                        labelText: "Your Code",
                        labelStyle: TextStyle(color: appsMainColor),
                        focusedBorder: UnderlineInputBorder(
                            borderSide:
                            BorderSide(color: appsMainColor, width: 3))),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20, bottom: 5),
                  padding:
                  EdgeInsets.only(left: 10, right: 20, top: 2, bottom: 2),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                            color: Colors.black.withOpacity(.5), width: .3),
                        bottom: BorderSide(
                            color: Colors.black.withOpacity(.5), width: .3),
                      )),
                  child: FlatButton(
                    onPressed: () {
                      resendCode();
                    },
                    child: Text(
                      "Resend code",
                      style: TextStyle(
                          fontSize: 16,
                          color: appsMainColor,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                Container(
                  decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(5)),
                  margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: FlatButton(
                          onPressed: code.isEmpty || code.length < 8
                              ? null
                              : () {
                            verifyCode();
                          },
                          color: appsMainColor,
                          disabledColor: Colors.black.withOpacity(.1),
                          disabledTextColor: Colors.black.withOpacity(.3),
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child: Text(
                            'Verify',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(5)),
                  margin: EdgeInsets.only(left: 20, right: 20, top: 15),
                  child: FlatButton(
                    onPressed:() {
                        Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    color: Colors.red[700],
                    disabledColor: Colors.black.withOpacity(.1),
                    disabledTextColor: Colors.black.withOpacity(.3),
                    padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                    child: Text(
                      'Back to Home',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        onWillPop: willPop);
  }
  Future<bool> willPop(){
    Toast.show("Please verify your account", context);
    return Future.value(false);
  }
  verifyCode() async {
    ProgressLoader.show();
    var formData = jsonEncode(
        {"username": widget.emailAddress, "code": codeController.text});
    await ApiRequest(context)
        .verifyCode(formData)
        .then((value) {
          ProgressLoader.close();
      if (value.responseCode == 200) {
        Toast.show("Verification Successfully Complete.", context, backgroundColor: Colors.green, textColor: Colors.white);
        SharedPrefManager.clearResendCodeInfo();
        int count = 0;
        Navigator.popUntil(context, (Route<dynamic> route) {
          return count++==widget.returnCount??2;
        });
      } else {
        errorOnCode = true;
        errorMessage = "Verification Failed ! Try again later";

        Toast.show("Verification Failed !", context,
            backgroundColor: Colors.red, textColor: Colors.white);
      }
    });
    setState(() {

    });
  }

  resendCode() async {
    ProgressLoader.show();
    var formData = jsonEncode({
      "username": widget.emailAddress,
      "key":"email",
      "value":widget.emailAddress
    });
    print(formData);
    await ApiRequest(context)
        .resendVerifyCode(formData)
        .then((value) {
      ProgressLoader.close();
      if (value.responseCode == 201) {
        Toast.show("Verification Code Sent", context,
            backgroundColor: Colors.green, textColor: Colors.white);
      } else {
        errorOnCode = true;
        errorMessage = "Resend Failed ! Try again later";
        Toast.show("Failed to Resend Verification Code!", context,
            backgroundColor: Colors.red, textColor: Colors.white);
      }
    });
    setState(() {

    });
  }
}
