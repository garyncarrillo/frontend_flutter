class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final bool is_active;

  Product(
      {this.id = 0,
      this.name = "",
      this.description = "",
      this.price = 0,
      this.is_active = false});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      is_active: json['is_active'] == 'true' || json['is_active'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price.toString(),
      'is_active': is_active.toString(),
    };
  }
}
