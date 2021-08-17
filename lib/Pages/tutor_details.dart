import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:tutorlink/Pages/course_details.dart';
import 'package:tutorlink/api/api_request.dart';
import 'package:tutorlink/extra/theme_data.dart';
import 'package:tutorlink/modelClass/course_model.dart';
import 'package:tutorlink/widgets/course_card.dart';
import 'package:tutorlink/widgets/loader.dart';

class TutorDetails extends StatefulWidget {
  final String name;
  final String imageId;
  final String providerId;
  final String description;
  final double rating;
  TutorDetails({
   this.name,this.description,this.imageId,this.providerId,this.rating
  });
  @override
  _TutorDetailsState createState() => _TutorDetailsState();
}

class _TutorDetailsState extends State<TutorDetails> {
  List<CourseModel> courses = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getTutorCourses();
    });
  }
  getTutorCourses() async{
    ProgressLoader.show();
  //  await ApiRequest(context).get
    courses =(await ApiRequest(context).getAllCourse("skip_content=true&show_price_history=true&show_provider_info=true&page_items=100&current_page=1"));
    ProgressLoader.close();
    setState(() {

    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tutor Details"),
        iconTheme: IconThemeData(color: appsMainColor),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(left: 15, right: 15, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                width: 120.0,
                height: 120.0,
                alignment: Alignment.center,
                margin: EdgeInsets.only(top: 20, bottom: 10),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        fit: BoxFit.fill,
                        image: widget.imageId==null?AssetImage("assets/images/profe.png"):NetworkImage(ApiRequest(context).getBaseUrl()+'/delivery/provider/${widget.providerId}/file/${widget.imageId}'),
                    )
                )
            ),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(top: 2, bottom: 5),
              child: Text(
                widget.name,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              child: widget.description == null? Text(
                "No Data Found",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.black),
              ):Html(data:widget.description),
            ),
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(bottom: 20),
              child: Text(
                "${widget.name}'s courses",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Column(
                children: courses.map((e){
                  return Container(
                    padding: EdgeInsets.only(),
                    child: FlatButton(
                      padding: EdgeInsets.all(0),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    CourseDetails(
                                        courseId: e.courseId)));
                      },
                      child: CourseCard(
                        courseModel: e,
                      ),
                    ),
                  );}).toList()
            ),
//            Container(
//              margin: EdgeInsets.only(top: 10, bottom: 10),
//              alignment: Alignment.center,
//              height: 1,
//              color: Color(0xFFCCCCCC),
//            ),
//            Container(
//              height: 35,
//              child: FlatButton(
//                onPressed: () {},
//                child: Text(
//                  "University of California San Diego",
//                  style: TextStyle(color: Colors.blueAccent, fontSize: 16),
//                ),
//              ),
//            ),
//            Container(
//              height: 35,
//              child: FlatButton(
//                onPressed: () {},
//                child: Text(
//                  "McMaster University",
//                  style: TextStyle(color: Colors.blueAccent, fontSize: 16),
//                ),
//              ),
//            ),
//            Container(
//              height: 35,
//              child: FlatButton(
//                onPressed: () {},
//                child: Text(
//                  "National UNiversity Of Bangladesh",
//                  style: TextStyle(color: Colors.blueAccent, fontSize: 16),
//                ),
//              ),
//            ),
//            Container(
//              margin: EdgeInsets.only(top: 10, bottom: 10),
//              alignment: Alignment.center,
//              height: 1,
//              color: Color(0xFFCCCCCC),
//            ),
//            Container(
//              child: Text(
//                CourseData.professorBio,
//                textAlign: TextAlign.left,
//                style: TextStyle(
//                    fontSize: 15,
//                    color: Colors.black,
//                    fontWeight: FontWeight.w400),
//              ),
//            ),
          ],
        ),
      ),
    );
  }
}
