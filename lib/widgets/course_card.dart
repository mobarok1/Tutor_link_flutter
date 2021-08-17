import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:tutorlink/api/api_request.dart';
import 'package:tutorlink/extra/dateService.dart';
import 'package:tutorlink/extra/theme_data.dart';
import 'package:tutorlink/modelClass/course_model.dart';
import 'package:tutorlink/modelClass/price_history.dart';

class CourseCard extends StatelessWidget {
  CourseModel courseModel;
  CourseCard({
    @required this.courseModel,
  });
  bool tablet = false;
  double width = 0;
  bool discounted = false;
  double lastCoursePrice = 0;
  DateTime lastDate = DateTime.parse("2020-01-01");
  String courseImage;

  @override
  Widget build(BuildContext context) {
    lastCoursePrice = courseModel.price.price;
    for (int i = 0; i < courseModel.pricesHistory.length; i++) {
      PriceModel price = courseModel.pricesHistory[i];
      if (price.endDate != null) {
        DateTime endDate = price.endDate;
        if (endDate.isAfter(lastDate)) {
          lastDate = endDate;
          lastCoursePrice = price.price;
        }
      }
    }
    if (lastCoursePrice > courseModel.price.price) {
      discounted = true;
    }
    width = MediaQuery.of(context).size.width;

    if (width > 479) {
      tablet = true;
    }
    try {
      courseImage = courseModel.courseFiles
          .singleWhere((element) => element.keyName == "course_image")
          .fileUid;
    }catch(e){}
    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: 10),
      child: Container(
        padding: EdgeInsets.only(bottom: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            tablet?Container(
              height: (width/2)*.6,
              child: Row(
                children: [
                  SizedBox(
                    width: width/2,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: courseImage == null
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
                  getTileRating()
                ],
              ),
            ):
            SizedBox(
              width: width,
              height: width * .6,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: courseImage==null
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
            !tablet?getTileRating():Container()

          ],
        ),
      ),
    );
  }
  getTileRating(){
    return Container(
      margin: EdgeInsets.only(left: 5, ),
      width: (width/2)-40,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(left: 5, top: 10),
            child: Text(
              courseModel.courseTitle,
              maxLines: 2,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: appsMainColor
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 5),
                    padding: EdgeInsets.only(top: 2, bottom: 2),
                    alignment: Alignment.centerLeft,
                    child: Text("Start date : ${DateFormatHelper.fromDate(courseModel.startDate)}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 5),
                    padding: EdgeInsets.only(top: 1, bottom: 1),
                    alignment: Alignment.centerLeft,
                    child: Text("(Enrolment ${courseModel.properties.courseAdmissionStatus})",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                  tablet? Container(
                    margin: EdgeInsets.only(left: 5),
                    padding: EdgeInsets.only(top: 2, bottom: 2),
                    alignment: Alignment.centerLeft,
                    child: Text("Tutor : ${(courseModel.tutorFirstName+" "+courseModel.tutorLastName).replaceAll("null", "")}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ):Container(),
                  Container(
                      padding: EdgeInsets.only(top: 2, bottom: 2),
                      child: Row(
                        children: [
                          RatingBarIndicator(
                            rating: (courseModel.avgRating / 2) < 0
                                ? 0
                                : (courseModel.avgRating / 2),
                            itemBuilder: (context, index) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            unratedColor: Colors.grey,
                            itemCount: 5,
                            itemSize: 24.0,
                            direction: Axis.horizontal,
                          ),
                          // Container(
                          //   margin: EdgeInsets.only(left: 5),
                          //   child: Text(
                          //     (courseModel.avgRating / 2) < 0
                          //         ? "0"
                          //         : (courseModel.avgRating / 2)
                          //         .toStringAsFixed(1),
                          //     style: TextStyle(
                          //         color: Colors.black,
                          //         fontSize: 14,
                          //         fontWeight: FontWeight.bold),
                          //   ),
                          // ),
                        ],
                      )),
                  !tablet?Container():getPrice()                ],
              ),
              tablet?Container():getPrice()
            ],
          ),
        ],
      ),
    );
  }
  getPrice(){
    return Container(
      margin: EdgeInsets.only(right: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          discounted
              ? Container(
            margin: EdgeInsets.only(right: 7),
            child: Text(
              "£${lastCoursePrice.toStringAsFixed(2)}",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.lineThrough,
                color: Colors.black.withOpacity(.4),
              ),
            ),
          )
              : Container(),
          courseModel.price.price>0?Row(
            children: [
              discounted
                  ? Container(
                decoration: BoxDecoration(
                    color: Color.fromRGBO(255,36,0 , 1),
                    borderRadius: BorderRadius.circular(7)),
                padding: EdgeInsets.symmetric(
                    vertical: 5, horizontal: 5),
                child: Text(
                  "-${(((lastCoursePrice - courseModel.price.price) / lastCoursePrice) * 100).round()}%",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              )
                  : Container(),
              !tablet?SizedBox(
                width: 10,
              ):Container(),
              Text(
                "${(tablet?" Price : £ ":" £ ")+courseModel.price.price.toStringAsFixed(2)}",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: appsMainColor),
              ),
              SizedBox(
                width: 5,
              ),
            ],
          ):Text(
            " FREE",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: appsMainColor),
          ),
        ],
      ),
    );
  }
}

class CourseCardHorizontal extends StatelessWidget {
  final CourseModel courseModel;
  CourseCardHorizontal({
    @required this.courseModel,
  });
  @override
  Widget build(BuildContext context) {
    bool discounted = false;
    double lastCoursePrice = courseModel.price.price;
    DateTime lastDate = DateTime.parse("2020-01-01");
    for (int i = 0; i < courseModel.pricesHistory.length; i++) {
      PriceModel price = courseModel.pricesHistory[i];
      if (price.endDate != null) {
        DateTime endDate = price.endDate;
        if (endDate.isAfter(lastDate)) {
          lastDate = endDate;
          lastCoursePrice = price.price;
        }
      }
    }
    if (lastCoursePrice > courseModel.price.price) {
      discounted = true;
    }
    String courseImage ;
    try{
     courseImage = courseModel.courseFiles.singleWhere((element) => element.keyName == "course_image").fileUid;
    }catch(e){}
    return Container(
      padding: EdgeInsets.only(bottom: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            child: Stack(
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 8),
                  height: 160,
                  width: 270,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child:courseImage==null
                            ? Image.asset(
                          "assets/images/ustad_logo.png",
                          fit: BoxFit.fitWidth,
                        )
                            : Image.network(
                          ApiRequest(context).getBaseUrl() +
                              '/delivery/course/${courseModel.courseId}/file/$courseImage',
                          fit: BoxFit.fill,
                        )),
                ),
                Positioned(
                  bottom: 7,
                  right: 10,
                  child:  discounted
                      ? Container(
                    decoration: BoxDecoration(
                        color: Colors.red,
                        //  color: Color.fromRGBO(255,36,0 , 1),
                        borderRadius: BorderRadius.circular(7)),
                    padding: EdgeInsets.symmetric(
                        vertical: 5, horizontal: 5),
                    child: Text(
                      "-${(((lastCoursePrice - courseModel.price.price) / lastCoursePrice) * 100).round()}% OFF",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  )
                      : Container(),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 5,top: 5,bottom: 5),
            padding: EdgeInsets.only(left: 0, right: 10),
            alignment: Alignment.centerLeft,
            child: Text(
              courseModel.courseTitle,
              maxLines: 1,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: appsMainColor
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 5),
                    padding: EdgeInsets.only(top: 2, bottom: 2),
                    alignment: Alignment.centerLeft,
                    child: Text("Start date : ${DateFormatHelper.fromDate(courseModel.startDate)}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 5),
                    padding: EdgeInsets.only(top: 1, bottom: 1),
                    alignment: Alignment.centerLeft,
                    child: Text("(Enrolment ${courseModel.properties.courseAdmissionStatus})",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 2, bottom: 2),
                    child: RatingBarIndicator(
                      rating: (courseModel.avgRating / 2),
                      itemBuilder: (context, index) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      itemCount: 5,
                      itemSize: 24.0,
                      direction: Axis.horizontal,
                    ),
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.only(right: 10),
                child: courseModel.price.price>0?Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        discounted
                            ? Text(
                                "£${lastCoursePrice.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.black.withOpacity(.4),
                                ),
                              )
                            : Container(),
                        SizedBox(
                          width: 10,
                          height: 5,
                        ),
                        Text(
                          "£" + courseModel.price.price.toStringAsFixed(2),
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: appsMainColor),
                          // color: Color.fromRGBO(255, 36, 0, 1)),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                      ],
                    ),
                    // Container(
                    //   height: 30,
                    //   margin: EdgeInsets.only(top: 2, bottom: 5),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.end,
                    //     children: [
                    //       IconButton(
                    //         onPressed: () {},
                    //         icon: Icon(
                    //           Icons.favorite_border,
                    //           size: 25,
                    //           color: Colors.red,
                    //         ),
                    //       ),
                    //       IconButton(
                    //         onPressed: () {},
                    //         icon: Icon(
                    //           Icons.add_shopping_cart,
                    //           size: 25,
                    //           color: Colors.red,
                    //         ),
                    //       )
                    //     ],
                    //   ),
                    // )
                  ],
                ):Text(
                  "FREE",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                     color: Colors.red),
                  ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
class CourseCardFeatured extends StatelessWidget {
  CourseModel courseModel;
  CourseCardFeatured({
    @required this.courseModel,
  });

  @override
  Widget build(BuildContext context) {
    bool discounted = false;
    double lastCoursePrice = courseModel.price.price;
    DateTime lastDate = DateTime.parse("2020-01-01");
    for (int i = 0; i < courseModel.pricesHistory.length; i++) {
      PriceModel price = courseModel.pricesHistory[i];
      if (price.endDate != null) {
        DateTime endDate = price.endDate;
        if (endDate.isAfter(lastDate)) {
          lastDate = endDate;
          lastCoursePrice = price.price;
        }
      }
    }
    if (lastCoursePrice > courseModel.price.price) {
      discounted = true;
    }
    String courseImage ;
    try{
      courseImage = courseModel.courseFiles.singleWhere((element) => element.keyName == "course_image").fileUid;
    }catch(e){}

    return Container(
      padding: EdgeInsets.only(bottom: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            child: Stack(
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 8),
                  height: 160,
                  width: 270,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child:courseImage==null
                          ? Image.asset(
                        "assets/images/ustad_logo.png",
                        fit: BoxFit.fitWidth,
                      )
                          : Image.network(
                        ApiRequest(context).getBaseUrl() +
                            '/delivery/course/${courseModel.courseId}/file/${courseModel.courseFiles.singleWhere((element) => element.keyName == "course_image").fileUid}',
                        fit: BoxFit.fill,
                      )),
                ),
                Positioned(
                  bottom: 7,
                  right: 10,
                  child:Container(
                    decoration: BoxDecoration(
                        color: Colors.red,
                        //  color: Color.fromRGBO(255,36,0 , 1),
                        borderRadius: BorderRadius.circular(7)),
                    padding: EdgeInsets.symmetric(
                        vertical: 5, horizontal: 10),
                    child: Text(
                      "Featured",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  )
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 5),
            padding: EdgeInsets.only(left: 0, right: 10),
            alignment: Alignment.centerLeft,
            child: Text(
              courseModel.courseTitle,
              maxLines: 1,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: appsMainColor
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Container(
                  //   margin: EdgeInsets.only(left: 5),
                  //   padding: EdgeInsets.only(top: 2, bottom: 2),
                  //   alignment: Alignment.centerLeft,
                  //   width: 150,
                  //   child: Text(
                  //     courseModel.tutorFirstName == null
                  //         ? "Tutor : UnKnown"
                  //         : "Tutor : ${courseModel.tutorFirstName} ${courseModel.tutorLastName} ",
                  //     maxLines: 1,
                  //     overflow: TextOverflow.ellipsis,
                  //     style: TextStyle(
                  //       fontSize: 15,
                  //     ),
                  //   ),
                  // ),
                  Container(
                    margin: EdgeInsets.only(left: 5),
                    padding: EdgeInsets.only(top: 2, bottom: 2),
                    alignment: Alignment.centerLeft,
                    child: Text("Start date : ${DateFormatHelper.fromDate(courseModel.startDate)}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 5),
                    padding: EdgeInsets.only(top: 1, bottom: 1),
                    alignment: Alignment.centerLeft,
                    child: Text("(Enrolment ${courseModel.properties.courseAdmissionStatus})",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 2, bottom: 2),
                    child: RatingBarIndicator(
                      rating: (courseModel.avgRating / 2),
                      itemBuilder: (context, index) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      itemCount: 5,
                      itemSize: 24.0,
                      direction: Axis.horizontal,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CourseCardInterested extends StatelessWidget {
  CourseModel courseModel;
  CourseCardInterested({
    @required this.courseModel,
  });
  String courseImage;

  @override
  Widget build(BuildContext context) {
    try{
      courseImage = courseModel.courseFiles.singleWhere((element) => element.keyName == "course_image").fileUid;
    }catch(e){}
    return Container(
      padding: EdgeInsets.only(bottom: 5),
      margin: EdgeInsets.only(right: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            child: Stack(
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 8),
                  height: 100,
                  width: 180,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child:  courseImage==null ?
                      Image.asset(
                        "assets/images/ustad_logo.png",
                        fit: BoxFit.fill,
                      )
                          : Image.network(
                        ApiRequest(context).getBaseUrl() +
                            '/delivery/course/${courseModel.courseId}/file/$courseImage',
                        fit: BoxFit.fill,
                      )
                  ),
                ),
                Positioned(
                  child: Container(),
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 5),
            alignment: Alignment.centerLeft,
            child: Text(
              courseModel.courseTitle,
              maxLines: 1,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                  color: appsMainColor
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
              padding: EdgeInsets.only(top: 2, bottom: 2),
              child: Row(
                children: [
                  RatingBarIndicator(
                    rating: (courseModel.avgRating / 2),
                    itemBuilder: (context, index) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    itemCount: 5,
                    itemSize: 18.0,
                    direction: Axis.horizontal,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 5),
                    child: Text(
                      (courseModel.avgRating / 2) <= 0
                          ? "0"
                          : (courseModel.avgRating / 2).toStringAsFixed(1),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
//                  Container(
//                    child: Text(
//                      " (428)",
//                      style: TextStyle(
//                          color: Colors.black, fontWeight: FontWeight.w600),
//                    ),
//                  )
                ],
              )),
        ],
      ),
    );
  }
}
