class ChildAccountModel{
  String childUid,parentUid,firstName,middleName,lastName,gender,achievement;
  DateTime dateOfBirth;
  ChildAccountModel({this.gender,this.achievement,this.childUid,this.dateOfBirth,this.firstName,this.lastName,this.middleName,this.parentUid});
  factory ChildAccountModel.fromJSON(Map<String,dynamic> data){
    return ChildAccountModel(
      childUid: data["id"],
      firstName: data["name"]
    );
  }
  Map toJSON(ChildAccountModel childAccountModel){
    return <String,dynamic>{
      "id":childAccountModel.childUid,
      "name":childAccountModel.firstName,
    };
  }
}