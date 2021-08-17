import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:tutorlink/controller/user_controller.dart';
import 'package:tutorlink/extra/theme_data.dart';
import 'package:tutorlink/storage/SharedPrefManager.dart';

class ApiClient{
    // final baseURL = "https://api.ustadhlink.com:8443";
  final baseURL = "https://labapi.yuma-technology.co.uk:8443";
  static ApiClient getInstance = ApiClient();
  HttpClient getHttpClient() {
    HttpClient webClient = HttpClient();
    webClient.connectionTimeout = Duration(seconds: 15);
    webClient.idleTimeout = Duration(seconds: 50);
    webClient.userAgent ="FlutterConsumerApps";
    webClient.badCertificateCallback =
    ((X509Certificate cert, String host, int port) => true);
    return webClient;
  }
  post(formData, urlPath) async {
    try {
      HttpClientRequest request =
      await getHttpClient().postUrl(Uri.parse(baseURL + urlPath));
      request.headers.set('content-type', 'application/json');
      request.headers.set('Accept', 'application/json');
      request.headers.set('ConsumerSession', Get.find<UserController>().userSession);
      request.add(utf8.encode(formData));
      return await request.close();
    } catch (e) {
      return null;
    }
  }

  get(urlPath) async {
    try {
      HttpClientRequest request = await getHttpClient().getUrl(Uri.parse(baseURL + urlPath));
      request.headers.set('content-type', 'application/json');
      request.headers.set('ConsumerSession', Get.find<UserController>().userSession);
      return await request.close();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
  postWithoutBody(urlPath) async {
    try {
      HttpClientRequest request =
      await getHttpClient().postUrl(Uri.parse(baseURL + urlPath));
      request.headers.set('content-type', 'application/json');
      request.headers.set('Accept', 'application/json');
      request.headers.set('ConsumerSession', Get.find<UserController>().userSession);
      return await request.close();
    } catch (e) {
      return null;
    }
  }
  getPublic(urlPath) async {
    try {
      HttpClientRequest request = await getHttpClient().getUrl(Uri.parse(baseURL + urlPath));
      request.headers.set('content-type', 'application/json');
      return await request.close();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
  patch(formData,urlPath) async {
    try {
      HttpClientRequest request =
      await getHttpClient().patchUrl(Uri.parse(baseURL + urlPath));
      request.headers.set('content-type', 'application/json');
      request.headers.set('ConsumerSession', Get.find<UserController>().userSession);
      request.add(utf8.encode(formData));
      return await request.close();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
  delete(urlPath) async {
    try {
      HttpClientRequest request =
      await getHttpClient().deleteUrl(Uri.parse(baseURL + urlPath));
      request.headers.set('content-type', 'application/json');
      request.headers.set('ConsumerSession', Get.find<UserController>().userSession);
      return await request.close();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}