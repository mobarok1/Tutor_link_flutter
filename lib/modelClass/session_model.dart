class SessionModel{
  String courseId,uuId,name;
  DateTime startDate,endDate;
  int capacity,used;
  SessionModel({this.name,this.endDate,this.startDate,this.capacity,this.uuId,this.courseId,this.used});
  factory SessionModel.fromJSON(Map<String,dynamic> data){
    return SessionModel(
      name: data["name"],
      uuId:data["uuid"],
      capacity: data["capacity"],
      used: data["used"],
      startDate: DateTime.parse(data["start_date"]),
      endDate: DateTime.parse(data["end_date"]),
    );
  }
}