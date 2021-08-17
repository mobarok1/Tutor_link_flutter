import 'dart:convert';

import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:toast/toast.dart';
import 'package:tutorlink/Pages/cart_page.dart';
import 'package:tutorlink/Pages/category_page.dart';
import 'package:tutorlink/Pages/favorite_page.dart';
import 'package:tutorlink/Pages/profile_pages/add_Edit_child.dart';
import 'package:tutorlink/Pages/profile_pages/saved_address.dart';
import 'package:tutorlink/Pages/register_login/login.dart';
import 'package:tutorlink/Pages/session_selection.dart';
import 'package:tutorlink/Pages/tutor_details.dart';
import 'package:tutorlink/api/api_request.dart';
import 'package:tutorlink/api/api_response.dart';
import 'package:tutorlink/controller/cart_controller.dart';
import 'package:tutorlink/controller/favorite_controller.dart';
import 'package:tutorlink/controller/user_controller.dart';
import 'package:tutorlink/extra/dateService.dart';
import 'package:tutorlink/extra/theme_data.dart';
import 'package:tutorlink/modelClass/address.dart';
import 'package:tutorlink/modelClass/cart_item.dart';
import 'package:tutorlink/modelClass/child_account.dart';
import 'package:tutorlink/modelClass/consumer_review_model.dart';
import 'package:tutorlink/modelClass/consumer_subscription_model.dart';
import 'package:tutorlink/modelClass/course_model.dart';
import 'package:tutorlink/modelClass/my_details_model.dart';
import 'package:tutorlink/modelClass/price_history.dart';
import 'package:tutorlink/modelClass/session_model.dart';
import 'package:tutorlink/storage/SharedPrefManager.dart';
import 'package:tutorlink/widgets/bottom_bar.dart';
import 'package:tutorlink/widgets/course_card.dart';
/*


medema8899@donmah.com
 */
// ignore: must_be_immutable
class CourseDetails extends StatefulWidget {
  String courseId;
  CourseDetails({this.courseId});

  @override
  _CourseDetailsState createState() => _CourseDetailsState();
}

class _CourseDetailsState extends State<CourseDetails> {
  bool showAboutDetails = false;
  CourseModel courseModel;
  bool loading = false, inCart = false, isLogged = false;
  double width = 0,height = 0;
  double rating = 1;
  bool loadError = false;
  List<CourseModel> relatedCourse = [];
  List<ConsumerReviewModel> userReviews = [];
  List<ChildAccountModel> userChildren = [];
  List<SessionModel> sessions = [];
  String selectedChildUuid;
  SessionModel selectedSession;
  String posterImage;
  String courseImage;
  TextEditingController commentController = TextEditingController();
  CartController cartController = Get.find();
  FavoriteController favoriteController = Get.find();
  UserController userController = Get.find();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // first we have get have to get course details by using courseID
    getCourseData();
  }

  addToWishList() async {
    // getting userId from localStorage
    if(await userController.loginCheck() == false){
      Get.to(()=>LoginPage(returnCount: 1,));
      return;
    }
    favoriteController.addToFavorite(courseModel);
  }
  showNoChildMessage(){
    AlertDialog alert = AlertDialog(
      title: Text("Choose your child"),
      content: Container(
          child: FlatButton(
              color: Colors.red,
              textColor: Colors.white,
              padding: EdgeInsets.only(top: 10,bottom: 10,left: 20,right: 20),
              onPressed: (){
                Navigator.pop(context);
                openChildAddPage();
              },
              child: Text("No Child found.To add a child click here",textAlign: TextAlign.center,)
          ),
      ),
      actions: [
        FlatButton(
          onPressed: () {
            Get.back();
          },
          child: Text("Close"),
        )
      ],
    );
    showDialog(context: context, builder: (ctx)=> alert);
  }
  openChildAddPage() async{
    // redirect to addChildPage if child is empty
    var result  =  await Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => AddEditChild()));
    setState(() {
      loading = true;
    });
    //after back to this page reload all Child
    userChildren = await ApiRequest(context).getAllChild();
    setState(() {
      loading = false;
    });

  }
  showAddressMessage(){
    AlertDialog alert = AlertDialog(
      title: Text("Home/Invoice Address Not Found!"),
      content: Container(
        child: FlatButton(
            color: Colors.red,
            textColor: Colors.white,
            padding: EdgeInsets.only(top: 10,bottom: 10,left: 20,right: 20),
            onPressed: (){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => SaveAddress()));
            },
            child: Text("Click Here to Add Address",textAlign: TextAlign.center,)
        ),
      ),
      actions: [
        FlatButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Close"),

        )
      ],
    );
    showDialog(context: context, builder: (ctx)=> alert);
  }
  //this function used to ensure all condition is fullFill before enroll to a course
  preEnrollToCourse() async {
    setState(() {
      loading = true;
    });
    if(await userController.loginCheck()){
      isLogged = true;
      ApiResponse response = await ApiRequest(context).getProfileData();
      print(response.response);
      if(response.responseCode == -1){
        setState(() {
          loading = false;
        });
        return;
      }
      var data = json.decode(response.response);
      UserDetailsModel _myDetailsModel = UserDetailsModel.fromJSON(data);
      // getting all Address to ensure User gave input his address
      if(_myDetailsModel.addresses.length==0){
        // No Address found , So Display Address Error Message
        showAddressMessage();
        setState(() {
          loading = false;
        });
        return;
      }else if(_myDetailsModel.addresses.length != 2){
        // address exist but we need invoice and Home Address both
        showAddressMessage();
        setState(() {
          loading = false;
        });
        return;
      }
      if(courseModel.properties.capacity != null){
        if(selectedSession == null){
          sessions = await ApiRequest(context).getCourseSession(courseModel.courseId);
          Get.to(()=>SessionSelect(
            sessions: sessions,
            onSessionSelect: onSessionSelect,
          ));
          setState(() {
            loading = false;
          });
          return;
        }
      }
      String gender = courseModel.properties.gender;
      print(gender);
      if(gender=="Female" && _myDetailsModel.profile.gender == Gender.male){
        Get.showSnackbar(GetBar(message: "This course only for Female!",backgroundColor: Colors.red,duration: Duration(seconds: 2),));
        setState(() {
          loading = false;
        });
        return;
      }else if(gender=="Male" && _myDetailsModel.profile.gender == Gender.female){
        Get.showSnackbar(GetBar(message: "This course only for Male!",backgroundColor: Colors.red,duration: Duration(seconds: 2),));
        setState(() {
          loading = false;
        });
        return;
      }
      // getting Children
      userChildren = await ApiRequest(context).getAllChild();
      if (courseModel.properties.under16 == "under_16") {
          if (userChildren.length == 0) {
            //no child found
            showNoChildMessage();
          }else{
            showChildSelect();
          }
        } else {
          //everything ok enroll now
          enrollNow();
      }
    } else {
      // user is not logged, redirect to login page
      Get.to(()=>LoginPage(returnCount: 1,));
    }

    setState(() {
      loading = false;
    });
  }

  getCourseData() async {
    setState(() {
      loading = true;
    });
    // get course Data
    courseModel = await ApiRequest(context).getCourseData(widget.courseId);
    if(courseModel == null){
      loadError = true;
    }else{
      loadError = false;
      //used try to bypass no content error
      try{
        courseImage = courseImage = courseModel.courseFiles.singleWhere((element) => element.keyName == "course_image").fileUid;
        posterImage = courseModel.courseFiles.singleWhere((element) => element.keyName=="poster_image").fileUid;
      }catch(e){
        print(e);
      }
      //getting related course
      getRelatedCourse();
    }
    if (mounted)
      setState(() {
        loading = false;
      });
  }

  getRelatedCourse() async {
    if (cityName == null) {
        cityName = "";
    }
    String str;
    for (int i = 0; i < courseModel.properties.courseType.length; i++) {
      if (str == null) {
        str = courseModel.properties.courseType.elementAt(i);
      } else {
        str = str + ";" + courseModel.properties.courseType.elementAt(i);
      }
    }
    var dataString = 'skip_content=true&advertised=true&base_country=United+Kingdom&base_city=$cityName&type=$str&show_price_history=true&show_provider_info=true&page_items=5&current_page=1';
    relatedCourse = await ApiRequest(context).getAllCourse(dataString);
    userReviews = await ApiRequest(context).getAllReview(courseModel.courseId);
    if (mounted) setState(() {});
  }

  // main function to enroll
  enrollNow() async {
    if (!isLogged) {
      Navigator.push(context,MaterialPageRoute(builder: (BuildContext context) => LoginPage(returnCount: 1,)));
    }
    if (courseModel.price.price == 0) {
      setState(() {
        loading = true;
      });
      // sending payment info to the server
      bool response = await ApiRequest(context).paymentSubscription(courseModel.courseId, "free",selectedSession.uuId);
      if (response) {
        Toast.show("Successfully Enrolled", context, backgroundColor: Colors.green, textColor: Colors.white);
      }
      setState(() {
        loading = false;
      });
      return;
    }
    CartListItem item = CartListItem(
      courseId: courseModel.courseId,
      courseName: courseModel.courseTitle,
      courseImage: courseImage,
      tutorName: courseModel.tutorFirstName.toString() +
          " " +
          courseModel.tutorLastName.toString(),
      price: courseModel.price.price,
      startDate: courseModel.startDate,
      finishDate: courseModel.endDate,
      children: [],
      sessionId: selectedSession==null?"":selectedSession.uuId,
      sessionName: selectedSession==null?"":selectedSession.name
    );
    //checking already exist or not
    inCart = await SharedPrefManager.checkCartExist(courseModel.courseId);
    if (inCart) {
      Toast.show("Already in Cart", context,
          backgroundColor: Colors.red, textColor: Colors.white);
      return;
    }
    cartController.addToCart(item);
    Toast.show("Course added to your cart", context, backgroundColor: Colors.green, textColor: Colors.white);
    setState(() {
      inCart = true;
    });
  }

  childEnrollNow(List<ChildAccountModel> childCartItem) async {
    if (courseModel.price.price == 0) {
      setState(() {
        loading = true;
      });
      bool childEnroll = false;
      for (ChildAccountModel element in childCartItem) {
        // child subscription to the server
        bool response = await ApiRequest(context).childPaymentSubscription(courseModel.courseId, "free", element.childUid,selectedSession.uuId);
        childEnroll = response;
      }
      if (childEnroll) {
        Toast.show("Successfully Enrolled", context,
            backgroundColor: Colors.green, textColor: Colors.white);
      }
      setState(() {
        loading = false;
      });
      return;
    }
    CartListItem item = CartListItem(
      courseId: courseModel.courseId,
      courseName: courseModel.courseTitle,
      courseImage: courseImage,
      tutorName: courseModel.tutorFirstName.toString() +
          " " +
          courseModel.tutorLastName.toString(),
      price: courseModel.price.price,
      startDate: courseModel.startDate,
      finishDate: courseModel.endDate,
      children: childCartItem,
      sessionId: selectedSession==null?"":selectedSession.uuId,
      sessionName: selectedSession==null?"":selectedSession.name
    );
    bool exist = await SharedPrefManager.checkCartExist(courseModel.courseId);
    if (exist) {
      Toast.show("Already in Cart", context,
          backgroundColor: Colors.red, textColor: Colors.white);
      return;
    }
    cartController.addToCart(item);
    Toast.show("Course added to your cart", context,
        backgroundColor: Colors.green, textColor: Colors.white);
    setState(() {
      inCart = true;
    });
  }

  rateNow() async {
    bool logged = await userController.loginCheck();
    if (!logged) {
      // user is not logged so redirect to loginPage
      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => LoginPage(returnCount: 1,)));
      return;
    }
    setState(() {
      loading = true;
    });
    //rate the course
    bool response = await ApiRequest(context).rateTheCourse(
        courseModel.courseId, (rating * 2), commentController.text);

    if (mounted)
      setState(() {
        loading = false;
      });
    if (response) {
      commentController.text = '';
      Toast.show("Successfully Rated", context,
          backgroundColor: Colors.green, textColor: Colors.white);
      //after rating get course data again
      getCourseData();
    } else {
      Toast.show("Failed to Rate", context,
          backgroundColor: Colors.red, textColor: Colors.white);
    }
  }



  @override
  Widget build(BuildContext context) {
    bool tablet = false;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    if (width > 479) {
      tablet = true;
    }
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: appsMainColor),
        title: Text("Course Details"),
      ),
      bottomNavigationBar: BottomNavigationBarModelView(
        activeIndex: 0,
      ),

      body: loading
          ? loader
          : loadError?Center(
        child: FlatButton.icon(
            color: Colors.black.withOpacity(.2),
            onPressed: (){
              getCourseData();
            },
            icon: Icon(Icons.refresh,),
            label: Text("Reload"),)
      ):SingleChildScrollView(
              padding: EdgeInsets.only(left: 15, right: 15, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  tablet
                      ? Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: width/2,
                                padding: EdgeInsets.only(
                                    left: 0, right: 0, top: 10, bottom: 5),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: courseImage == null
                                        ? Image.asset(
                                            "assets/images/ustad_logo.png",
                                            fit: BoxFit.cover,
                                          )
                                        : Image.network(
                                            ApiRequest(context).getBaseUrl() +
                                                '/delivery/course/${courseModel.courseId}/file/$courseImage',
                                            fit: BoxFit.fill,
                                          )),
                              ),
                              Container(
                                  margin: EdgeInsets.only(top: 10, left: 20),
                                  child: getCourseTitleRating())
                            ],
                          ),
                        )
                      : Container(
                          width: width,
                          height: width*.6,
                          padding: EdgeInsets.only(
                              left: 0, right: 0, top: 10, bottom: 5),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: courseImage==null
                                  ? Image.asset(
                                      "assets/images/ustad_logo.png",
                                      fit: BoxFit.fill,
                                    )
                                  : Image.network(
                                      ApiRequest(context).getBaseUrl() +
                                          '/delivery/course/${courseModel.courseId}/file/$courseImage',
                                      fit: BoxFit.fill,
                                    )),
                        ),
                  tablet ? Container() : getCourseTitleRating(),
                  posterImage!=null? Row(
                    children: [
                      Container(
                        child: FlatButton.icon(
                            padding: EdgeInsets.only(left: 0),
                            onPressed: (){
                              showPosterImage();
                            },
                            icon: Icon(Icons.image),
                            label: Text("View additional course image")
                        ),
                      ),
                    ],
                  ):Container(),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    padding: EdgeInsets.only(
                        left: 10, right: 5, top: 20, bottom: 15),
                    decoration:
                        BoxDecoration(color: appsMainColor.withOpacity(.1)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Text(
                            "About this course",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple),
                          ),
                        ),
                        Container(
                          child: Html(
                            data: courseModel.courseDescription,
                            style: {
                              "p": Style(
                                fontSize: FontSize.medium,
                              )
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  relatedCourse.length != 0
                      ? Container(
                          padding:
                              EdgeInsets.only(top: 15, right: 10, bottom: 10),
                          child: Text(
                            "You might be interested in ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 19,
                                color: Colors.deepPurple),
                          ),
                        )
                      : Container(),
                  Container(
                    child: getHorizontalCourse(),
                  ),
                  Container(
                    color: Colors.blue.withOpacity(.1),
                    padding: EdgeInsets.only(
                        left: 10, right: 10, top: 10, bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(
                            "Rate this course",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          child: Row(
                            children: [
                              Expanded(
                                child: RatingBar.builder(
                                  initialRating: rating,
                                  minRating: 1,
                                  itemSize: 28,
                                  direction: Axis.horizontal,
                                  allowHalfRating: true,
                                  itemCount: 5,
                                  unratedColor: Colors.grey,
                                  itemPadding:
                                      EdgeInsets.symmetric(horizontal: 4.0),
                                  itemBuilder: (context, _) => Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  onRatingUpdate: (rating) {
                                    this.rating = rating;
                                  },
                                ),
                              ),
                              Container(
                                width: 90,
                                height: 35,
                                child: FlatButton.icon(
                                  padding: EdgeInsets.only(left: 0),
                                  color: appsMainColor,
                                  onPressed: () {
                                    rateNow();
                                  },
                                  label: Text(
                                    "Submit",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  icon: Icon(
                                    Icons.send,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10, bottom: 5),
                          height: 80,
                          child: TextField(
                            expands: true,
                            minLines: null,
                            maxLines: null,
                            controller: commentController,
                            decoration: InputDecoration(
                                hintText: "Comment",
                                fillColor: Colors.white,
                                filled: true,
                                enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: appsMainColor))),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 10, right: 10, bottom: 10),
                    child: Text(
                      "Top Reviews ",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 19,
                          color: Colors.deepPurple),
                    ),
                  ),
                  userReviews.length == 0
                      ? Container(
                          margin: EdgeInsets.only(top: 10, bottom: 10),
                          child: Text(
                            "Now Review Found",
                            textAlign: TextAlign.center,
                          ),
                        )
                      : Container(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: userReviews.map((e) {
                                return Container(
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                  margin: EdgeInsets.only(top: 5),
                                  decoration: BoxDecoration(
                                      color: appsMainColor.withOpacity(.1),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: ReviewModel(
                                    review: e,
                                  ),
                                );
                              }).toList()),
                        ),
                  Container(
                    padding: EdgeInsets.only(top: 20, right: 10, bottom: 10),
                    margin: EdgeInsets.only(left: 0, top: 10),
                    child: Text(
                      "Institute / Tutor : ",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.deepPurple),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 5, bottom: 10),
                    decoration:
                        BoxDecoration(color: appsMainColor.withOpacity(.1)),
                    child: FlatButton(
                      padding: EdgeInsets.only(top: 5),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) => TutorDetails(
                                      providerId: courseModel.tutorProviderId,
                                      imageId: courseModel.tutorImageId,
                                      description: courseModel.aboutTutor,
                                      name: courseModel.tutorFirstName == null
                                          ? "UnKnown"
                                          : courseModel.tutorFirstName +
                                                      courseModel
                                                          .tutorLastName ==
                                                  null
                                              ? ""
                                              : courseModel.tutorLastName,
                                    )));
                      },
                      child: TutorProfileShort(
                        name: courseModel.tutorFirstName == null
                            ? "UnKnown"
                            : "${courseModel.tutorFirstName + " " + courseModel.tutorLastName}",
                        imageUrl: courseModel.tutorImageId,
                        shortDescription: courseModel.aboutTutor,
                        providerId: courseModel.tutorProviderId,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
  onSessionSelect(_session){
      selectedSession = _session;
      print(_session);
      preEnrollToCourse();
  }
  showPosterImage() async {
    AlertDialog alert = AlertDialog(
      title: Text("Additional Course Image"),
      actionsPadding: EdgeInsets.only(top: 0, right: 10),
      scrollable: true,
      content: Container(
        width: width,
        height: width*1,
        child: PhotoView(
          enableRotation: false,
          backgroundDecoration:BoxDecoration(
            color: Colors.transparent
          ),
          imageProvider: NetworkImage(
              ApiRequest(context).getBaseUrl() + '/delivery/course/${courseModel.courseId}/file/$posterImage',

          ),
        ),
      ),
      actions: [
        FlatButton(
            color: subColor,
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "Close",
              style: TextStyle(color: Colors.white),
            ))
      ],
    );
    showDialog(context: context, builder:(ctx)=> alert);
  }
  showChildSelect() {
    AlertDialog alert = AlertDialog(
      title: Text("Select Your Child"),
      content: Container(
          height: 300,
          width: 300,
          child: ChildSelect(
            userChildren: userChildren,
            enroll: childEnrollNow,
          )),
      actionsPadding: EdgeInsets.only(top: 0, bottom: 15),
      contentPadding: EdgeInsets.only(bottom: 15, top: 20),
    );
    showDialog(context: context, builder:(ctx)=> alert);
  }

  Widget getCourseTitleRating() {
    bool discounted = false;
    double lastCoursePrice = courseModel.price.price;
    DateTime lastDate = DateTime.parse("2020-01-01");
    for (int i = 0; i < courseModel.pricesHistory.length; i++) {
      PriceModel price = courseModel.pricesHistory[i];
      if (price.endDate != null) {
        DateTime endDate = price.endDate;
        if (endDate.isAfter(lastDate)) {
          lastDate = endDate;
          lastCoursePrice = price.price +
              ((price.price + price.serviceCharge) * (price.vat / 100)) +
              price.serviceCharge;
        }
      }
    }
    if (lastCoursePrice > courseModel.price.price) {
      discounted = true;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(top: 5),
          child: Text(
            courseModel.courseTitle,
            style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: appsMainColor),
          ),
        ),
        Container(
            padding: EdgeInsets.only(top: 10, bottom: 10),
            child: RatingBarIndicator(
              rating: (courseModel.avgRating / 2.0),
              itemBuilder: (context, index) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              itemCount: 5,
              itemSize: 24.0,
              direction: Axis.horizontal,
              unratedColor: Colors.grey,
            )),
        Container(
          margin: EdgeInsets.only(right: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 5),
                    child: Text(
                        courseModel.price.price == 0
                            ? "FREE"
                            : "Price :  £ ${courseModel.price.price.toStringAsFixed(2)}",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: appsMainColor)),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  discounted
                      ? Text(
                          "£${lastCoursePrice.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.black.withOpacity(.4),
                          ),
                        )
                      : Container(),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: 5, bottom: 2),
          child: Text(
            "Start From :  ${DateFormatHelper.fromDate(courseModel.startDate)}",
            style: TextStyle(
              fontSize: 14,
              // fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: 2, bottom: 5),
          child: Text(
            "End To        :  ${DateFormatHelper.fromDate(courseModel.endDate)}",
            style: TextStyle(
              fontSize: 14,
              // fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: 2, bottom: 5),
          child: Text(
            "Age              :  ${courseModel.properties.under16 == "under_16" ? "Under 16" : courseModel.properties.under16 == "over_16" ? "Over 16" : "Both"}",
            style: TextStyle(
              fontSize: 14,
              // fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: 2, bottom: 5),
          child: Text(
            "Location     :  ${courseModel.cityName} ( ${courseModel.properties.mode == "both" ? "Online & Onsite" : courseModel.properties.mode} )",
            style: TextStyle(
              fontSize: 14,
              // fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: 2, bottom: 5),
          child: Text(
            "Enrollment status     :  ${courseModel.properties.courseAdmissionStatus}",
            style: TextStyle(
              fontSize: 14,
              // fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
        Container(
          height: 40,
          margin: EdgeInsets.only(top: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              FlatButton(
                color: appsMainColor,
                padding:
                    EdgeInsets.only(top: 0, bottom: 0, left: 15, right: 15),
                onPressed: () {
                  preEnrollToCourse();
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 2),
                  child: Text(
                    "Enroll Now",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: .5),
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              FlatButton(
                color: appsMainColor,
                padding:
                    EdgeInsets.only(top: 0, bottom: 0, left: 10, right: 10),
                onPressed: () {
                  addToWishList();
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 2),
                  child: Text(
                    "Add to Favourites",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: .5),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget getHorizontalCourse() {
    return Container(
      padding: EdgeInsets.only(left: 0, right: 10),
      margin: EdgeInsets.only(top: 5),
      child: Container(
        height: relatedCourse.length == 0 ? 0 : 170,
        padding: EdgeInsets.only(left: 5),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: relatedCourse.map((e) {
            return Container(
              height: 100,
              width: 180,
              padding: EdgeInsets.only(),
              child: FlatButton(
                padding: EdgeInsets.all(0),
                onPressed: () {
                  widget.courseId = e.courseId;
                  getCourseData();
                },
                child: CourseCardInterested(
                  courseModel: e,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class FeatureItemModel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subTitle;

  FeatureItemModel({@required this.icon, @required this.title, this.subTitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: Row(
        children: [
          Container(
            child: Icon(
              icon,
              size: 35,
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 2, bottom: 2),
                    child: Text(
                      title,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  subTitle == null
                      ? Container()
                      : Container(
                          child: Text(
                            subTitle,
                            maxLines: 10,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ReviewModel extends StatelessWidget {
  final ConsumerReviewModel review;

  ReviewModel({this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(top: 10, bottom: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(right: 10),
              width: 70,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      width: 60.0,
                      height: 60.0,
                      margin: EdgeInsets.only(left: 0),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.fill,
                            image: review.profileImageId == null
                                ? AssetImage("assets/images/student_dummy.png")
                                : NetworkImage(ApiRequest(context)
                                        .getBaseUrl() +
                                    '/delivery/consumer/${review.consumerId}/file/${review.profileImageId}'),
                          ))),
                  Container(
                    width: 60,
                    margin: EdgeInsets.only(top: 5),
                    child: Text(
                      review.firstName == null
                          ? "UnKnown"
                          : "${review.firstName + (review.lastName == null ? "" : review.lastName)}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                          fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      padding: EdgeInsets.only(top: 5, bottom: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          RatingBarIndicator(
                            rating: (review.rating / 2),
                            itemBuilder: (context, index) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            itemCount: 5,
                            itemSize: 20.0,
                            direction: Axis.horizontal,
                            unratedColor: Colors.grey,
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 5, top: 2, bottom: 2),
                            child: Text(
                              (review.rating / 2).toStringAsFixed(1),
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 10),
                            child: Text(
                              " ${DateFormatHelper.fromString(review.dateTime)}",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14),
                            ),
                          ),
                        ],
                      )),
                  Container(
                    child: Text(
                      review.comment == null ? "" : review.comment,
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                          fontSize: 14),
                      maxLines: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}

class TutorProfileShort extends StatelessWidget {
  final String name;
  final String shortDescription;
  final String imageUrl, providerId;
  BuildContext ctx;

  TutorProfileShort(
      {this.name, this.imageUrl, this.shortDescription, this.providerId});

  @override
  Widget build(BuildContext context) {
    ctx = context;
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              width: 70.0,
              height: 70.0,
              margin: EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: imageUrl == null
                        ? AssetImage("assets/images/profe.png")
                        : NetworkImage(
                            ApiRequest(context).getBaseUrl() +
                                '/delivery/provider/$providerId/file/$imageUrl',
                          ),
                  ))),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 2, bottom: 2),
                    child: Text(
                      name,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  shortDescription == null
                      ? Container()
                      : Container(
                          child: Html(
                            data: shortDescription,
                          ),
                        )
                ],
              ),
            ),
          ),
//          Container(
//            margin: EdgeInsets.only(right: 5, left: 5),
//            child: Column(
//              mainAxisAlignment: MainAxisAlignment.spaceBetween,
//              children: [
//                RatingBarIndicator(
//                  rating: 4.2,
//                  itemBuilder: (context, index) => Icon(
//                    Icons.star,
//                    color: Colors.amber,
//                  ),
//                  itemCount: 5,
//                  itemSize: 22.0,
//                  direction: Axis.horizontal,
//                  unratedColor: Colors.grey,
//                ),
//                Container(
//                  alignment: Alignment.topCenter,
//                  width: 100,
//                  margin: EdgeInsets.only(right: 5, top: 5),
//                  child: FlatButton.icon(
//                      padding: EdgeInsets.only(left: 5, right: 10),
//                      color: appsMainColor,
//                      icon: Icon(
//                        Icons.star,
//                        color: Colors.amber,
//                      ),
//                      onPressed: () {
//                        showTutorRatingDialog();
//                      },
//                      label: Text(
//                        "Rate Me",
//                        style: TextStyle(color: Colors.white),
//                      )),
//                )
//              ],
//            ),
//          ),
        ],
      ),
    );
  }

  showTutorRatingDialog() async {
    AlertDialog alert = AlertDialog(
      title: Text("Rate the Tutor"),
      actionsPadding: EdgeInsets.only(top: 0, right: 10),
      content: Container(
        child: RatingBar.builder(
          initialRating: 3.5,
          minRating: 1,
          itemSize: 35,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          unratedColor: Colors.grey,
          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, _) => Icon(
            Icons.star,
            color: Colors.amber,
          ),
          onRatingUpdate: (rating) {},
        ),
      ),
      actions: [
        FlatButton(
            color: appsMainColor,
            onPressed: () {},
            child: Text(
              "Submit",
              style: TextStyle(color: Colors.white, letterSpacing: .3),
            ))
      ],
    );
    showDialog(context: ctx, builder:(ctx)=> alert);
  }

  submitRatingToTutor() async {}
}

class FAQExpansionTiles extends StatelessWidget {
  String title;
  String description;

  FAQExpansionTiles({this.title, this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ExpansionTile(
        title: Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        children: [
          Container(
              padding: EdgeInsets.only(left: 15, right: 15, top: 0, bottom: 15),
              child: Text(
                description,
                style: TextStyle(color: Colors.black),
              )),
        ],
      ),
    );
  }
}

class ChildSelect extends StatefulWidget {
  final List<ChildAccountModel> userChildren;
  dynamic enroll;
  ChildSelect({this.userChildren, this.enroll});
  @override
  _ChildSelectState createState() => _ChildSelectState();
}

class _ChildSelectState extends State<ChildSelect> {
  Set<ChildAccountModel> selectedChild = Set<ChildAccountModel>();
  bool checked = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(
          child: ListView(
            children: widget.userChildren.map((e) {
              String name = "";
              if (e.firstName != null) name += " " + e.firstName;
              if (e.middleName != null) name += " " + e.middleName;
              if (e.lastName != null) name += " " + e.lastName;
              bool selected = false;
              selectedChild.forEach((element) {
                if (element.childUid == e.childUid) {
                  selected = true;
                }
              });
              bool enrolled = false;
              return Container(
                  height: 40,
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                      border: Border(
                          bottom:
                              BorderSide(color: Colors.black.withOpacity(.2)))),
                  child: FlatButton(
                    disabledColor: Colors.grey,
                    color:
                        selected ? Colors.deepPurpleAccent : Colors.transparent,
                    padding: EdgeInsets.only(left: 0),
                    onPressed: enrolled
                        ? null
                        : () {
                            selected
                                ? selectedChild.removeWhere(
                                    (element) => element.childUid == e.childUid)
                                : selectedChild
                                    .add(ChildAccountModel(firstName: name, childUid: e.childUid));
                            setState(() {});
                          },
                    child: Container(
                        child: Text(
                      name + (enrolled ? " (enrolled)" : ""),
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.black,
                      ),
                    )),
                  ));
            }).toList(),
          ),
        ),
        Container(
          child: Row(
            children: [
              Checkbox(
                  value: checked,
                  onChanged: (value) {
                    setState(() {
                      checked = value;
                    });
                  }),
              Flexible(
                child: Container(
                  child: Text(
                      "I give consent for my child to be tought online via audio and video"),
                ),
              )
            ],
          ),
        ),
        Container(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                child: FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Back",
                      style: TextStyle(color: appsMainColor),
                    )),
              ),
              Container(
                child: FlatButton(
                    onPressed: selectedChild.length == 0 || !checked
                        ? null
                        : () {
                            widget.enroll(selectedChild.toList());
                            Navigator.pop(context);
                          },
                    disabledTextColor: Colors.grey,
                    textColor: appsMainColor,
                    child: Text("Select")),
              ),
            ],
          ),
        )
      ],
    );
  }
}
