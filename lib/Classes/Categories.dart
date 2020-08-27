class Categories {
  String imageUrl;
  String name;

  Categories({this.imageUrl, this.name});
}

List<Categories> categorylist = [
  Categories(imageUrl: "images/Grocery.png", name: "Groceries"),
  Categories(imageUrl: "images/Veggies.png", name: "Veggies"),
  Categories(imageUrl: "images/Dairy.png", name: "Dairy"),
  Categories(imageUrl: "images/Medicines.png", name: "Medicines"),
  Categories(imageUrl: "images/Stationary.png", name: "Stationary"),
];
