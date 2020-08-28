import 'package:groceryapp/Classes/Shops.dart';

class Order {
  String deliveryDate,
      orderAmount,
      orderDate,
      orderKey,
      orderTime,
      shippingDate,
      shopCategory,
      shopKey;
  Shops shop;
  List<String> itemsName;
  bool isCompleted;
  List<int> itemsQty;
  Order(
      {this.shopKey,
      this.shopCategory,
      this.itemsQty,
      this.itemsName,
      this.orderAmount,
      this.orderDate,
      this.shop,
      this.deliveryDate,
      this.orderKey,
      this.orderTime,
      this.shippingDate,
      this.isCompleted});
}
