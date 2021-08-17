import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

Color appsMainColor = Color.fromRGBO(65, 22, 153, 1);
Color buttonColor = Color.fromRGBO(20, 186, 155, 1);
Color subColor = Colors.red;
Color mainBackgroundColor = Colors.white;
Color mainTextTitleColor = Colors.black;
Color mainShadowColor = Colors.black.withOpacity(.5);
Color mainTextSubColor = Colors.black.withOpacity(.5);
Color mainTextNormalColor = Colors.black;
String countryName;
String cityName,stateName;
TextStyle inputAndHint = TextStyle(fontSize: 17.0, height: 1.2, color: Colors.grey);
final loader = SpinKitFadingCircle(
  itemBuilder: (BuildContext context, int index) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: index.isEven ? Colors.red : Colors.green,
      ),
    );
  },
);
final loaderMore = SpinKitThreeBounce(
  itemBuilder: (BuildContext context, int index) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: index.isEven ? appsMainColor: Colors.red,
      ),
    );
  },
);
final loaderMaterial = Center(
  child: CircularProgressIndicator(
    valueColor: AlwaysStoppedAnimation<Color>(appsMainColor),
  ),
);
final loaderMaterialLinear = LinearProgressIndicator(
  valueColor: AlwaysStoppedAnimation<Color>(appsMainColor),
  backgroundColor: Colors.white,
);

