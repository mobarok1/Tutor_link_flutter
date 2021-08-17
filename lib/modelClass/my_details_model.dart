import 'package:tutorlink/modelClass/address.dart';

class UserDetailsModel{
    String consumerUuid,email,username;
    ProfileModel profile;
    List<Address> addresses;
    UserDetailsModel(
        {this.consumerUuid,
            this.email,
            this.username,
            this.profile,
            this.addresses,
        });
    factory UserDetailsModel.fromJSON(Map<String,dynamic> data){
      List<Address> _address = [];
      if(data["addresses"] != null)
      data["addresses"].forEach((e){
        _address.add(Address.fromData(e));
      });
      return UserDetailsModel(
        consumerUuid: data["consumer_uuid"],
        email: data["email"],
        username: data["username"],
        profile: ProfileModel.fromJSON(data["profile"]),
        addresses: _address
      );
    }

}
class ProfileModel{
  String firstName, lastName, phoneNumber;
  Gender gender;
  ProfileModel({this.firstName,this.gender,this.lastName,this.phoneNumber});
  factory ProfileModel.fromJSON(Map<String,dynamic> data){
    return ProfileModel(
      firstName: data["first_name"],
      lastName: data["last_name"],
      phoneNumber: data["phone"],
      gender: data["gender"]=="F"?Gender.female:Gender.male,
    );
  }
}
enum Gender{
  male,
  female,
  both
}
