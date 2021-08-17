import 'dart:convert';

import 'package:get/get.dart';
import 'package:tutorlink/api/api_client.dart';
import 'package:tutorlink/api/api_request.dart';
import 'package:tutorlink/api/api_response.dart';
import 'package:tutorlink/modelClass/my_details_model.dart';
import 'package:tutorlink/storage/SharedPrefManager.dart';

class UserController extends GetxController{
  UserDetailsModel userDetails;
  int loginType;
  String userSession,userId;
  @override
  void onInit() async {
    // TODO: implement onInit
    super.onInit();
    userId = await SharedPrefManager.getUserId();
    userSession = await SharedPrefManager.getToken();
    loginType = await SharedPrefManager.getType();
    update();
    if(userId != null){
      ApiResponse response = await ApiRequest(Get.context).getProfileData();
      if(response.responseCode == -1){
        userId = null;
        await SharedPrefManager.logOut();
      }else{
        var data = json.decode(response.response);
        userDetails = UserDetailsModel.fromJSON(data);
      }
    }
    update();
  }

  Future<bool> loginCheck() async{
    userId = await SharedPrefManager.getUserId();
    userSession = await SharedPrefManager.getToken();
    loginType = await SharedPrefManager.getType();
    return userId!=null;
  }
  updateUserInfo(UserDetailsModel userData){
    userDetails = userData;
    update();
  }
}