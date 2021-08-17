import 'package:get/get.dart';
import 'package:tutorlink/modelClass/cart_item.dart';
import 'package:tutorlink/storage/SharedPrefManager.dart';

class CartController extends GetxController{
  var count = 0.obs;
  RxList<dynamic> items = [].obs;
  @override
  void onInit() async{
    // TODO: implement onInit
    super.onInit();
    count.value = (await SharedPrefManager.getCartData()).length;
    update();
  }
  refreshCartList()async{
    items = RxList.from(await SharedPrefManager.getCartData());
    count.value = (await SharedPrefManager.getCartData()).length;
    update();
  }
  void addToCart(item) async{
    await SharedPrefManager.addToCart(item);
    refreshCartList();
  }
  void removeFromCart(String courseId) async{
    await SharedPrefManager.removeFromCart(courseId);
    items = RxList.from(await SharedPrefManager.getCartData());
    count.value = (await SharedPrefManager.getCartData()).length;
    if(count.value == 0){
      Get.back();
    }
    update();
  }
  clearCart() async{
    await SharedPrefManager.clearCart();
    count.value = 0;
    items = [].obs;
    update();
  }
  clearOnlyCart() async{
    await SharedPrefManager.clearCart();
    count.value = 0;
    items = [].obs;
  }
}