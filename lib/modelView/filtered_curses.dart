import 'package:flutter/material.dart';
import 'package:tutorlink/Pages/course_details.dart';
import 'package:tutorlink/api/api_request.dart';
import 'package:tutorlink/extra/theme_data.dart';
import 'package:tutorlink/modelClass/course_model.dart';
import 'package:tutorlink/modelClass/filter_model_class.dart';
import 'package:tutorlink/widgets/course_card.dart';

class FilteredCourses extends StatefulWidget {
  FilterModelClass filterModel;
  bool searching = false;
  String searchText;
  Set<CourseModel> filteredFeaturedCourse;
  Set<CourseModel> filteredCourseList;
  FilteredCourses({@required this.filteredCourseList,@required this.filterModel,@required this.searching,@required this.searchText,@required this.filteredFeaturedCourse});
  @override
  _FilteredCoursesState createState() => _FilteredCoursesState();
}

class _FilteredCoursesState extends State<FilteredCourses> {
  int filterCurrentPage = 0;
  int filterLastLoaded = 5;
  int filterPerPageLoad = 5;
  bool loading = false, loadingMore= false;
  FilterModelClass filterModel;

  getFilterPageMoreData() async {
    setState(() {
      loadingMore = true;
    });
    String str;
    for (int i = 0; i < filterModel.categoryNames.length; i++) {
      if (str == null) {
        str = filterModel.categoryNames.elementAt(i);
      } else {
        str = str + ";" + filterModel.categoryNames.elementAt(i);
      }
    }
    String sortByString = getSortByDataString();

    var dataString = 'skip_content=true&age_category=${filterModel.age == 0 ? "under_16" : filterModel.age == 1 ? "over_16" : ""}${widget.searching ? "&course_name=${widget.searchText}" : ""}&${filterModel.categoryNames.length != 0 ? "type=$str" : ""}&$sortByString&show_price_history=true&show_provider_info=true&page_items=$filterPerPageLoad&current_page=$filterCurrentPage';
    Set<CourseModel> _courses = (await ApiRequest(context).getAllCourse(dataString)).toSet();
    filterLastLoaded = _courses.length;
    widget.filteredCourseList = widget.filteredCourseList.union(_courses);
    setState(() {
      loadingMore = false;
    });
  }
  String getSortByDataString() {
    String sortByString = "";
    String sortOrder = "desc";
    if (filterModel.sortBy == 0) {
      sortOrder = "asc";
      sortByString = "sort_by_price=true&sort_order=$sortOrder";
    } else if (filterModel.sortBy == 1) {
      sortOrder = "desc";
      sortByString = "sort_by_price=true&sort_order=$sortOrder";
    } else if (filterModel.sortBy == 2) {
      sortOrder = "desc";
      sortByString = "sort_by_rate=true&sort_order=$sortOrder";
    } else if (filterModel.sortBy == 3) {
      sortOrder = "desc";
      sortByString = "sort_by_creationdate=true&sort_order=$sortOrder";
    } else if (filterModel.sortBy == 4) {
      sortOrder = "desc";
      sortByString = "sort_by_startdate=true&sort_order=$sortOrder";
    }
    return sortByString;
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    filterLastLoaded = widget.filteredCourseList.length;
    filterModel = widget.filterModel;
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        reverse: false,
        children: [
          getFilterFeaturedCourse(widget.filteredFeaturedCourse),
          widget.filteredCourseList.length == 0
              ? Container(
            margin: EdgeInsets.only(top: 0),
            alignment: Alignment.center,
            child: Text(
              "No Course Available",
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.black.withOpacity(.4),
                  fontWeight: FontWeight.bold),
            ),
          )
              : Container(
            padding: EdgeInsets.only(left: 10, right: 10),
            margin: EdgeInsets.only(top: 5),
            child: Column(
                children: [
                  Column(
                      children: widget.filteredCourseList.map((e){
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
                  filterLastLoaded >= filterPerPageLoad
                      ? Container(
                    margin: EdgeInsets.only(top: 10, bottom: 10),
                    child: loadingMore
                        ? loaderMore
                        : FlatButton(
                      padding: EdgeInsets.only(
                          bottom: 12, top: 12, left: 20, right: 20),
                      color: appsMainColor,
                      materialTapTargetSize:
                      MaterialTapTargetSize.shrinkWrap,
                      onPressed: () {
                        filterCurrentPage++;
                        getFilterPageMoreData();
                      },
                      child: Text(
                        "Load More",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            letterSpacing: .2),
                      ),
                    ),
                  )
                      : Container()
                ]),
          ),
        ],
      ),
    );
  }
  Widget getFilterFeaturedCourse(Set<CourseModel> courses) {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10),
      margin: EdgeInsets.only(top: 5),
      child: Column(
        children: [
          courses.length == 0
              ? Container()
              : Container(
            height: 280,
            padding: EdgeInsets.only(left: 5),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: courses.map((e) {
                return Container(
                  height: 250,
                  width: 280,
                  padding: EdgeInsets.only(),
                  child: FlatButton(
                      padding: EdgeInsets.all(0),
                      onPressed: () {
                        Navigator.push(
                            context,MaterialPageRoute(builder: (BuildContext context) =>CourseDetails(courseId: e.courseId)));
                      },
                      child: CourseCardFeatured(
                        courseModel: e,
                      )
                  ),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }

}
