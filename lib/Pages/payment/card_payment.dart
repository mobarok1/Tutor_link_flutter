import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:toast/toast.dart';
import 'package:tutorlink/Pages/profile_pages/consumer_order_page_list.dart';
import 'package:tutorlink/api/api_request.dart';
import 'package:tutorlink/api/api_response.dart';
import 'package:tutorlink/controller/cart_controller.dart';
import 'package:tutorlink/controller/favorite_controller.dart';
import 'package:tutorlink/controller/user_controller.dart';
import 'package:tutorlink/extra/payment-service.dart';
import 'package:tutorlink/extra/theme_data.dart';
import 'package:tutorlink/modelClass/cart_item.dart';
import 'package:tutorlink/modelClass/course_model.dart';
import 'package:tutorlink/storage/SharedPrefManager.dart';
import 'package:tutorlink/widgets/input_fields.dart';
import 'package:http/http.dart' as http;
import 'package:tutorlink/widgets/loader.dart';
import 'package:webview_flutter/platform_interface.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CardPaymentPage extends StatefulWidget {
  final double price;
  CardPaymentPage({@required this.price});
  @override
  _CardPaymentPageState createState() => _CardPaymentPageState();
}

class _CardPaymentPageState extends State<CardPaymentPage> {
  TextEditingController cardNumber = TextEditingController();
  TextEditingController cardExpire = TextEditingController();
  TextEditingController cardCVC = TextEditingController();
  bool loading = false;
  bool cardNumberError =false;
  bool cardExpireError =false;
  bool cardCVCError =false;
  WebViewController _controller;
  List<CartListItem> cartItems=[];
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  CartController controller = Get.find();
  UserController userController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Payment"),
      ),
      body: Column(
        children: [
          Flexible(
              child:WebView(
                javascriptMode: JavascriptMode.unrestricted,
                onWebResourceError: (WebResourceError error){
                  Navigator.pop(context);
                },
                onPageStarted: (str){
                  ProgressLoader.show();
                },
                onPageFinished: (str){
                  ProgressLoader.close();
                },
                userAgent: "Mozilla/5.0 (iPhone; CPU iPhone OS 9_3 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13E233 Safari/601.1",

                javascriptChannels:Set.from([
                  JavascriptChannel(
                    name: 'message',
                    onMessageReceived: (JavascriptMessage message) {
                      var response = jsonDecode(message.message);
                      int statusCode = 404;
                      try{
                        statusCode = response["status_code"];
                      }catch(e){
                        print(e);
                      }
                      if(statusCode == 200){
                        print("Success Called");
                        showSuccessDialog();
                      }else{
                        print("failed called");
                        showFailedDialog(response["message"]??"Unknown Error ($response)");
                      }

                    },
                  )
                ]),
                onWebViewCreated: (WebViewController w) {
                  _controller = w;
                  _loadHtmlFromAssets();
                },
              )
          ),
        ],
      )
    );
  }
  _loadHtmlFromAssets() async {
      List<Map<String,dynamic>> items = [];
      cartItems = await SharedPrefManager.getCartData();
      cartItems.forEach((element) {
        items.add(
          {
            "course_id": element.courseId,
            "course_session_id":element.sessionId,
            "child": element.children.map((e){
              return e.childUid;
            }).toList(),
            "price": element.children.length==0?element.price:(element.price*element.children.length)
          }
        );
      });
      Map<String,dynamic> _courseData = {
        "userId": userController.userId,
        "session_id":userController.userSession,
        "total_amount": widget.price,
        "courses":items
      };
      var data = base64Encode(utf8.encode(jsonEncode(_courseData)));
print("https://test1.ustadhlink.com/mobile/checkout?course=$data");
    _controller.loadUrl("https://test1.ustadhlink.com/mobile/checkout?course=$data");
  }
  showSuccessDialog() async{
    Get.defaultDialog(
      title: "Payment Success",
      content: Text("Your payment has been successful and a confirmation receipt has been sent to your email"),
      actions: [
        FlatButton(
            onPressed: (){
              Get.offUntil(MaterialPageRoute(builder:(ctx)=>ConsumerOrderPage()), (route) => route.isFirst);
            },
            child: Text("Close")
        )
      ]
    );
    await controller.clearOnlyCart();
  }
  showFailedDialog(String msg){
    print("Called");
    Get.defaultDialog(
        title: "Payment Failed",
        content: Text("Error : $msg"),
        actions: [
          FlatButton(
              onPressed: (){
                Get.back();
              },
              child: Text("Close")
          )
        ]
    );
  }
}
