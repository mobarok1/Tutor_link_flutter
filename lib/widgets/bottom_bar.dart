import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toast/toast.dart';
import 'package:tutorlink/Pages/cart_page.dart';
import 'package:tutorlink/Pages/category_page.dart';
import 'package:tutorlink/Pages/favorite_page.dart';
import 'package:tutorlink/Pages/register_login/login.dart';
import 'package:tutorlink/controller/cart_controller.dart';
import 'package:tutorlink/controller/favorite_controller.dart';
import 'package:tutorlink/extra/theme_data.dart';

class BottomNavigationBarModelView extends StatelessWidget {
  final activeIndex;
  BottomNavigationBarModelView({this.activeIndex});
  final CartController cartController = Get.find();
  final FavoriteController favoriteController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(()=> ConvexAppBar(
      style: TabStyle.react,
      backgroundColor: appsMainColor,
      height: 40,
      curveSize: 60,
      items: [
        TabItem(
          icon: Icon(
            Icons.home,
            color: Colors.white,
          ),
        ),
        TabItem(
          icon: Icon(
            Icons.category,
            color: Colors.white,
          ),
        ),
        TabItem(
          icon:Stack(
            fit: StackFit.loose,
            children: [
              Icon(
                Icons.favorite,
                color: Colors.white,
              ),
            favoriteController.count.value != 0
                  ? Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    height: 20,
                    width: 20,
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                    child:Text(
                      favoriteController.count.value.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ))
                  : Container()
            ],
          ),
          activeIcon: Stack(
            fit: StackFit.loose,
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.favorite,
                size: 30,
                color: Colors.white,
              ),
              favoriteController.count.value != 0
                  ? Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    height: 20,
                    width: 20,
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                    child: Text(
                      favoriteController.count.value.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ))
                  : Container()
            ],
          )
        ),
        TabItem(
          icon: Stack(
            fit: StackFit.loose,
            children: [
              Icon(
                Icons.shopping_cart,
                color: Colors.white,
              ),
              cartController.count.value != 0
                  ? Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    height: 20,
                    width: 20,
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                    child:Text(
                      cartController.count.value.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ))
                  : Container()
            ],
          ),
          activeIcon: Stack(
            fit: StackFit.expand,
            children: [
              Icon(
                Icons.shopping_cart,
                color: Colors.white,
              ),
              cartController.count.value != 0
                  ? Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    height: 20,
                    width: 20,
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                    child: Text(
                      cartController.count.value.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ))
                  : Container()
            ],
          ),
        ),
        TabItem(
          icon: Icon(
            Icons.account_box,
            color: Colors.white,
          ),
        ),
      ],
      initialActiveIndex: activeIndex ,
      onTabNotify: (int i) {
        if(i==activeIndex){
          return false;
        }else if(i==0){
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
        else if (i == 1)
          Get.to(()=>CategoryPage());
        else if (i == 2)
          Get.to(()=>FavoritePage());
        else if (i == 3) {
          if (cartController.count.value == 0)
            Toast.show("Cart is Empty", context, backgroundColor: Colors.red, textColor: Colors.white);
          else
            Get.to(()=>CartListPage());
        }else if (i == 4)
          Get.to(()=>LoginPage(returnCount: 1,));
        return false;
      },
      onTap: (int i) {},
    ));
  }
}
