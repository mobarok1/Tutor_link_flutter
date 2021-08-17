import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tutorlink/Pages/profile_pages/consumer_order_page_list.dart';
import 'package:tutorlink/controller/cart_controller.dart';
import 'package:tutorlink/extra/theme_data.dart';

class PaymentConfirmationPage extends StatefulWidget {

  @override
  _PaymentConfirmationPageState createState() => _PaymentConfirmationPageState();
}

class _PaymentConfirmationPageState extends State<PaymentConfirmationPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      clearCart();
    });
  }
  clearCart()async{
    CartController controller = Get.find();
    await controller.clearCart();
  }
  Future<bool> _willPopCallback() async {

    return false; // return true if the route to be popped
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
        appBar: AppBar(
          title: Text("Payment Confirmation"),
        ),
        body: Center(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Your payment has been successful and a confirmation receipt has been sent to your email",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),textAlign: TextAlign.center,),
                FlatButton(
                  onPressed: () {
                    Get.offUntil(MaterialPageRoute(builder:(ctx)=>ConsumerOrderPage()), (route) => route.isFirst);
                  },
                  color: appsMainColor,
                  textColor: Colors.white,
                  child: Text("Go Back",),
                )
              ],
            ),
          ),
        )
    ),
        onWillPop: _willPopCallback
    );
  }
}