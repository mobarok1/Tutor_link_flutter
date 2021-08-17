import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:stripe_native/stripe_native.dart';
import 'package:tutorlink/modelClass/address.dart';
import 'package:tutorlink/modelClass/charge_model.dart';
import 'package:tutorlink/storage/SharedPrefManager.dart';

class StripeTransactionResponse {
  String message;
  bool success;
  String id;
  StripeTransactionResponse({this.message, this.success,this.id});
}

class StripeService {
  static String apiBase = 'https://api.stripe.com/v1';
  static String secret = "sk_test_51Hkr9VG3turlMCSlQXY8EFL5DhgUbceHJkrCDXOM9HvQe4s2Mb3aRbAHiS3zwB231F21pp2KIMgbW3zr3Deof0QC00Qe9mToZm";
  static Map<String, String> headers = {
    'Authorization': 'Bearer ${StripeService.secret}',
    'Content-Type': 'application/x-www-form-urlencoded'
  };
  static init() {
    StripeNative.setPublishableKey("pk_test_51Hkr9VG3turlMCSl2caZ4VoqAgzp7LB2xoYBL24dYC6k6h9r5KiDDrLMMHQqOPcevqPOWBjDI3qvXVuShFHuhNBu00S8UaSj2n");
    StripeNative.setMerchantIdentifier("merchant.rbii.stripe-example");
  }

  static getPlatformExceptionErrorResult(err) {
    String message = 'Something went wrong';
    if (err.code == 'cancelled') {
      message = 'Transaction cancelled';
    }
    return new StripeTransactionResponse(message: message, success: false);
  }
  static Future<ChargeModel> getChargeID(String paymentIntent) async {
    try{
      Uri uri = Uri.parse("https://api.stripe.com/v1/charges?payment_intent=$paymentIntent");
      var response = await http.get(uri, headers: StripeService.headers);
      var data = jsonDecode(response.body);
      if(data["data"].length !=0){
       return ChargeModel(
         chargeId: data["data"][0]["id"],
         transactionId: data["data"][0]["balance_transaction"],
       );
      }else{
        return null;
      }
    } catch (err) {
      print('err to getting charge info of user: ${err.toString()}');
    }
    return null;
  }
  static Future<ChargeModel> getFees(String transactionId) async {
    try{
      var response = await http.get(Uri.parse("https://api.stripe.com/v1/balance_transactions/$transactionId"), headers: StripeService.headers);
      var data = jsonDecode(response.body);
      print(data);

      if(data["fee_details"] != null){
          print(data["fee_details"]);
          return ChargeModel(
            feesCent: data["fee_details"][0]["amount"],
            chargeCent: data["amount"]
          );
      }else{
        return null;
      }
    } catch (err) {
      print('err to getting charge info of user: ${err.toString()}');
    }
    return null;
  }
}
