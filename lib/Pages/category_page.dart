import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tutorlink/Pages/section_view.dart';
import 'package:tutorlink/api/api_request.dart';
import 'package:tutorlink/controller/cart_controller.dart';
import 'package:tutorlink/controller/favorite_controller.dart';
import 'package:tutorlink/extra/theme_data.dart';
import 'package:tutorlink/modelClass/category_model_type.dart';
import 'package:tutorlink/modelClass/section_model.dart';
import 'package:tutorlink/widgets/bottom_bar.dart';

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  bool loading = false;
  List<CategoryTypeModel> allCategory = List<CategoryTypeModel>();
  CartController cartController = Get.find();
  FavoriteController favoriteController = Get.find();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCartData();
  }
  getCartData() async {
    setState(() {
      loading = true;
    });
    //getting all category From Server
    allCategory = await ApiRequest(context).getAllCategoryType();
    setState(() {
      loading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomNavigationBarModelView(
          activeIndex: 1,
        ),
        appBar: AppBar(
          iconTheme: IconThemeData(color: appsMainColor),
          title: Text(
            "Course Category",
            style:
            TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          ),
        ),
        body: loading
            ? Center(
                child: loader,
            ) :
            GridView.count(
                crossAxisCount: 3,
                children: allCategory.map((e){
                  return Container(
                      height: 100,
                      width: 100,
                      margin: EdgeInsets.only(left: 0, right: 0, top: 5, bottom: 5),
                      padding: EdgeInsets.only(),
                      child: FlatButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            Get.to(()=>SectionView(
                              sectionModel: SectionModel(
                                  sectionName: e.displayName,
                                  keyName: e.value,
                                  value: "categoryView"
                              ),
                            ));                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Container(
                                child: Image.network(
                                  ApiRequest(context).getBaseUrl()+"/delivery/config/course/property/category/${e.value}/file",
                                  fit: BoxFit.cover,
                                )),
                          )));
                }).toList(),
            )
    );
  }
}
