import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toast/toast.dart';
import 'package:tutorlink/api/api_request.dart';
import 'package:tutorlink/api/api_response.dart';
import 'package:tutorlink/modelClass/cart_item.dart';
import 'package:tutorlink/modelClass/course_model.dart';
import 'package:tutorlink/widgets/loader.dart';

class FavoriteController extends GetxController{
  RxInt count = RxInt(0);
  RxList<dynamic> items = [].obs;

  getFavoriteCourses() async {
    ProgressLoader.show();
    items = RxList.from(await ApiRequest(Get.context).getAllFavorite());
    count.value = items.length;
    update();
    ProgressLoader.close();
  }
  removeAfterPurchase(List<CartListItem> cartItems) async{
    ProgressLoader.show();
    List<String> removable = [];
    for(var _d in cartItems){
       items.toList().forEach((element) {
        if(_d.courseId == element.courseId){
          removable.add(_d.courseId);
        }
       });
    }
    for(var _r in removable){
      await ApiRequest(Get.context).deleteFavorite(_r);
      items.removeWhere((element) => element.courseId == _r);
    }
    count.value = items.length;
    update();
    ProgressLoader.close();
  }
  removeFromFavorite(courseId) async {
    ProgressLoader.show();
    ApiResponse response = await ApiRequest(Get.context).deleteFavorite(courseId);
    ProgressLoader.close();
    if (response.responseCode == 202) {
      Get.showSnackbar(
          GetBar(
            duration: Duration(seconds: 3),
            icon: Icon(Icons.done_all,color: Colors.white,),
            backgroundColor: Colors.green,
            messageText: Text("Removed from favorites",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
          )
      );
      items.removeWhere((element) => element.courseId == courseId);
      count.value = items.length;
      update();
    } else {
      Get.showSnackbar(
          GetBar(
            duration: Duration(seconds: 3),
            icon: Icon(Icons.error,color: Colors.white,),
            snackStyle: SnackStyle.FLOATING,
            backgroundColor: Colors.red,
            messageText: Text("Failed to remove",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
          )
      );
    }
  }
  addToFavorite(CourseModel courseModel) async{
    ProgressLoader.show();
    // adding to favourite under the userId
    ApiResponse response = await ApiRequest(Get.context).addToFavorite(courseModel.courseId);
    ProgressLoader.close();
    if (response.responseCode == 201) {
      items.add(courseModel);
      count.value = items.length;
      update();
      //Successfully Added
      Get.showSnackbar(
          GetBar(
            duration: Duration(seconds: 3),
            icon: Icon(Icons.done_outline_outlined,color: Colors.white,),
            backgroundColor: Colors.green,
            messageText: Text("Added to your favorites!",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
          )
      );
    } else if (response.responseCode == 500) {
      //Already Added
      Get.showSnackbar(
          GetBar(
            duration: Duration(seconds: 3),
            icon: Icon(Icons.error,color: Colors.white,),
            backgroundColor: Colors.green,
            messageText: Text("Already in your favorite list.To Remove from favorite, go to your Favorites page",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,),maxLines: 5,),
          )
      );
    } else {
      //Failed to Add
      Get.showSnackbar(
          GetBar(
            duration: Duration(seconds: 3),
            icon: Icon(Icons.error,color: Colors.white,),
            backgroundColor: Colors.red,
            messageText: Text("Failed to add to your favorites",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
          )
      );
    }

  }
  logOut(){
    count = 0.obs;
    items = [].obs;
    update();
  }
  @override
  void onInit() async{
    // TODO: implement onInit
    super.onInit();
    items = RxList.from(await ApiRequest(Get.context).getAllFavorite());
    count.value = items.length;
    update();
  }
}