import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toast/toast.dart';
import 'package:tutorlink/Pages/cart_page.dart';
import 'package:tutorlink/Pages/category_page.dart';
import 'package:tutorlink/Pages/favorite_page.dart';
import 'package:tutorlink/Pages/profile_pages/consumer_child_accounts.dart';
import 'package:tutorlink/Pages/profile_pages/consumer_deatils.dart';
import 'package:tutorlink/Pages/profile_pages/consumer_order_page_list.dart';
import 'package:tutorlink/Pages/profile_pages/saved_address.dart';
import 'package:tutorlink/controller/cart_controller.dart';
import 'package:tutorlink/controller/favorite_controller.dart';
import 'package:tutorlink/controller/user_controller.dart';
import 'package:tutorlink/extra/theme_data.dart';
import 'package:tutorlink/main.dart';
import 'package:tutorlink/modelView/email_input.dart';
import 'package:tutorlink/storage/SharedPrefManager.dart';
import 'package:tutorlink/widgets/bottom_bar.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  CartController cartController = Get.find();
  FavoriteController favoriteController = Get.find();
  UserController userController = Get.find();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }


  logOutNow() async {
    signIn.signOut();
    bool logout = await SharedPrefManager.logOut();
    favoriteController.logOut();
    cartController.count.value = 0;
    if (logout) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBarModelView(
        activeIndex: 4,
      ),      appBar: AppBar(
        iconTheme: IconThemeData(color: appsMainColor),
        title: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                userController.userDetails==null?"Email Not Found":userController.userDetails.email,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          FlatButton.icon(
            onPressed: () {
              logOutNow();
            },
            icon: Icon(
              Icons.power_settings_new,
              color: Colors.red,
            ),
            label: Text("Logout"),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.centerRight,
              margin: EdgeInsets.only(top: 15),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                      top: BorderSide(color: appsMainColor.withOpacity(.3)),
                      bottom: BorderSide(color: appsMainColor.withOpacity(.1)))),
              child: FlatButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              ConsumerOrderPage()));
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    children: [
                      Icon(
                        Icons.description,
                        color: appsMainColor,
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Text(
                        'Enrollment History',
                        style: TextStyle(
                           color: appsMainColor
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20),
              padding: EdgeInsets.symmetric(horizontal: 0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: appsMainColor.withOpacity(.1)),

                  )),
              child: Column(
                children: [
                  FlatButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  ConsumerDetails()));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Icon(Icons.person, color: appsMainColor),
                          SizedBox(
                            width: 15,
                          ),
                          Text(
                            'Account',
                            style: TextStyle(
                                color: appsMainColor
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>ChildAccounts()));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Image.asset(
                            "assets/images/child.png",
                            color: appsMainColor,
                            height: 25,
                            width: 25,
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Text(
                            "My Children",
                            style: TextStyle(
                                color: appsMainColor
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SaveAddress()));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: appsMainColor,
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Text(
                            'Address Information',
                            style: TextStyle(
                                color: appsMainColor
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  userController.loginType!=0?
                      Container():
                  FlatButton(
                    onPressed: () {
                      getEmailInput();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lock,
                            color: appsMainColor,
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Text(
                            'Change password',
                            style: TextStyle(
                                color: appsMainColor
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  getEmailInput(){
    AlertDialog alert = AlertDialog(
      title: Text("Change Password"),
      content: Container(
          child: EmailInputDialogModel()
      ),
    );
    showDialog(context: context, builder:(ctx)=> alert);
  }
}
