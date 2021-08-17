import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorlink/controller/cart_controller.dart';
import 'package:tutorlink/modelClass/cart_item.dart';

class SharedPrefManager {
  static void setToken(String token) async {
    SharedPreferences myData = await SharedPreferences.getInstance();
    myData.setString('token', token);
  }

  static Future<String> getToken() async {
    SharedPreferences myData = await SharedPreferences.getInstance();
    String token = myData.getString('token');
    return token;
  }

  static void setEmail(String token) async {
    SharedPreferences myData = await SharedPreferences.getInstance();
    myData.setString('email', token);
  }

  static Future<String> getEmail() async {
    SharedPreferences myData = await SharedPreferences.getInstance();
    String token = myData.getString('email');
    return token;
  }

  static void setUserId(String userId) async {
    SharedPreferences myData = await SharedPreferences.getInstance();
    myData.setString('userId', userId);
  }

  static Future<String> getUserId() async {
    SharedPreferences myData = await SharedPreferences.getInstance();
    String userId = myData.getString('userId');
    return userId;
  }

  static void setType(int type) async {
    SharedPreferences myData = await SharedPreferences.getInstance();
    myData.setInt('type', type);
  }

  static Future<int> getType() async {
    SharedPreferences myData = await SharedPreferences.getInstance();
    int type = myData.getInt('type');
    return type;
  }

  static Future<bool> logOut() async {
    SharedPreferences myData = await SharedPreferences.getInstance();
    myData.clear();
    return myData.clear();
  }
  static Future saveResendCodeInfo(email) async {
    SharedPreferences myData = await SharedPreferences.getInstance();
    myData.setString("__email", email);
  }
  static Future clearResendCodeInfo() async {
    SharedPreferences myData = await SharedPreferences.getInstance();
    myData.setString("__email", null);
  }
  static Future saveString(key,value) async {
    SharedPreferences myData = await SharedPreferences.getInstance();
    myData.setString(key, value);
  }
  static Future<String> getString(_key) async {
    SharedPreferences myData = await SharedPreferences.getInstance();
    return myData.getString(_key);
  }
  static Future saveInt(key,int value) async {
    SharedPreferences myData = await SharedPreferences.getInstance();
    myData.setInt(key, value);
  }
  static Future<int> getInt(_key) async {
    SharedPreferences myData = await SharedPreferences.getInstance();
    return myData.getInt(_key);
  }
  static Future addToCart(CartListItem item) async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    List<String> allItems = storage.getStringList("cartLIst");
    allItems = allItems??List();
    allItems.add( jsonEncode(CartListItem().toJSON(item)));
    storage.setStringList("cartLIst", allItems);
  }
  static Future<List<CartListItem>> getCartData() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    List<String> allItems = storage.getStringList("cartLIst");
   // storage.setStringList("cartLIst",null);
    allItems = allItems??List();
    List<CartListItem> data = List<CartListItem>();
    allItems.forEach((element) {
      data.add(CartListItem.fromJSON(jsonDecode(element)));
    });
    return data;
  }
  static Future removeFromCart(String courseId) async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    List<String> allItems = storage.getStringList("cartLIst");
    allItems = allItems??List();
    allItems.removeWhere((element) => element.contains(courseId));
    storage.setStringList("cartLIst", allItems);

  }
  static Future<bool> checkCartExist(String courseId) async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    List<String> allItems = storage.getStringList("cartLIst");
    allItems = allItems??List();
    bool contain = false;
    allItems.forEach((element) {
      if(element.contains(courseId)){
        contain = true;
      }
    });
    return contain;
  }
  static Future clearCart() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    storage.setStringList("cartLIst",null);
  }

}
