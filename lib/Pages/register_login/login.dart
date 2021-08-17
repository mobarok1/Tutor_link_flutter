import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:toast/toast.dart';
import 'package:tutorlink/Pages/profile_pages/consumer_deatils.dart';
import 'package:tutorlink/Pages/profile_pages/consumer_profile_page.dart';
import 'package:tutorlink/Pages/register_login/user_login.dart';
import 'package:tutorlink/api/api_request.dart';
import 'package:tutorlink/api/api_response.dart';
import 'package:tutorlink/controller/user_controller.dart';
import 'package:tutorlink/extra/term_policy.dart';
import 'package:tutorlink/extra/theme_data.dart';
import 'package:tutorlink/main.dart';
import 'package:tutorlink/modelClass/my_details_model.dart';
import 'package:tutorlink/modelClass/social_login.dart';
import 'package:tutorlink/storage/SharedPrefManager.dart';
import 'package:url_launcher/url_launcher.dart';


class LoginPage extends StatefulWidget {
  int returnCount;
  LoginPage({this.returnCount});
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool loading = false;
  SocialLoginModel socialLogin = SocialLoginModel();
  bool alreadyExist = false;
  String errorEmailMessage ="";
  AccessToken _accessToken;
  Map<String, dynamic> _fbUser;
  UserController userController = Get.find();


  @override
  void initState() {
    // TODO: implement initState super.initState();
    super.initState();
    checkLoggedIn();
  }
  showTermAndCondition(){
    AlertDialog alert = AlertDialog(
      title: Text("Term And Condition"),
      content: Text(StringData.termsAndCondition),
      scrollable: true,
      actions: [
        FlatButton(
          textColor: appsMainColor,
            onPressed: (){
              Navigator.pop(context);
            },
            child: Text("Close"))
      ],
    );
    showDialog(
        context: context,
        builder:(ctx)=> alert
    );
  }
  checkLoggedIn() async {
    bool logged = await userController.loginCheck();
    if (logged) {
      int count = 0;
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) => ProfilePage()
          ), (Route<dynamic> route) => count++==widget.returnCount);
    }
  }

  Future signInWithGoogle() async {
    // Trigger the authentication flow
    signIn.disconnect();
    GoogleSignInAccount googleUser = signIn.currentUser;
    if (googleUser == null) {
      // Attempt to sign in without user interaction
      googleUser = await signIn.signInSilently();
    }
    if (googleUser == null) {
      // Force the user to interactively sign in
      googleUser = await signIn.signIn();
    }
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    socialLogin = SocialLoginModel(
      loginNetwork: 1,
      userId: googleUser.id,
      emailAddress: googleUser.email,
      accessToken: googleAuth.accessToken,
      userName: googleUser.displayName,
    );
    var myBody = jsonEncode({'username': socialLogin.emailAddress, 'google_token': socialLogin.accessToken});
    print(myBody);
    getLoginSession(myBody);

  }

  void getLoginSession(myBody) async {
    setState(() {
      loading = true;
    });

    var value = await ApiRequest(context).postLoginData(myBody);
      if (value.responseCode == 200) {
        SharedPrefManager.setToken(value.response.session_id);
        SharedPrefManager.setUserId(value.response.uuid);
        SharedPrefManager.setEmail(socialLogin.emailAddress);
        SharedPrefManager.setType(socialLogin.loginNetwork);

        userController.userSession = value.response.session_id;
        userController.userId = value.response.uuid;
        userController.userDetails =UserDetailsModel(email: socialLogin.emailAddress);
        userController.loginType = socialLogin.loginNetwork;

        print(await SharedPrefManager.getUserId());
        ApiResponse response = await ApiRequest(context).getProfileData();
        if(response.responseCode == -1){
          signIn.signOut();
          return;
        }
        var data = json.decode(response.response);
        UserDetailsModel _myDetailsModel = UserDetailsModel.fromJSON(data);
        userController.updateUserInfo(_myDetailsModel);
        if(_myDetailsModel.profile.firstName == null ||
            _myDetailsModel.profile.lastName == null ||
            _myDetailsModel.profile.phoneNumber == null){
          int count = 0;
          Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (ctx)=>ConsumerDetails()),(Route<dynamic> route) {
            return count++==widget.returnCount;
          });

        }else{
          int count = 0;
          print(await SharedPrefManager.getUserId());
          Navigator.popUntil(context, (Route<dynamic> route) {

            return count++==widget.returnCount;
          });
        }
      } else if (value.responseCode == 417) {
        Toast.show('This Account Not Verified', context, duration: 2, backgroundColor: Colors.yellow, textColor: Colors.black);
      } else if (value.responseCode == 428) {
        Toast.show('Account Request Pending', context, duration: 2, backgroundColor: Colors.red, textColor: Colors.white);
      }else if (value.responseCode == 404){
        socialLogin.loginNetwork==1?
        registerWithSocialNetwork("google_token"):registerWithSocialNetwork("facebook_token");
      } else {
        Toast.show(
          'Failed to Login',
          context,
          duration: 2,
          backgroundColor: Colors.redAccent,
        );
      }
    setState(() {
      loading = false;
    });
  }
  registerWithSocialNetwork(String networkKey) async{
    var formData = jsonEncode({
      'username': socialLogin.emailAddress,
       networkKey: socialLogin.accessToken,
      'language': "en_GB",
      'email': socialLogin.emailAddress,
      socialLogin.loginNetwork == 1?'google_id':'facebook_id':socialLogin.userId,
      "profile": {
        "first_name": socialLogin.userName,
      }
    });
    print(formData);
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
        alreadyExist = true;
        errorEmailMessage = "Email Already Exist !";
        setState(() {});
        return;
      } else if (value.responseCode == 201) {
        signInWithGoogle();
      } else {
        Toast.show('Something Error . Please Try Again Later ', context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 5,
        iconTheme: IconThemeData(color: appsMainColor),
        actionsIconTheme: IconThemeData(),
        title: Text("Sign up or log in"),
      ),
      body: loading?Center(
        child: loaderMaterial,
      ): Container(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 20),
            margin: EdgeInsets.only(top: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Container(
                //   alignment: Alignment.center,
                //   height: 55,
                //   decoration: BoxDecoration(
                //     color: Color(0xFF3b5998),
                //     borderRadius: BorderRadius.circular(4),
                //   ),
                //   child: FlatButton(
                //     onPressed: (){
                //       signInWithFacebook();
                //     },
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       children: [
                //         Icon(
                //           FontAwesomeIcons.facebookF,
                //           color: Colors.white,
                //         ),
                //         SizedBox(
                //           width: 10,
                //         ),
                //         Text(
                //           'Continue with Facebook',
                //           style: TextStyle(
                //               color: Colors.white,
                //               fontSize: 17,
                //               fontWeight: FontWeight.bold,
                //               letterSpacing: .5),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  alignment: Alignment.center,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: FlatButton(
                    onPressed: (){
                      signInWithGoogle();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/google.png",
                          height: 30,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text('Continue with Google',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                letterSpacing: .5)),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(children: <Widget>[
                  Expanded(
                    child: new Container(
                        child: Divider(
                      height: 36,
                      color: Colors.black.withOpacity(.5),
                    )),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text("or"),
                  ),
                  Expanded(
                    child: new Container(
                        child: Divider(
                      height: 36,
                      color: Colors.black.withOpacity(.5),
                    )),
                  ),
                ]),
                SizedBox(
                  height: 5,
                ),
                Row(children: [
                  Expanded(
                    child: FlatButton.icon(
                        color: appsMainColor,
                        padding: EdgeInsets.only(top: 15, bottom: 15),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UserLogin(returnCount: (widget.returnCount+1))));
                        },
                        icon: Icon(
                          Icons.mail_outline,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Continue with email',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        )),
                  ),
                ]),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text( 'By continuing you agree to our ',
                        style: TextStyle(color: Colors.black.withOpacity(.6))),
                    Container(
                      width: 40,
                      height: 25,
                      child: FlatButton(
                          onPressed: () {
                            showTermAndCondition();
                          },
                          padding: EdgeInsets.only(left: 0,right: 0,top: 0,bottom: 0),
                          child: Text('T&Cs ', style: TextStyle(color: appsMainColor))),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text( 'Please also check out our ',
                        style: TextStyle(color: Colors.black.withOpacity(.6))),
                    Container(
                      width: 100,
                      height: 25,
                      child: FlatButton(
                          onPressed: () {

                          },
                          padding: EdgeInsets.only(left: 0,right: 0,top: 0,bottom: 0),
                          child: Text('Privacy Policy ', style: TextStyle(color: appsMainColor))),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
