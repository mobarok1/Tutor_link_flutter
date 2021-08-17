import 'package:flutter/foundation.dart';
import 'package:tutorlink/modelClass/child_account.dart';
import 'package:tutorlink/modelClass/course_model.dart';

class SubscriptionModel {
  String consumerId, courseId, consumerMail, consumerPhone, consumerFirstName, childUid, consumerLastName;
  DateTime startDate;
  int status, subscriptionId;
  double price;
  CourseModel courseDetails;
  ChildAccountModel child;
  String sessionUid,sessionName;
  SubscriptionModel(
      {this.courseDetails,
      this.courseId,
      this.price,
      this.consumerId,
      this.startDate,
      this.status,
      this.subscriptionId,
      this.consumerFirstName,
      this.consumerLastName,
      this.consumerMail,
        this.child,
        this.childUid,
        this.sessionUid,
        this.sessionName,
      this.consumerPhone});
}
