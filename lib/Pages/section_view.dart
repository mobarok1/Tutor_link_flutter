import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tutorlink/Pages/course_details.dart';
import 'package:tutorlink/api/api_request.dart';
import 'package:tutorlink/extra/theme_data.dart';
import 'package:tutorlink/modelClass/category_model_type.dart';
import 'package:tutorlink/modelClass/course_model.dart';
import 'package:tutorlink/modelClass/section_model.dart';
import 'package:tutorlink/widgets/course_card.dart';
class SectionView extends StatefulWidget {
   final SectionModel sectionModel;
  SectionView({this.sectionModel});

  @override
  _SectionViewState createState() => _SectionViewState();
}

class _SectionViewState extends State<SectionView> {
  Set<CourseModel> courses = Set<CourseModel>();
  bool loading = false,moreLoading = false;
  int perPageLoad = 5,currentPage = 1,lastLoad;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    lastLoad = perPageLoad;
    getAllCourseOfCategory();
  }

  getAllCourseOfCategory() async {
    setState(() {
      loading = true;
    });
    var dataString = 'skip_content=true&category=${widget.sectionModel.value}&show_price_history=true&show_provider_info=true&page_items=$perPageLoad&current_page=$currentPage&sort_by_creationdate=true&sort_order=desc&sort_by_creationdate=true&sort_order=desc';
    if(widget.sectionModel.value == "paid"){
      dataString = "skip_content=true&advertised=true&base_country=United+Kingdom&${cityName == null ? "" : "base_city=$cityName"}&show_provider_info=true&show_price_history=true&page_items=$perPageLoad&current_page=$currentPage&sort_by_creationdate=true&sort_order=desc";
    }else if(widget.sectionModel.value == "top10"){
      dataString = "skip_content=true&min_rate=5&show_provider_info=true&show_price_history=true&page_items=$perPageLoad&current_page=$currentPage&sort_by_creationdate=true&sort_order=desc";
    }else if(widget.sectionModel.value == "online"){
      dataString = "skip_content=true&mode=online&show_provider_info=true&show_price_history=true&page_items=$perPageLoad&current_page=$currentPage&sort_by_creationdate=true&sort_order=desc";
    }else if(widget.sectionModel.value == "categoryView"){
      dataString = 'skip_content=true&type=${widget.sectionModel.keyName}&show_price_history=true&show_provider_info=true&page_items=$perPageLoad&current_page=$currentPage&sort_by_creationdate=true&sort_order=desc';
    }else if(widget.sectionModel.value == "freeView"){
      dataString = 'skip_content=true&course_tag=free&show_price_history=true&show_provider_info=true&page_items=$perPageLoad&current_page=$currentPage&sort_by_creationdate=true&sort_order=desc';
    }else if(widget.sectionModel.value == "EventView"){
      dataString = 'skip_content=true&course_event_tag=event&show_price_history=true&show_provider_info=true&page_items=$perPageLoad&current_page=$currentPage&sort_by_creationdate=true&sort_order=desc';
    }
    courses = (await ApiRequest(context).getAllCourse(dataString)).toSet();
    lastLoad = courses.length;
    setState(() {
      loading = false;
    });
  }
  getMoreCourse() async {
    setState(() {
      moreLoading = true;
    });
    String dataString = 'skip_content=true&category=${widget.sectionModel.value}&show_price_history=true&show_provider_info=true&page_items=$perPageLoad&current_page=$currentPage&sort_by_creationdate=true&sort_order=desc';
    if(widget.sectionModel.value == "paid"){
      dataString = "skip_content=true&advertised=true&base_country=United+Kingdom&${cityName == null ? "" : "base_city=$cityName"}&show_provider_info=true&show_price_history=true&page_items=$perPageLoad&current_page=$currentPage&sort_by_creationdate=true&sort_order=desc";
    }else if(widget.sectionModel.value == "top10"){
      dataString = "skip_content=true&min_rate=5&show_provider_info=true&show_price_history=true&page_items=$perPageLoad&current_page=$currentPage&sort_by_creationdate=true&sort_order=desc";
    }else if(widget.sectionModel.value == "online"){
      dataString = "skip_content=true&mode=online&show_provider_info=true&show_price_history=true&page_items=$perPageLoad&current_page=$currentPage&sort_by_creationdate=true&sort_order=desc";
    }else if(widget.sectionModel.value == "categoryView"){
      dataString = 'skip_content=true&type=${widget.sectionModel.keyName}&show_price_history=true&show_provider_info=true&page_items=$perPageLoad&current_page=$currentPage&sort_by_creationdate=true&sort_order=desc';
    }else if(widget.sectionModel.value == "freeView"){
      dataString = 'skip_content=true&course_tag=free&show_price_history=true&show_provider_info=true&page_items=$perPageLoad&current_page=$currentPage&sort_by_creationdate=true&sort_order=desc';
    }else if(widget.sectionModel.value == "EventView"){
      dataString = 'skip_content=true&course_event_tag=event&show_price_history=true&show_provider_info=true&page_items=$perPageLoad&current_page=$currentPage&sort_by_creationdate=true&sort_order=desc';
    }
    Set<CourseModel> _moreCourses = Set<CourseModel>();
    _moreCourses = (await ApiRequest(context).getAllCourse(dataString)).toSet();
    lastLoad = _moreCourses.length;
    courses = courses.union(_moreCourses);
    setState(() {
      moreLoading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: appsMainColor),
        title: Text(widget.sectionModel.sectionName),
      ),
      body: loading
          ? Center(
        child: loader,
      ) :courses.length==0?
      Container(
        alignment: Alignment.center,
        child: Text("No Course Found!",style: TextStyle(color: Colors.black.withOpacity(.5),fontSize: 21,fontWeight: FontWeight.bold),),
      ):
      SingleChildScrollView(
          child: Column(
          children: [
            getVerticalCourse(),
            perPageLoad<=lastLoad?
            Container(
              margin: EdgeInsets.only(top: 10,bottom: 2),
              child: moreLoading?loaderMore:FlatButton(
                padding: EdgeInsets.only(bottom: 12,top: 12,left: 20,right: 20),
                color: appsMainColor,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onPressed: () {
                  currentPage++;
                  getMoreCourse();
                },
                child: Text("Load More",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      letterSpacing: .2
                  ),),
              ),
            ):Container()
          ],
        ),
      ),
    );
  }

  Widget getVerticalCourse() {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10),
      margin: EdgeInsets.only(top: 5),
      child: Column(
        children: courses.map((e) {
          return Container(
            padding: EdgeInsets.only(),
            child: FlatButton(
              padding: EdgeInsets.all(0),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => CourseDetails(
                          courseId: e.courseId,
                        )));
              },
              child: CourseCard(
                courseModel: e,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
