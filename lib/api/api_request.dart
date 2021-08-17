import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tutorlink/api/api_client.dart';
import 'package:tutorlink/controller/favorite_controller.dart';
import 'package:tutorlink/controller/user_controller.dart';
import 'package:tutorlink/extra/theme_data.dart';
import 'package:tutorlink/modelClass/address.dart';
import 'package:tutorlink/modelClass/category_model_type.dart';
import 'package:tutorlink/modelClass/child_account.dart';
import 'package:tutorlink/modelClass/city_suggestions_model.dart';
import 'package:tutorlink/modelClass/consumer_review_model.dart';
import 'package:tutorlink/modelClass/consumer_subscription_model.dart';
import 'package:tutorlink/modelClass/course_model.dart';
import 'package:tutorlink/modelClass/price_history.dart';
import 'package:tutorlink/modelClass/section_model.dart';
import 'package:tutorlink/modelClass/session_model.dart';
import 'package:tutorlink/modelClass/user_session_Id.dart';
import 'package:tutorlink/storage/SharedPrefManager.dart';
import 'api_response.dart';
import 'package:http/http.dart' as http;

class ApiRequest {
  BuildContext _buildContext;
  static String BASE_URL = ApiClient().baseURL;
  String userId;
  String getBaseUrl() {
    return BASE_URL;
  }
  ApiRequest(ctx){
    _buildContext = ctx;
    userId = Get.find<UserController>().userId;
  }
  Future<ApiResponse> postRegisterData(formData) async{
    HttpClientResponse response = await ApiClient.getInstance.post(formData, "/delivery/consumer/register");
    if (response == null) {
      showAlertDialog("Failed to Connect");
      return ApiResponse(responseCode: -1);
    }else{
      return ApiResponse(responseCode: response.statusCode);
    }
  }

  Future<ApiResponse> verifyCode(formData) async{
    HttpClientResponse response = await ApiClient.getInstance.post(formData, "/delivery/consumer/register/validation");
    if (response == null) {
      showAlertDialog("Failed to Connect");
      return ApiResponse(responseCode: -1);
    }else {
      return ApiResponse(responseCode: response.statusCode);
    }
  }

  Future<ApiResponse> resendVerifyCode(formData) async{
    HttpClientResponse response = await ApiClient.getInstance.post(formData, "/delivery/consumer/register/validation/resend");
    if (response == null) {
      showAlertDialog("Failed to Connect");
      return ApiResponse(responseCode: -1);
    }else {
      return ApiResponse(responseCode: response.statusCode);
    }
  }
  Future<ApiResponse> updateMyDetails(formData) async {
    if(userId == null){
      userId = await SharedPrefManager.getUserId();
    }
    HttpClientResponse response = await ApiClient.getInstance.patch(formData, "/delivery/consumer/$userId");
    if (response == null) {
      showAlertDialog("Failed to Connect");
      return ApiResponse(responseCode: -1);
    } else if(response.statusCode == 401){
      forceLogOut();
      return ApiResponse(responseCode: -1);
    } else {
      return ApiResponse(responseCode: response.statusCode);
    }
  }

  Future<ApiResponse<UserSessionId>> postLoginData(formData) async {
    HttpClientResponse response = await ApiClient.getInstance.post(formData, "/delivery/consumer/login");
    if (response == null) {
      showAlertDialog("Failed to Connect");
      return ApiResponse(responseCode: -1);
    }else {
      String body = await response.transform(utf8.decoder).join();
      print(body);
        if (response.statusCode == 200) {
          var myData = json.decode(body);
          var mySession;
          mySession = UserSessionId(session_id: myData['session_id'], uuid: myData['consumer_uuid']);
          return ApiResponse(response: mySession, responseCode: response.statusCode);
          }
        else {
          return ApiResponse<UserSessionId>(responseCode: response.statusCode);
          }
    }
  }

  Future<ApiResponse> getProfileData() async {
    if(userId == null){
      userId = await SharedPrefManager.getUserId();
    }
    HttpClientResponse response = await ApiClient.getInstance.get("/delivery/consumer/$userId");
    if (response == null) {
      showAlertDialog("Failed to Connect");
      return ApiResponse(responseCode: -1);
    }else if(response.statusCode == 401){
      Get.showSnackbar(GetBar(message: "Invalid login !",backgroundColor: Colors.red,duration: Duration(seconds: 2),));
      forceLogOut();
      return ApiResponse(responseCode: -1);
    } else{
      String body = await response.transform(utf8.decoder).join();
      return ApiResponse(responseCode: response.statusCode, response: body);
    }

  }

  Future<ApiResponse<String>> addNewAddress(SaveAddressData myAddress) async {
    var formData = jsonEncode({
      'name': myAddress.name,
      'type': myAddress.type,
      'properties': {
        'street_name': myAddress.properties.street_name,
        'street_number': myAddress.properties.street_number,
        'building': myAddress.properties.building,
        'zip': myAddress.properties.zip_code,
        'country': myAddress.properties.country,
        'city': myAddress.properties.city,
        'state': myAddress.properties.state,
      },
    });
    HttpClientResponse response = await ApiClient.getInstance.post(formData, "/delivery/address/");
    if (response == null) {
      showAlertDialog("Failed to Connect");
      return ApiResponse(responseCode: -1);
    }else if(response.statusCode == 401){
      forceLogOut();
      return ApiResponse(responseCode: -1);
    } else {
      String location = response.headers.value('location');
      if (response.statusCode == 201) {
        return ApiResponse<String>(
            response: location, responseCode: response.statusCode);
      } else {
        return ApiResponse<String>(
            response: "Error", responseCode: response.statusCode);
      }
    }
  }

  Future<ApiResponse<String>> updateAddress(SaveAddressData myAddress, String addressUuid) async {
    var formData = jsonEncode({
      'name': myAddress.name,
      'type': myAddress.type,
      'properties': {
        'street_name': myAddress.properties.street_name,
        'street_number': myAddress.properties.street_number,
        'building': myAddress.properties.building,
        'zip': myAddress.properties.zip_code,
        'country': myAddress.properties.country,
        'city': myAddress.properties.city,
        'state': myAddress.properties.state,
      },
    });
    HttpClientResponse response = await ApiClient.getInstance.patch(formData, "/delivery/address/$addressUuid");
    if (response == null) {
      showAlertDialog("Failed to Connect");
      return ApiResponse(responseCode: -1);
    }else if(response.statusCode == 401){
      forceLogOut();
      return ApiResponse(responseCode: -1);
    } else {
        return ApiResponse<String>(responseCode: response.statusCode);
    }
  }

  Future<ApiResponse<String>> approvedAddress(String location) async {
    if(userId == null){
      userId = await SharedPrefManager.getUserId();
    }
    HttpClientResponse response = await ApiClient.getInstance.postWithoutBody("/delivery/consumer/$userId/address/$location");
    if (response == null) {
      showAlertDialog("Failed to Connect");
      return ApiResponse(responseCode: -1);
    }else if(response.statusCode == 401){
      forceLogOut();
      return ApiResponse(responseCode: -1);
    } else {
      if (response.statusCode == 202) {
        return ApiResponse<String>(
            response: "Accepted", responseCode: response.statusCode);
      } else {
        return ApiResponse<String>(
            response: "Error", responseCode: response.statusCode);
      }
    }
  }

  Future<ApiResponse<List<Address>>> viewAddress() async {
    if(userId == null){
      userId = await SharedPrefManager.getUserId();
    }
    HttpClientResponse response = await ApiClient.getInstance.get("/delivery/consumer/$userId");
    if (response == null) {
      showAlertDialog("Failed to Connect");
      return ApiResponse<List<Address>>(
          responseCode: response.statusCode, response: List());
    }else if(response.statusCode == 401){
      forceLogOut();
      return ApiResponse<List<Address>>(
          responseCode: response.statusCode, response: List());
    } else {
      if (response.statusCode == 200) {
        String body = await response.transform(utf8.decoder).join();
        var myResponse = json.decode(body);
        if (myResponse['addresses'] == null) {
          return ApiResponse<List<Address>>(
              responseCode: response.statusCode, response: List());
        }
        List<Address> myDataList = [];
        for (var item in myResponse['addresses']) {
          myDataList.add(Address.fromData(item));
        }
        return ApiResponse<List<Address>>(
            response: myDataList, responseCode: response.statusCode);
      } else {
        return ApiResponse<List<Address>>(
            responseCode: response.statusCode, response: List());
      }
    }

  }

  Future<CourseModel> getCourseData(String courseID) async {
    HttpClientResponse serverResponse = await ApiClient.getInstance.get("/delivery/course/$courseID");
    if (serverResponse == null) {
      showAlertDialog("Failed to Connect");
      return null;
    }else {
      try {
        String body = await serverResponse.transform(utf8.decoder).join();
        dynamic response = jsonDecode(body);
        List<CourseFiles> files = [];
        List<PriceModel> prices = [];
        print(response["files"]);
        for (int i = 0; i < response["files"].length; i++) {
          files.add(CourseFiles(
            courseId: response["files"][i]["course_uuid"],
            fileUid: response["files"][i]["file_uuid"],
            keyName: response["files"][i]["key_name"],
          ));
        }
        for (int i = 0; i < response["price_history"].length; i++) {
          prices.add(PriceModel(
            priceUuid: response["price_history"][i]["price_uuid"],
            price: response["price_history"][i]["price"],
            vat: response["price_history"][i]["VAT"],
            serviceCharge: response["price_history"][i]["service_charge"],
            startDate: parseDate(response["properties"]["course_begin_date"]),
            endDate: parseDate(response["price_history"][i]["end_date"]),
          ));
        }
        List _type = response["properties"]["type"].toString().split(";");
        String city = "";
        if (response["addresses"] != null) {
          if (response["addresses"].length > 0) {
            try {
              city = response["addresses"][0]["properties"]["city"] ?? "";
            } catch (err) {
              city = "";
            }
          }
        }
        return CourseModel(
          courseTitle: response["short_name"],
          courseId: response["course_uuid"],
          courseDescription: response["description"],
          creationDate: parseDate(response["creation_date"]),
          price: response["price"] == null
              ? PriceModel(
            priceUuid: "-1",
            price: 0,
            vat: 0,
            serviceCharge: 0,
            startDate: DateTime.now(),
          )
              : PriceModel(
            priceUuid: response["price"]["price_uuid"],
            price: response["price"]["price"],
            vat: response["price"]["VAT"],
            serviceCharge: response["price"]["service_charge"],
            startDate: parseDate(response["price"]["start_date"]),
          ),
          avgRating: response["average_rate"],
          tutorFirstName: response["provider_info"]["first_name"],
          tutorLastName: response["provider_info"]["last_name"],
          aboutTutor: response["provider_info"]["about_me"],
          tutorImageId: response["provider_info"]["profile_image"],
          tutorProviderId: response["creator_provider_uuid"],
          startDate: parseDate(response["properties"]["course_begin_date"]),
          endDate: parseDate(response["properties"]["course_finish_date"]),
          pricesHistory: prices,
          cityName: city,
          properties: CourseProperties(
              mode: response["properties"]["mode"],
              classStart: response["properties"]["next"],
              classType: response["properties"]["class_type"],
              classTime: response["properties"]["class_time"],
              courseAdmissionStatus: response["properties"]["course_admission_status"],
              category: response["properties"]["category"],
              gender: response["properties"]["gender"],
              capacity: response["properties"]["capacity"],
              under16: response["properties"]["age_category"] == null
                  ? "adult"
                  : response["properties"]["age_category"],
              courseType: _type),
          courseFiles: files,
        );
      }catch(ex){
        showAlertDialog("UnKnown Error . Please Try Again later");
        print(ex);
        return null;
      }

    }
  }

  Future getHomePageConfig() async {
    HttpClientResponse serverResponse = await ApiClient.getInstance.get("/delivery/config/platform/WEB/1");
    if (serverResponse == null) {
      showAlertDialog("Failed to Connect");
      return null;
    }else{
      String body = await serverResponse.transform(utf8.decoder).join();
      var response = jsonDecode(body)["home"]["sections"];
      List _dataKeys = response.keys.toList();
      List _dataValue = response.values.toList();

      Set<SectionModel> homePageSections = Set<SectionModel>();

      for (int i = 0; i < _dataKeys.length; i++) {
        homePageSections.add(SectionModel(
          sectionName: _dataKeys[i],
          keyName: _dataValue[i].first["keyname"],
          value: _dataValue[i].first["values"],
          sorting: int.parse(_dataValue[i].first["sorting"]),
        ));
      }
      return homePageSections.toList();
    }
  }

  Future<List<CourseModel>> getAllCourse(String courseData) async {
    print(courseData);
    HttpClientResponse response = await ApiClient.getInstance.getPublic("/delivery/course?$courseData");
    if (response == null) {
      showAlertDialog("Failed to Connect");
      return [];
    }else {
      print(response.statusCode);
      if (response.statusCode == 204 || response.statusCode == 500) {
        return [];
      }
      String body = await response.transform(utf8.decoder).join();
      dynamic responseList = jsonDecode(body);
      List<CourseModel> allCourse = [];
      try {
        responseList.forEach((element) {
          List<CourseFiles> files = [];
          List<PriceModel> prices = [];
          for (int i = 0; i < element["files"].length; i++) {
            files.add(CourseFiles(
              courseId: element["files"][i]["course_uuid"],
              fileUid: element["files"][i]["file_uuid"],
              keyName: element["files"][i]["key_name"],
            ));
          }
          if (element["price_history"] != null)
            for (int i = 0; i < element["price_history"].length; i++) {
              prices.add(PriceModel(
                priceUuid: element["price_history"][i]["price_uuid"],
                price: element["price_history"][i]["price"],
                vat: element["price_history"][i]["price"],
                serviceCharge: element["price_history"][i]["service_charge"],
                startDate: parseDate(element["price_history"][i]["start_date"]),
                endDate: parseDate(element["price_history"][i]["end_date"]),
              ));
            }
          String _category = element["properties"]["category"];
          allCourse.add(CourseModel(
            courseTitle: element["short_name"],
            courseId: element["course_uuid"],
            courseDescription: element["description"],
            creationDate: parseDate(element["creation_date"]),
            price: element["price"] == null || element["price"]["price"] == null
                ? PriceModel(
              priceUuid: "-1",
              price: 0,
              vat: 0,
              serviceCharge: 0,
              startDate: DateTime.now(),
            )
                : PriceModel(
              priceUuid: element["price"]["price_uuid"],
              price: element["price"]["price"],
              vat: element["price"]["VAT"],
              serviceCharge: element["price"]["service_charge"],
              startDate: parseDate(element["price"]["start_date"]),
            ),
            avgRating: element["average_rate"],
            tutorFirstName: element["provider_info"]["first_name"],
            tutorLastName: element["provider_info"]["last_name"],
            tutorProviderId: element["creator_provider_uuid"],
            startDate: parseDate(element["properties"]["course_begin_date"]),
            endDate: parseDate(element["properties"]["course_finish_date"]),
            pricesHistory: prices,
            properties: CourseProperties(
              mode: element["properties"]["mode"],
              classStart: element["properties"]["next"],
              classType: element["properties"]["class_type"],
              classTime: element["properties"]["class_time"],
              courseAdmissionStatus: element["properties"]["course_admission_status"],
              under16: element["properties"]["age_category"] == null
                  ? "adult"
                  : element["properties"]["age_category"],
              category: _category,
            ),
            courseFiles: files,
          ));
        });
      }catch(ex){
        print(ex);
      }
      allCourse.sort((a,b)=>b.startDate.compareTo(a.startDate));
      return allCourse;
    }
  }

  Future<List<CategoryTypeModel>> getAllCategoryType() async {
    HttpClientResponse response = await ApiClient.getInstance.get("/delivery/config/course/property/category");
    if (response == null) {
      showAlertDialog("Failed to Connect");
      return null;
    }else{
      String body = await response.transform(utf8.decoder).join();
      if (response.statusCode == 204) {
        return List<CategoryTypeModel>();
      }
      dynamic responseList = jsonDecode(body);
      List<CategoryTypeModel> allCategory = List<CategoryTypeModel>();
      responseList.forEach((element) {
        allCategory.add(CategoryTypeModel.fromJSON(element));
      });
      return allCategory;
    }
  }

  Future<List<SubscriptionModel>> getConsumerEnrolledCourses() async {
    HttpClientResponse response = await ApiClient.getInstance.get("/delivery/consumer/course/subscribe?status=1");
    if (response == null) {
      showAlertDialog("Failed to Connect");
      return null;
    }else if(response.statusCode == 401){
      forceLogOut();
      return List<SubscriptionModel>();
    } else{
      print(response.statusCode);
      if (response.statusCode == 403) {
        await SharedPrefManager.logOut();
        userId = null;
        Navigator.popUntil(_buildContext, (route) => route.isFirst);
        return null;
      }
      String body = await response.transform(utf8.decoder).join();
      dynamic responseList = jsonDecode(body);
      List<SubscriptionModel> subscription = List<SubscriptionModel>();
      responseList.forEach((element) {
        subscription.add(SubscriptionModel(
          subscriptionId: element["subscription_id"],
          consumerId: element["consumer_uuid"],
          courseId: element["course_uuid"],
          childUid: element["child_uuid"]??"",
          sessionUid: element["session_uuid"]??"",
          price: element["price"],
          status: element["status"],
          startDate: parseDate(element["start_date"]),
        ));
      });
      return subscription;
    }
  }

  Future<ApiResponse<String>> uploadNewFile(
      File my_file, f_name, f_extension, String key_name, String scope) async {
    String userSession = await SharedPrefManager.getToken();
    String userId = await SharedPrefManager.getUserId();
    var saveAddressUrl = BASE_URL + '/delivery/consumer/$userId/file';

    var headers = {
      "ConsumerSession": userSession,
      "Content-Type": "multipart/form-data",
      "Accept": "application/json"
    };
    var req = http.MultipartRequest('POST', Uri.parse(saveAddressUrl));
    var time = DateTime.now().toString();
    req.headers.addAll(headers);
    req.files.add(http.MultipartFile(
        'file', my_file.readAsBytes().asStream(), my_file.lengthSync(),
        filename: f_name + time));
    req.fields.putIfAbsent(
        "request",
        () => jsonEncode({
              "key_name": key_name,
              "file_name": f_name + time,
              "scope": scope,
              "content_type": f_extension
            }));

    return req.send().then((value) {
      var location = value.headers['location'];
      print(value.statusCode);
      print(value);
      if (value.statusCode == 201) {
        return ApiResponse<String>(
            response: location, responseCode: value.statusCode);
      }else if(value.statusCode == 401){
        forceLogOut();
        return ApiResponse<String>(
            response: "Error", responseCode: value.statusCode);}
      else {
        return ApiResponse<String>(
            response: "Error", responseCode: value.statusCode);
      }
    });
  }

  Future<ApiResponse<String>> updateFile(File my_file, f_name, f_extension,
      String key_name, String scope, String fileId) async {
    String userSession = await SharedPrefManager.getToken();
    String userId = await SharedPrefManager.getUserId();
    var saveAddressUrl = BASE_URL + '/delivery/consumer/$userId/file/$fileId';
    var headers = {
      "ConsumerSession": userSession,
      "Content-Type": "multipart/form-data",
      "Accept": "application/json"
    };
    var req = http.MultipartRequest('PATCH', Uri.parse(saveAddressUrl));
    var time = DateTime.now().toString();
    req.headers.addAll(headers);
    req.files.add(http.MultipartFile(
        'file', my_file.readAsBytes().asStream(), my_file.lengthSync(),
        filename: f_name + time));
    req.fields.putIfAbsent(
        "request",
        () => jsonEncode({
              "key_name": key_name,
              "file_name": f_name + time,
              "scope": scope,
              "content_type": f_extension
            }));
    return req.send().then((value) {
      var location = value.headers['location'];
      if (value.statusCode == 201) {
        return ApiResponse<String>(
            response: location, responseCode: value.statusCode);
      }else if(value.statusCode == 401){
        forceLogOut();
        return ApiResponse<String>(
            response: "Error", responseCode: value.statusCode);}
      else {
        return ApiResponse<String>(
            response: "Error", responseCode: value.statusCode);
      }
    });
  }

  Future deleteFileData(String fileId) async {
    if(userId == null){
      userId = await SharedPrefManager.getUserId();
    }
    HttpClientResponse response = await ApiClient.getInstance.delete("/delivery/consumer/$userId/file/$fileId");
    if (response == null) {
      showAlertDialog("Failed to Connect");
      return null;
    }else if(response.statusCode == 401){
      forceLogOut();
      return ApiResponse<String>(
          response: "Error", responseCode: 401);}
    else{
      String body = await response.transform(utf8.decoder).join();
      return ApiResponse<String>(
          responseCode: response.statusCode, response: body);
    }
  }

  Future<ApiResponse<String>> enrollToCourse(String courseId) async {
    if(userId == null){
      userId = await SharedPrefManager.getUserId();
    }
    var formData = jsonEncode("");
    HttpClientResponse response = await ApiClient.getInstance.post(formData, "/delivery/course/$courseId/subscribe");
    if (response == null) {
      showAlertDialog("Failed to Connect");
      return ApiResponse(responseCode: -1);
    }else if(response.statusCode == 401){
      forceLogOut();
      return ApiResponse<String>(
          response: "Error : Failed to Enrolled",
          responseCode: response.statusCode);
    }else {
      if (response.statusCode == 201) {
        return ApiResponse<String>(
            response: "Successfully Enrolled", responseCode: response.statusCode);
      } else {
        return ApiResponse<String>(
            response: "Error : Failed to Enrolled",
            responseCode: response.statusCode);
      }
    }
  }

  Future<ApiResponse<String>> childEnrollToCourse(String courseId, String childUuid) async {
    var formData = jsonEncode({"child_uuid": childUuid});
    HttpClientResponse response = await ApiClient.getInstance.post(formData, "/delivery/course/$courseId/subscribe");
    if (response == null) {
      showAlertDialog("Failed to Connect");
      return ApiResponse(responseCode: -1);
    }else if(response.statusCode == 401){
      forceLogOut();
      return ApiResponse<String>(
          response: "Error : Failed to Enrolled",
          responseCode: response.statusCode);
    }else {
      if (response.statusCode == 201) {
        return ApiResponse<String>(
            response: "Successfully Enrolled", responseCode: response.statusCode);
      } else {
        return ApiResponse<String>(
            response: "Error : Failed to Enrolled",
            responseCode: response.statusCode);
      }
    }
  }

  Future<ApiResponse<String>> addToFavorite(String courseId) async {
    HttpClientResponse response = await ApiClient.getInstance.postWithoutBody("/delivery/course/$courseId/bookmark");
    if (response == null) {
      showAlertDialog("Failed to Connect");
      return ApiResponse(responseCode: -1);
    }else if(response.statusCode == 401){
      forceLogOut();
      return ApiResponse<String>(
          response: "Error : Failed to add",
          responseCode: response.statusCode);
    }else {
      String body = await response.transform(utf8.decoder).join();
      print(body);
      if (response.statusCode == 201) {
        return ApiResponse<String>(response: "Added", responseCode: response.statusCode);
      } else {
        return ApiResponse<String>(
            response: "Error : Failed to Add", responseCode: response.statusCode);
      }
    }
  }

  Future<ApiResponse<String>> deleteFavorite(String courseId) async {
    HttpClientResponse response = await ApiClient.getInstance.delete("/delivery/course/$courseId/bookmark");
    if (response == null) {
      showAlertDialog("Failed to Connect");
      return ApiResponse(responseCode: -1);
    }else if(response.statusCode == 401){
      forceLogOut();
      return ApiResponse<String>(
          response: "Error : Failed to delete",
          responseCode: response.statusCode);
    }else {
      if (response.statusCode == 202) {
        return ApiResponse<String>(response: "Deleted", responseCode: response.statusCode);
      } else {
        return ApiResponse<String>(
            response: "Error : Failed to delete",
            responseCode: response.statusCode);
      }
    }
  }

  Future<List<CourseModel>> getAllFavorite() async {
    HttpClientResponse response = await ApiClient.getInstance.get("/delivery/consumer/bookmark");
    if (response == null) {
      showAlertDialog("Failed to Connect");
      return List<CourseModel>();
    }else if(response.statusCode == 401){
      forceLogOut();
      return List();
    }else {
      String body = await response.transform(utf8.decoder).join();
      print(body);
      if (response.statusCode == 200){
        dynamic responseList = jsonDecode(body);
        List<CourseModel> allCourse = List<CourseModel>();
        try {
          responseList.forEach((element) {
            List<CourseFiles> files = List<CourseFiles>();
            List<PriceModel> prices = List<PriceModel>();
            for (int i = 0; i < element["files"].length; i++) {
              files.add(CourseFiles(
                courseId: element["files"][i]["course_uuid"],
                fileUid: element["files"][i]["file_uuid"],
                keyName: element["files"][i]["key_name"],
              ));
            }
            if (element["price_history"] != null)
              for (int i = 0; i < element["price_history"].length; i++) {
                prices.add(PriceModel(
                  priceUuid: element["price_history"][i]["price_uuid"],
                  price: element["price_history"][i]["price"],
                  vat: element["price_history"][i]["price"],
                  serviceCharge: element["price_history"][i]["service_charge"],
                  startDate: parseDate(element["price_history"][i]["start_date"]),
                  endDate: parseDate(element["price_history"][i]["end_date"]),
                ));
              }
            String _category = element["properties"]["category"];
            allCourse.add(CourseModel(
              courseTitle: element["short_name"],
              courseId: element["course_uuid"],
              courseDescription: element["description"],
              creationDate: parseDate(element["creation_date"]),
              price: element["price"] == null ||
                  element["price"]["price"] == null
                  ? PriceModel(
                priceUuid: "-1",
                price: 0,
                vat: 0,
                serviceCharge: 0,
                startDate: DateTime.now(),
              )
                  : PriceModel(
                priceUuid: element["price"]["price_uuid"],
                price: element["price"]["price"],
                vat: element["price"]["VAT"],
                serviceCharge: element["price"]["service_charge"],
                startDate: parseDate(element["price"]["start_date"]),
              ),
              avgRating: element["average_rate"],
              startDate: parseDate(element["properties"]["course_begin_date"]),
              endDate: parseDate(element["properties"]["course_finish_date"]),
              pricesHistory: prices,
              properties: CourseProperties(
                mode: element["properties"]["mode"],
                classStart: element["properties"]["next"],
                classType: element["properties"]["class_type"],
                classTime: element["properties"]["class_time"],
                under16: element["properties"]["age_category"] == null
                    ? "adult"
                    : element["properties"]["age_category"],
                category: _category,
              ),
              courseFiles: files,
            ));
          });
        }catch(ex){}
        return allCourse;
      } else {
        return List<CourseModel>();
      }
    }
  }

  Future<bool> rateTheCourse(String courseId, double rate, String comment) async {
    var formData = jsonEncode({"consumer_uuid": userId, "rate": rate, "comment": comment});
    HttpClientResponse response = await ApiClient.getInstance.post(formData,"/delivery/course/$courseId/rate");
    if (response == null) {
      showAlertDialog("Failed to Connect");
      return false;
    }else if(response.statusCode == 401){
      forceLogOut();
      return false;
    }else {
      if (response.statusCode == 202) {
        return true;
      } else {
        return false;
      }
    }
  }
  Future<bool> checkSubscribe(String courseId) async {
    HttpClientResponse response = await ApiClient.getInstance.get("/delivery/course/$courseId/subscribe/check");
    if (response == null) {
      showAlertDialog("Failed to Connect");
      return false;
    }else if(response.statusCode == 401){
      forceLogOut();
      return false;
    }else {
      if (response.statusCode == 200) {
        return true;
      } else
        return false;
    }
  }

  Future<bool> checkRating(String courseId) async {
    HttpClientResponse response = await ApiClient.getInstance.get("/delivery/consumer/check/course/$courseId/rate");
    if (response == null) {
      showAlertDialog("Failed to Connect");
      return false;
    }else if(response.statusCode == 401){
      forceLogOut();
      return false;
    }else {
      if (response.statusCode == 200) {
        return true;
      } else
        return false;
    }
  }

  Future getAllReview(String courseId) async {
    HttpClientResponse response = await ApiClient.getInstance.get("/delivery/course/$courseId/rate");
    if (response == null) {
      showAlertDialog("Failed to Connect");
      return List<ConsumerReviewModel>();
    }else {
      if (response.statusCode == 204) {
        return List<ConsumerReviewModel>();
      }
      String body = await response.transform(utf8.decoder).join();

      var data = jsonDecode(body);
      List<ConsumerReviewModel> reviews = List<ConsumerReviewModel>();
      for (int i = 0; i < data.length; i++) {
        DateTime date = DateTime.parse(data[i]["creation_date"]);
        print(data[i]);
        reviews.add(ConsumerReviewModel(
          consumerId: data[i]["consumer_uuid"],
          comment: data[i]["comment"],
          rating: data[i]["rate"],
          profileImageId: data[i]["consumer_info"]["profile_image"],
          firstName: data[i]["consumer_info"]["first_name"],
          lastName: data[i]["consumer_info"]["last_name"],
          dateTime: DateFormat.yMEd().format(date),
        ));
      }
      return reviews;
    }
  }

  Future<List<ChildAccountModel>> getAllChild() async {
    if(userId == null){
      userId = await SharedPrefManager.getUserId();
    }
    HttpClientResponse response = await ApiClient.getInstance.get("/delivery/consumer/$userId/child");
    if (response == null) {
      showAlertDialog("Failed to Connect");
      return List<ChildAccountModel>();
    }else if(response.statusCode == 401){
      forceLogOut();
      return List<ChildAccountModel>();
    }else {
      String body = await response.transform(utf8.decoder).join();
      var data = jsonDecode(body);
      List<ChildAccountModel> child = List<ChildAccountModel>();
      for (int i = 0; i < data.length; i++) {
        child.add(ChildAccountModel(
          childUid: data[i]["child_uuid"],
          firstName: data[i]["first_name"],
          middleName: data[i]["middle_name"],
          lastName: data[i]["last_name"],
          gender: data[i]["gender"],
          dateOfBirth: parseDate(data[i]["date_of_birth"]),
          achievement: data[i]["achivement"],
        ));
      }
      return child;

    }

  }

  Future getChildInfo(String childId) async {
    if(userId == null){
      userId = await SharedPrefManager.getUserId();
    }
    HttpClientResponse response = await ApiClient.getInstance.get("/delivery/consumer/$userId/child/$childId");
    if (response == null) {
      showAlertDialog("Failed to Connect");
      return List<ChildAccountModel>();
    }else if(response.statusCode == 401){
      forceLogOut();
      return List<ChildAccountModel>();
    }else {
      String body = await response.transform(utf8.decoder).join();
      if(response.statusCode == 404){
        return ChildAccountModel(
          childUid: "1",
          firstName: "Child Deleted",
          middleName: "",
          lastName: "",
          gender: "",
          dateOfBirth: parseDate(null),
        );
      }
      var data = jsonDecode(body);
      return ChildAccountModel(
          childUid: data["child_uuid"],
          firstName: data["first_name"],
          middleName: data["middle_name"],
          lastName: data["last_name"],
          gender: data["gender"],
          dateOfBirth: parseDate(data["date_of_birth"]),
          achievement: data["achivement"]
      );

    }
  }

  Future<ApiResponse<String>> addNewChild(ChildAccountModel myChild) async {
    if(userId == null){
      userId = await SharedPrefManager.getUserId();
    }
    var formBody = jsonEncode(
      {
        'first_name': myChild.firstName,
        'middle_name': myChild.middleName,
        'last_name': myChild.lastName,
        'gender': myChild.gender,
        'date_of_birth': myChild.dateOfBirth.toString().substring(0,10),
        'achivement':myChild.achievement
      },
    );
    HttpClientResponse response = await ApiClient.getInstance.post(formBody,"/delivery/consumer/$userId/child");
    if (response == null) {
      showAlertDialog("Failed to Connect");
      return ApiResponse<String>(
          response: "Error", responseCode: response.statusCode);
    }else if(response.statusCode == 401){
      forceLogOut();
      return ApiResponse<String>(
          response: "failed",
          responseCode: response.statusCode);
    }else {
      String location = response.headers.value('location');
      if (response.statusCode == 201) {
        return ApiResponse<String>(
            response: location, responseCode: response.statusCode);
      } else {
        return ApiResponse<String>(
            response: "Error", responseCode: response.statusCode);
      }
    }

  }

  Future<bool> editChild(ChildAccountModel myChild) async {
    if(userId == null){
      userId = await SharedPrefManager.getUserId();
    }
    var formBody = jsonEncode(
      {
        'first_name': myChild.firstName,
        'middle_name': myChild.middleName,
        'last_name': myChild.lastName,
        'gender': myChild.gender,
        'date_of_birth': myChild.dateOfBirth,
        'achivement': myChild.achievement,
      },
    );
    HttpClientResponse response = await ApiClient.getInstance.patch(formBody,"/delivery/consumer/$userId/child/${myChild.childUid}");
    if (response == null) {
      showAlertDialog("Failed to Connect");
      return false;
    }else if(response.statusCode == 401){
      forceLogOut();
      return false;
    }else {
      if (response.statusCode == 202) {
           return true;
      } else {
          return false;
      }

    }

  }

  Future<bool> deleteChild(childUuid) async {
    if(userId == null){
      userId = await SharedPrefManager.getUserId();
    }
    HttpClientResponse response = await ApiClient.getInstance.delete("/delivery/consumer/$userId/child/$childUuid");
    if (response == null) {
      showAlertDialog("Failed to Connect");
      return false;
    }else if(response.statusCode == 401){
      forceLogOut();
      return false;
    }else {
      if (response.statusCode == 202) {
        return true;
      } else {
        return false;
      }

    }
  }

  Future<ApiResponse<String>> payment(formBody) async {
    if(userId == null){
      userId = await SharedPrefManager.getUserId();
    }
    HttpClientResponse response = await ApiClient.getInstance.post(formBody,"/delivery/payment");
    if (response == null) {
      showAlertDialog("Failed to Connect");
      return ApiResponse<String>(
          response: "failed", responseCode: response.statusCode);
    }else if(response.statusCode == 401){
      forceLogOut();
      return ApiResponse<String>(
          response: "failed",
          responseCode: response.statusCode);
    }else {
      String location = response.headers.value('location');
      if (response.statusCode == 201) {
        return ApiResponse<String>(
            response: location, responseCode: response.statusCode);
      } else {
        return ApiResponse<String>(
            response: "Error", responseCode: response.statusCode);
      }
    }
  }

  Future<bool> paymentSubscription(String courseUid, String paymentId,String session) async {
    HttpClientResponse response = await ApiClient.getInstance.post(jsonEncode(""),"/delivery/course/$courseUid/subscribe?payment_reference=$paymentId&session_uuid=$session");
    if (response == null) {
      showAlertDialog("Failed to Connect");
      return false;
    }else if(response.statusCode == 401){
      forceLogOut();
      return false;
    }else {
      if (response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    }

  }

  Future<bool> childPaymentSubscription(
      String courseUid, String paymentId, String childUuid,String session) async {
    var formData = jsonEncode({"child_uuid": childUuid});
    HttpClientResponse response = await ApiClient.getInstance.post(formData,"/delivery/course/$courseUid/subscribe?payment_reference=$paymentId&session_uuid=$session");
    if (response == null) {
      showAlertDialog("Failed to Connect");
      return false;
    }else if(response.statusCode == 401){
      forceLogOut();
      return false;
    }else {
      if (response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    }
  }

  Future<bool> sendPasswordResetCode(String userID) async {
    var formData = jsonEncode({"username": userID});
    HttpClientResponse response = await ApiClient.getInstance.post(formData,"/delivery/consumer/password/reset/resend/code");
    if (response == null) {
      showAlertDialog("Failed to Connect");
      return false;
    }else {
      if (response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    }
  }

  Future<bool> changePassword(
      String userID, String password, String code) async {
    var formData =
    jsonEncode({"username": userID, "password": password, "code": code});
    HttpClientResponse response = await ApiClient.getInstance.post(formData,"/delivery/consumer/password/reset");
    if (response == null) {
      showAlertDialog("Failed to Connect");
      return false;
    }else if(response.statusCode == 401){
      forceLogOut();
      return false;
    }else {
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    }
  }
  Future getCitySuggestions(String cityName) async {
    HttpClientResponse response = await ApiClient.getInstance.get("/delivery/config/city?q=$cityName");
    if (response == null) {
      print(response);
      showAlertDialog("Failed to Connect");
      return false;
    }else {
      String body = await response.transform(utf8.decoder).join();
      var data = jsonDecode(body);
      List<CitySuggestionsModel> cityNames = List<CitySuggestionsModel>();
      data.forEach((e){
        cityNames.add(CitySuggestionsModel(
            name: e["name"],
            country: e["county"]
        ));
      });
      return cityNames;
    }
  }
  Future<List<SessionModel>> getCourseSession(String courseId) async {
    HttpClientResponse response = await ApiClient.getInstance.get("/delivery/course/$courseId/session");
    if (response == null) {
      showAlertDialog("Failed to Connect");
      return [];
    } else{
      List<SessionModel> items = [];
      if(response.statusCode == 200){
        String body = await response.transform(utf8.decoder).join();
        var bodyData = jsonDecode(body);
        for(var _item in bodyData){
          int used = 0;
          int capacity = 0;
          capacity = _item["capacity"]??0;
          used = _item["used"]??0;
          if((capacity-used) >0)
            items.add(SessionModel.fromJSON(_item));
        }
      }
      return items;
    }

  }
  static DateTime parseDate(String str) {
    if (str == null) {
      return DateTime.parse("2000-01-01");
    }
    try{
      return DateTime.parse(str);
    }catch(e){
      return DateTime.parse("2000-01-01");
    }

  }
  showAlertDialog(msg,{VoidCallback retry}) {
    AlertDialog alert = AlertDialog(
      content: Text(msg),
      actions: <Widget>[
        retry != null?FlatButton(
          child: Text("Try Again"),
          onPressed: () {
            Navigator.pop(_buildContext);
            retry();
          },
        ):Container(),
        FlatButton(
          child: Text("Ok"),
          onPressed: () {
            Navigator.pop(_buildContext);
          },
        )
      ],
    );
    showDialog(
      context: _buildContext,
      builder: (ctx) {
        return alert;
      },
    );
  }
  forceLogOut() async{
    await SharedPrefManager.logOut();
    userId = null;
    Navigator.popUntil(_buildContext, (route) => route.isFirst);
  }
}
