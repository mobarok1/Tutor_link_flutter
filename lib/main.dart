import 'package:flare_splash_screen/flare_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:tutorlink/api/api_client.dart';
import 'package:tutorlink/api/api_request.dart';
import 'package:tutorlink/controller/cart_controller.dart';
import 'package:tutorlink/controller/favorite_controller.dart';
import 'package:tutorlink/controller/user_controller.dart';
import 'package:tutorlink/extra/theme_data.dart';
import 'package:tutorlink/modelClass/session_model.dart';
import 'Pages/home_page.dart';
import 'controller/category_controller.dart';
import 'controller/category_course_controller.dart';

void main() {
  runApp(MyApp());
}
final GoogleSignIn signIn = GoogleSignIn(
  clientId: "33218104932-8ecm7j4fuo0otgben45unbatjuc8eobo.apps.googleusercontent.com",
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Ustadhlink',
      debugShowCheckedModeBanner: false,
      color: Colors.white,
      builder: (context, child) {
        SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle());
        /****************************
            management Setup Start
         *****************************/
        Get.put(UserController());
        Get.put(CartController());
        Get.put(FavoriteController());
        Get.put(CategoryController());
        Get.put(CategoryCourseController());

        /****************************
            management Setup End
         *****************************/

        return ScrollConfiguration(
          behavior: MyBehavior(),
          child: child,
        );
      },
      theme: ThemeData(
          primaryColor: Colors.white,
          scaffoldBackgroundColor: Colors.white,
          textTheme: GoogleFonts.montserratTextTheme(
            Theme.of(context).textTheme,
          ),
      ),
      home: HomePage(),

    );
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

