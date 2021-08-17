import 'package:tutorlink/extra/dateService.dart';
import 'package:tutorlink/modelClass/child_account.dart';

class CartListItem{
  String courseId,courseName,courseImage,tutorName,sessionId,sessionName;
  DateTime startDate,finishDate;
  List<ChildAccountModel> children;
  double price;

  CartListItem({this.courseId, this.courseName,this.courseImage, this.startDate,
      this.finishDate, this.tutorName, this.price,this.children,this.sessionId,this.sessionName});
  factory CartListItem.fromJSON(Map<String , dynamic> data){
    List<ChildAccountModel> children = [];
    for(var item in data["children"]){
      children.add(
          ChildAccountModel.fromJSON(item)
      );
    }
    return CartListItem(
      courseId: data["courseId"],
      courseName: data["courseName"],
      courseImage: data["courseImage"],
      startDate: DateFormatHelper.parseDate(data["startDate"]),
      finishDate: DateFormatHelper.parseDate(data["finishDate"]),
      tutorName: data["tutorName"],
      price: data["price"],
        children: children,
      sessionId:data["sessionId"],
      sessionName:data["sessionName"]
    );
  }
  Map<String,dynamic> toJSON(CartListItem item){
    List<Map<String,dynamic>> children = [];
    for(ChildAccountModel _ch in item.children){
      children.add(
          ChildAccountModel().toJSON(_ch)
      );
    }
    return {
      "courseId" : item.courseId,
      "courseName" : item.courseName,
      "courseImage" : item.courseImage,
      "startDate" : DateFormatHelper.fromDate(item.startDate),
      "finishDate" : DateFormatHelper.fromDate(item.finishDate),
      "tutorName" : item.tutorName,
      "price" : item.price,
      "sessionId":item.sessionId,
      "sessionName":item.sessionName,
      "children": children
    };
  }
}