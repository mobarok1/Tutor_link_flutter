import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tutorlink/Pages/course_details.dart';
import 'package:tutorlink/api/api_request.dart';
import 'package:tutorlink/controller/cart_controller.dart';
import 'package:tutorlink/extra/theme_data.dart';
import 'package:tutorlink/modelClass/consumer_subscription_model.dart';
import 'package:tutorlink/modelClass/session_model.dart';

class ConsumerOrderPage extends StatefulWidget {
  @override
  _ConsumerOrderPageState createState() => _ConsumerOrderPageState();
}

class _ConsumerOrderPageState extends State<ConsumerOrderPage> {
  bool loading = false;
  List<SubscriptionModel> allSubscription = List<SubscriptionModel>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllCourses();
  }

  getAllCourses() async {
    setState(() {
      loading = true;
    });
    allSubscription = await ApiRequest(context).getConsumerEnrolledCourses();
    allSubscription.removeWhere((element) => element.status != 1);
    for (SubscriptionModel subscription in allSubscription) {
      if (subscription.childUid.isNotEmpty) {
        subscription.child = await ApiRequest(context).getChildInfo(subscription.childUid);
      }
      if (subscription.sessionUid.isNotEmpty) {
        List<SessionModel> allSession = await ApiRequest(context).getCourseSession(subscription.courseId);
        allSession.forEach((element) {
          if(element.uuId == subscription.sessionUid){
            subscription.sessionName = element.name;
          }
        });
      }
      subscription.courseDetails = await ApiRequest(context).getCourseData(subscription.courseId);

    }
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: appsMainColor),
          title: Text(
            'Enrolled Courses',
            style:
                TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          ),
        ),
        body: loading
            ? Center(child: loader)
            : allSubscription.length == 0
                ? Center(child: Text("No Course Enrolled"))
                : ListView.separated(
                    padding: EdgeInsets.only(
                        left: 10, right: 10, top: 5, bottom: 10),
                    itemCount: allSubscription.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider(color: Colors.black);
                    },
                    itemBuilder: (BuildContext context, int index) {
                      SubscriptionModel e = allSubscription[index];
                      bool childEnrolled = false;
                      String childName = "";
                      if (e.childUid.isNotEmpty) {
                        childEnrolled = true;
                        childName = (e.child.firstName +" "+
                                e.child.middleName +" "+
                                e.child.lastName)
                            .replaceAll("null", "");
                      }
                      String courseImage;
                      try{
                        courseImage = e.courseDetails.courseFiles.singleWhere((element) => element.keyName == "course_image").fileUid;
                      }catch(e){

                      }
                      return Container(
                        margin: EdgeInsets.only(bottom: 0, top: 0),
                        child: FlatButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        CourseDetails(
                                          courseId: e.courseId,
                                        )));
                          },
                          padding: EdgeInsets.only(
                              left: 0, top: 2, bottom: 2, right: 0),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                      height: 50,
                                      width: 50,
                                      margin: EdgeInsets.only(
                                          bottom: 5, left: 5, right: 10),
                                      child: courseImage == null
                                          ? Image.asset(
                                              "assets/images/ustad_logo.png")
                                          : Image.network(
                                              ApiRequest(context).getBaseUrl() +
                                                  '/delivery/course/${e.courseId}/file/$courseImage',
                                              fit: BoxFit.fill,
                                            )),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(
                                              top: 0, bottom: 2, right: 15),
                                          child: Text(
                                            e.courseDetails.courseTitle,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: appsMainColor,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        childEnrolled
                                            ? Container(
                                          padding: EdgeInsets.only(right: 5),
                                          child: Text(
                                            "Enrolled for : $childName",
                                            maxLines: 2,
                                            style: TextStyle(fontSize: 14,color: e.child.childUid=="1"?subColor:Colors.black),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        )
                                            : Container(),
                                        e.sessionUid.isNotEmpty
                                            ? Container(
                                          padding: EdgeInsets.only(right: 5),
                                          child: Text(
                                            "Session : ${e.sessionName??"Not found"}",
                                            maxLines: 2,
                                            style: TextStyle(fontSize: 14),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        )
                                            : Container(),
                                      ],
                                    )
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        child: Text(
                                          e.price == 0
                                              ? "FREE"
                                              : "Price : £ ${e.price.toStringAsFixed(2)}",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: appsMainColor),
                                        ),
                                      ),
                                      Container(
                                        child: Text(
                                          "Start : ${e.courseDetails.properties.classStart}",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ));
  }
}
