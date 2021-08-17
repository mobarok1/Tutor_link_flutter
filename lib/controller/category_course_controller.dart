import 'package:get/get.dart';
import 'package:tutorlink/modelClass/course_model.dart';

class CategoryCourseController extends GetxController{
  RxSet courseList = <dynamic>{}.obs;
  void setCourseList(List<CourseModel> courses){
    courseList = RxSet(courses.toSet());
  }
  void pushCourseList(Set<CourseModel> courses){
    courseList.union(RxSet(courses));
  }
}