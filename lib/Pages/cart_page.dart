import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:stripe_native/stripe_native.dart';
import 'package:toast/toast.dart';
import 'package:tutorlink/Pages/payment/card_payment.dart';
import 'package:tutorlink/Pages/profile_pages/consumer_order_page_list.dart';
import 'package:tutorlink/api/api_request.dart';
import 'package:tutorlink/api/api_response.dart';
import 'package:tutorlink/controller/cart_controller.dart';
import 'package:tutorlink/extra/payment-service.dart';
import 'package:tutorlink/extra/theme_data.dart';
import 'package:tutorlink/modelClass/cart_item.dart';
import 'package:tutorlink/modelClass/charge_model.dart';
import 'package:tutorlink/storage/SharedPrefManager.dart';
import 'package:http/http.dart' as http;
import 'package:tutorlink/widgets/input_fields.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CartListPage extends StatefulWidget {
  @override
  _CartListPageState createState() => _CartListPageState();
}

class _CartListPageState extends State<CartListPage> {
  bool loading = false;
  double price = 0;
  int paymentMethod = 0;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  BuildContext _myContext;
  CartController cartController = Get.find();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    StripeService.init();
    cartController.refreshCartList();
  }
  out(){
    Get.back();
  }
  @override
  Widget build(BuildContext context) {
    _myContext = context;
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          iconTheme: IconThemeData(color: appsMainColor),
          title: Text(
            "Your Cart",
            style:
                TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          ),
        ),
        body: GetBuilder<CartController>(
          init: cartController,
          builder: (controller){
            price = 0;
            cartController.items.toList().forEach((element) {
              try {
                double _price = element.children.length == 0
                    ? element.price
                    : (element.children.length * element.price);
                price+=_price;
              }catch(e){
                print(e);
              }
            });
            return SingleChildScrollView(
              child: Container(
                child: Column(
                  children: [
                    Container(
                        margin: EdgeInsets.only(left: 5, right: 5, top: 10),
                        decoration: BoxDecoration(
                            borderRadius:
                            BorderRadius.all(Radius.circular(15)),
                            border: Border.all(color: appsMainColor)),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: appsMainColor,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                ),
                              ),
                              alignment: Alignment.center,
                              padding: EdgeInsets.only(top: 10, bottom: 10),
                              margin: EdgeInsets.only(bottom: 5),
                              child: Text(
                                "Course List",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                            Column(
                              children: cartController.items.toList().map((element) {
                                CartListItem e = element;
                                double subtotal = e.children.length <= 1
                                    ? e.price
                                    : (e.children.length - 1) * e.price;
                                return Container(
                                  margin: EdgeInsets.only(
                                      bottom: 0, top: 0, left: 5, right: 5),
                                  padding: EdgeInsets.only(top: 5, bottom: 0),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: Colors.black
                                                  .withOpacity(.3)))),
                                  child: Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 40,
                                        width: 60,
                                        margin: EdgeInsets.only(
                                            bottom: 5, left: 5, right: 10),
                                        child: e.courseImage == null
                                            ? Image.asset(
                                            "assets/images/ustad_logo.png")
                                            : Image.network(
                                          ApiRequest(context).getBaseUrl() +
                                              '/delivery/course/${e.courseId}/file/${e.courseImage}',
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                      Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                margin: EdgeInsets.only(
                                                    top: 0, bottom: 2),
                                                child: Text(
                                                  e.courseName,
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: appsMainColor,
                                                      fontWeight:
                                                      FontWeight.bold),
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,

                                                children: e.children.map((e) {
                                                  return Container(
                                                      padding: EdgeInsets.only(
                                                          left: 5,
                                                          right: 5,
                                                          top: 2,
                                                          bottom: 2
                                                        ),
                                                      child: Text("* ${e.firstName}")
                                                  );
                                                }).toList(),
                                              ),
                                              e.sessionName.isNotEmpty?
                                  Container(
                                      padding: EdgeInsets.only(
                                          left: 5,
                                          right: 5,
                                          top: 2,
                                          bottom: 2
                                      ),
                                      child: Text("* ${e.sessionName}")
                                  ):Container()
                                            ],
                                          )),
                                      Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            width: 100,
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              "£ ${subtotal.toStringAsFixed(2)}",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: appsMainColor),
                                            ),
                                          ),
                                          Container(
                                            alignment: Alignment.centerRight,
                                            margin: EdgeInsets.only(top: 2),
                                            child: Text(
                                              "£ ${e.price.toStringAsFixed(2)} * ${e.children.length <= 1 ? 1 : (e.children.length - 1)}",
                                              style: TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        height: 25,
                                        width: 35,
                                        child: IconButton(
                                            icon: Icon(
                                              Icons.close,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              cartController.removeFromCart(e.courseId);
                                            }),
                                      )
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                            Container(
                              height: 45,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Total  :",
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                          color: appsMainColor,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Container(
                                    width: 130,
                                    padding: EdgeInsets.only(right: 10),
                                    margin: EdgeInsets.only(right: 35),
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      "£ ${price.toStringAsFixed(2)}",
                                      style: TextStyle(
                                          color: appsMainColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        )),
                    Container(
                      margin: EdgeInsets.only(left: 5, right: 5, top: 20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          border: Border.all(color: appsMainColor)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: appsMainColor,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
                            ),
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(top: 10, bottom: 10),
                            child: Text(
                              "Payment Information",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(
                                left: 10, right: 10, top: 10, bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  child: Radio(
                                    value: 0,
                                    onChanged: (value) {
                                      setState(() {
                                        paymentMethod = value;
                                      });
                                    },
                                    activeColor: appsMainColor,
                                    groupValue: paymentMethod,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 10),
                                  child: Image.asset(
                                    "assets/images/visa.png",
                                    height: 40,
                                    width: 50,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 10),
                                  child: Image.asset(
                                    "assets/images/master_card.png",
                                    height: 40,
                                    width: 50,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 10),
                                  child: Image.asset(
                                    "assets/images/amex.png",
                                    height: 40,
                                    width: 50,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                Container(
                                  child: Image.asset(
                                    "assets/images/discover.png",
                                    height: 40,
                                    width: 50,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            color: Colors.black.withOpacity(1),
                            height: 1,
                          ),
                          Container(
                            padding: EdgeInsets.only(
                                left: 10, right: 10, top: 5, bottom: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  child: Radio(
                                    value: 1,
                                    onChanged: (value) {
                                      setState(() {
                                        paymentMethod = value;
                                      });
                                    },
                                    groupValue: paymentMethod,
                                    activeColor: appsMainColor,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 10),
                                  child: Image.asset(
                                    "assets/images/google_pay.png",
                                    height: 25,
                                    width: 60,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 200,
                      margin: EdgeInsets.only(top: 10, bottom: 50),
                      child: FlatButton(
                        padding: EdgeInsets.only(
                            left: 25, right: 25, top: 12, bottom: 12),
                        color: Colors.redAccent[700],
                        onPressed: () {
                          //we are comparing payment method 0 = card payment and 1 = nativePay
                          if (paymentMethod == 0) {
                            payViaNewCard(context);
                          } else {
                            payWithNative();
                          }
                        },
                        child: Text(
                          "Continue",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        )
    );
  }

  payViaNewCard(BuildContext ctx) async {
    Navigator.push(context, MaterialPageRoute(builder: (ctx)=>CardPaymentPage(price: price,)));
  }

  payWithNative() async {
    // var token = await orderPayment;
    var token = await receiptPayment;
    await createCharge(token, price);

  }
  Future<String> get receiptPayment async {
    Map<String,double> receipt = {};
    cartController.items.toList().forEach((element) {
      receipt.putIfAbsent("${element.courseName}", ()=>(element.children.length == 0?element.price:(element.price*element.children.length)));
    });
    var aReceipt = Receipt(receipt, "Mobile Apps Purchase");
    var response;
    try {
      response = await StripeNative.useReceiptNativePay(aReceipt);
    }catch(e){
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Payment Failed !",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
          backgroundColor: Colors.red[900],
        )
      );
    }
    return response;
  }

  Future<String> get orderPayment async {
    // subtotal, tax, tip, merchant name
    var order = Order(5.50, 1.0, 2.0, "Some Store");
    return await StripeNative.useNativePay(order);
  }

  Future<Map<String, dynamic>> createCharge(
      String tokenId, double amount) async {
    setState(() {
      loading = true;
    });
    try {
      Map<String, dynamic> body = {
        'amount': (amount * 10).toString().replaceAll(".", ""),
        'currency': 'GBP',
        'source': tokenId,
        'description': 'Order'
      };
      var response = await http
          .post(Uri.parse('https://api.stripe.com/v1/charges'), body: body, headers: {
        'Authorization': 'Bearer ${StripeService.secret}',
        'Content-Type': 'application/x-www-form-urlencoded'
      });
      setState(() {
        loading = false;
      });
      var data = jsonDecode(response.body);
      print(data);
      ChargeModel charge;
      print(data);
      if (data["paid"]) {
        print("SSSSS");
        StripeNative.confirmPayment(true);
        if(data["data"].length !=0){
          charge =  ChargeModel(
            chargeId: data["data"][0]["id"],
            transactionId: data["data"][0]["balance_transaction"],
          );
        }
        ChargeModel fees = await StripeService.getFees(charge.transactionId);
        sendPaymentToServer(fees.chargeCent,fees.feesCent, charge.transactionId,context);
        Toast.show("Payment Successfully Completed", context,
            backgroundColor: Colors.green, textColor: Colors.white);
        Navigator.pop(context);
      } else {
        print("ffff");

        StripeNative.confirmPayment(false);
        Toast.show("Payment Failed", context,
            backgroundColor: Colors.red, textColor: Colors.white);
      }
      return data;
    } catch (err) {
      print('err charging user: ${err.toString()}');
    }
    setState(() {
      loading = false;
    });
    return null;
  }

  Future sendPaymentToServer(int amount,int fees, String _trId,ctx) async {
    ProgressDialog dialog = new ProgressDialog(context);
    dialog.style(message: 'Please wait...');
    await dialog.show();
    String consumerId = await SharedPrefManager.getUserId();
    var body = jsonEncode({
      "cents_amount" : amount,
      "reference" : _trId,
      "cents_fee" : fees,
      "orderer_type": "CONSUMER",
      "orderer_uuid": consumerId,
      "credit_card": {
        "card_number": "",
        "card_expiry_month": "",
        "card_expiry_year": "",
        "card_cvv": "",
      },
      "country_code": "UK",
      "currency_code": "GBP",
      "source": "STRIPE",
      "status": "APPROVED"
    });
    ApiResponse result = await ApiRequest(context).payment(body);
    if (result.responseCode == 201) {
      for (CartListItem item in cartController.items.toList()) {
        if (item.children.length <= 1) {
          bool res = await ApiRequest(context).paymentSubscription(item.courseId, result.response,item.sessionId);
          print(res ? "${item.courseName} => Success" : "Failed");
          if(!res){
            Toast.show("Payment Failed to Complete", context,
                backgroundColor: Colors.red, textColor: Colors.white);
          }
        } else {
          for (int i = 1; i < item.children.length; i++) {
            bool res = await ApiRequest(context).childPaymentSubscription(
                item.courseId, result.response, item.children[i].childUid,item.sessionId);
            print(res ? "${item.courseName} => child ${item.children[i].childUid} => Success"
                : "Failed");
            if(!res){
              Toast.show("Payment Failed to Complete", context,
                  backgroundColor: Colors.red, textColor: Colors.white);
            }
          }
        }
      }
      await dialog.hide();
      await SharedPrefManager.clearCart();
      cartController.clearCart();
      Navigator.pushAndRemoveUntil(_myContext,
          MaterialPageRoute(builder: (context) => ConsumerOrderPage()
          ), (Route<dynamic> route) => route.isFirst);
    } else {
      Toast.show("Payment Failed to Complete", context,
          backgroundColor: Colors.red, textColor: Colors.white);
    }
  }
}
