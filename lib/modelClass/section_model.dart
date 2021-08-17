import 'package:tutorlink/modelClass/course_model.dart';

class SectionModel {
  String sectionName;
  String keyName;
  String value;
  int sorting;
  Set<CourseModel> courses;
  SectionModel(
      {this.value, this.keyName, this.sectionName, this.sorting, this.courses});
}
