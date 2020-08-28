import 'DatabaseHelper.dart';

class Products {
  int id, qty;
  String key, name, imageUrl, price, desc;
  Products({this.name, this.imageUrl, this.desc, this.key, this.price});

  Products.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    imageUrl = map['imageUrl'];
    price = map['price'];
    qty = map['qty'];
    desc = map['desc'];
  }

  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.columnId: id,
      DatabaseHelper.columnProductName: name,
      DatabaseHelper.columnImageUrl: imageUrl,
      DatabaseHelper.columnPrice: price,
      DatabaseHelper.columnQuantity: qty,
      DatabaseHelper.columnDesc: desc
    };
  }
}
