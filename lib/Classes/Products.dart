import 'DatabaseHelper.dart';

class Products {
  int id, qty, stockQty;
  String key, name, imageUrl, price, desc, prodCategory;
  Products(
      {this.name,
      this.imageUrl,
      this.desc,
      this.key,
      this.price,
      this.qty,
      this.stockQty});

  Products.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    imageUrl = map['imageUrl'];
    price = map['price'];
    qty = map['qty'];
    desc = map['desc'];
    key = map['key'];
    prodCategory = map['prodCategory'];
  }

  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.columnId: id,
      DatabaseHelper.columnProductName: name,
      DatabaseHelper.columnImageUrl: imageUrl,
      DatabaseHelper.columnPrice: price,
      DatabaseHelper.columnQuantity: qty,
      DatabaseHelper.columnDesc: desc,
      DatabaseHelper.columnProductKey: key,
      DatabaseHelper.columnProductCategory: prodCategory,
    };
  }
}
