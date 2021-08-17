import 'package:tutorlink/modelClass/price_history.dart';

class CourseModel {
  String courseId, courseTitle, courseDescription;
  DateTime startDate, endDate;
  String tutorFirstName,
      tutorLastName,
      aboutTutor,
      tutorImageId,
      tutorProviderId;
  PriceModel price;
  double avgRating;
  DateTime creationDate;
  CourseProperties properties;
  List<CourseFiles> courseFiles;
  List<PriceModel> pricesHistory;
  String cityName;
  CourseModel(
      {this.pricesHistory,
      this.courseDescription,
      this.endDate,
      this.startDate,
      this.courseId,
      this.courseTitle,
        this.creationDate,
      this.tutorProviderId,
      this.price,
      this.avgRating,
      this.tutorFirstName,
      this.tutorLastName,
      this.aboutTutor,
      this.tutorImageId,
      this.properties,
      this.cityName,
      this.courseFiles});
  factory CourseModel.fromJSON(Map<String,dynamic> data){
    return CourseModel();
  }
}

class CourseProperties {
  String mode, classStart, classEnd, classType, classTime, featured, gender;
  String category, under16;
  List<String> courseType;
  String capacity,courseAdmissionStatus;
  CourseProperties(
      {this.category,
      this.classStart,
      this.classEnd,
      this.classTime,
      this.classType,
      this.mode,
      this.under16,
      this.courseType,
      this.gender,
        this.courseAdmissionStatus,
        this.capacity,
      this.featured});
}

class CourseFiles {
  String fileUid, keyName, courseId;
  CourseFiles({this.fileUid, this.keyName, this.courseId});
}
