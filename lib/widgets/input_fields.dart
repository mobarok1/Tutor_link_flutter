import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tutorlink/extra/theme_data.dart';
import 'package:tutorlink/modelView/filter_sort_by_page.dart';
typedef String Validator(String str);
class InputField1 extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String lableText;
  final bool obSecure, readOnly;
  final String errorText;
  final TextInputType inputType;
  final VoidCallback onTap;
  final Validator validator;
  InputField1(
      {@required this.hintText,
      @required this.controller,
      @required this.obSecure,
        this.lableText,
      this.errorText,
      this.readOnly,
        this.onTap,
        this.validator,
      this.inputType});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextFormField(
        keyboardType: inputType == null ? TextInputType.text : inputType,
        autofocus: false,
        autocorrect: false,
        textInputAction: TextInputAction.done,
        obscureText: obSecure,
        onTap: onTap,
        readOnly: readOnly == null ? false : readOnly,
        validator: validator,
        decoration:  InputDecoration(
            hintText: hintText,
            labelText: lableText??hintText,
            errorText: errorText,
            labelStyle: TextStyle(
                color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
            border: OutlineInputBorder(
                borderSide: BorderSide(color: appsMainColor, width: 2)),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: appsMainColor)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
              color: appsMainColor,
            ),
          ),
          contentPadding:
              EdgeInsets.only(left: 15, bottom: 0, top: 0, right: 15),
        ),
        controller: controller,
      ),
    );
  }
}

class InputField2 extends StatelessWidget {
  TextEditingController controller;
  String hintText;
  bool obSecure;
  String errorText;
  InputField2(
      {@required this.hintText,
      @required this.controller,
      @required this.obSecure,
      this.errorText});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.done,
        obscureText: obSecure,
        decoration: InputDecoration(
            labelText: hintText,
            errorText: errorText,
            labelStyle: TextStyle(color: appsMainColor),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: appsMainColor, width: 3))),
      ),
    );
  }
}
