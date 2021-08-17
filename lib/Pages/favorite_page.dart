import 'dart:convert';
import 'dart:math';

import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:toast/toast.dart';
import 'package:tutorlink/Pages/cart_page.dart';
import 'package:tutorlink/Pages/category_page.dart';
import 'package:tutorlink/Pages/course_details.dart';
import 'package:tutorlink/Pages/payment/card_payment.dart';
import 'package:tutorlink/Pages/profile_pages/add_Edit_child.dart';
import 'package:tutorlink/Pages/profile_pages/consumer_child_accounts.dart';
import 'package:tutorlink/Pages/profile_pages/consumer_order_page_list.dart';
import 'package:tutorlink/Pages/profile_pages/saved_address.dart';
import 'package:tutorlink/Pages/register_login/login.dart';
import 'package:tutorlink/Pages/session_selection.dart';
import 'package:tutorlink/api/api_request.dart';
import 'package:tutorlink/api/api_response.dart';
import 'package:tutorlink/controller/cart_controller.dart';
import 'package:tutorlink/controller/favorite_controller.dart';
import 'package:tutorlink/extra/dateService.dart';
import 'package:tutorlink/extra/payment-service.dart';
import 'package:tutorlink/extra/theme_data.dart';
import 'package:tutorlink/modelClass/address.dart';
import 'package:tutorlink/modelClass/cart_item.dart';
import 'package:tutorlink/modelClass/child_account.dart';
import 'package:tutorlink/modelClass/consumer_subscription_model.dart';
import 'package:tutorlink/modelClass/course_model.dart';
import 'package:tutorlink/modelClass/session_model.dart';
import 'package:tutorlink/storage/SharedPrefManager.dart';
import 'package:tutorlink/widgets/bottom_bar.dart';

class FavoritePage extends StatefulWidget {
  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  bool loading = false, subscribed = true, inCart = false, isLogged = false;
  List<CourseModel> favoriteItems = [];
  List<ChildAccountModel> userChildren =[];
  List<SessionModel> sessions = [];
  String selectedSession;
  CourseModel selectedCourse;

  double price = 0;
  int paymentMethod = 0;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  CartController cartController  = Get.find();
  FavoriteController favoriteController = Get.find();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLogin();
  }

  checkLogin() async {
    String id = await SharedPrefManager.getUserId();
    if (id == null) {
      //user is not logged redirect to homepage
      Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (ctx) => LoginPage(returnCount: 1,)),(route) => route.isFirst);
    } else {
    //  getFavoriteCourses();
      favoriteController.getFavoriteCourses();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          iconTheme: IconThemeData(color: appsMainColor),
          title: Text(
            "Favorites",
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          )
        ),
        bottomNavigationBar: BottomNavigationBarModelView(
          activeIndex: 2,
        ),
        body: Container(
          padding: EdgeInsets.only(
              left: 10, right: 10, top: 10, bottom: 0),
          child: GetBuilder<FavoriteController>(
            init: favoriteController,
           builder: (GetxController controller) {
            return favoriteController.items.length ==0?
            Center(
              child: Text("No course found"),
            ) :  ListView(
              children: favoriteController.items.toList().map((e) {
                String courseImage;
                try{
                  courseImage = e.courseFiles.singleWhere((element) => element.keyName == "course_image").fileUid;
                }catch(e){

                }
                return Container(
                  margin: EdgeInsets.only(bottom: 0, top: 0),
                  padding: EdgeInsets.only(top: 5, bottom: 0),
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color:
                              Colors.black.withOpacity(.3)))),
                  child: Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.center,
                    children: [
                      Container(
                          height: 40,
                          width: 50,
                          margin: EdgeInsets.only(
                              bottom: 5, left: 5, right: 10),
                          child: courseImage==null
                              ? Image.asset(
                            "assets/images/ustad_logo.png",
                            fit: BoxFit.cover,
                          )
                              : Image.network(
                            ApiRequest(context)
                                .getBaseUrl() +
                                '/delivery/course/${e.courseId}/file/$courseImage',
                            fit: BoxFit.fill,
                          )),
                      Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(
                                    top: 0, bottom: 2),
                                child: Text(
                                  e.courseTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: appsMainColor,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                    top: 0, bottom: 2),
                                child: Text(
                                  "Course begins : "+ DateFormatHelper.fromDate(e.startDate),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                    top: 0, bottom: 2),
                                child: Text(
                                  "Course finishes : " + DateFormatHelper.fromDate( e.endDate),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          )),
                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 100,
                            alignment: Alignment.centerRight,
                            child: Text(
                              "£ ${e.price.price.toStringAsFixed(2)}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: appsMainColor),
                            ),
                          ),
                          Container(
                            height: 30,
                            width: 75,
                            margin: EdgeInsets.only(top: 5,bottom: 5),
                            child: FlatButton(
                                padding: EdgeInsets.only(left: 0,right: 0),
                                onPressed: (){
                                  Get.to(CourseDetails(courseId: e.courseId,));
                                },
                                color: subColor,
                                textColor: Colors.white,
                                child: Text("Buy Now")),
                          )
                        ],
                      ),
                      Container(
                        height: 25,
                        width: 35,
                        child: IconButton(
                            icon: Icon(
                              Icons.delete_forever,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              favoriteController.removeFromFavorite(e.courseId);
                            }),
                      )
                    ],
                  ),
                );
              }).toList(),
            );
          },),
        ));
  }
}
