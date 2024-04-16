import 'package:http/http.dart' as http;
import 'dart:convert';
import 'product.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './product_response.dart';
import 'api_url.dart';

class ProductService {
  String apiUrl = ApiUrl.apiUrl;

  Future<List<Product>> getProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jwtNullable = prefs.getString('jwt');
    String jwt = jwtNullable ?? '';

    var response = await http.get(Uri.parse('$apiUrl/products'), headers: {
      'Content-Type': 'application/json',
      'Authorization': "Bearer $jwt",
    });

    if (response.statusCode == 201) {
      List<dynamic> body = jsonDecode(response.body);
      List<Product> products =
          body.map((dynamic item) => Product.fromJson(item)).toList();
      return products;
    } else {
      throw Exception("Failed to load products");
    }
  }

  Future<ProductResponse> addProduct(Product product) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jwtNullable = prefs.getString('jwt');
    String jwt = jwtNullable ?? '';

    var response = await http.post(
      Uri.parse('$apiUrl/products'),
      headers: {
        "Content-Type": "application/json",
        'Authorization': "Bearer $jwt",
      },
      body: jsonEncode(product.toJson()),
    );

    Product newProduct = Product(
      id: 0,
      name: "",
      description: "",
      price: 0,
      is_active: false,
    );

    if (response.statusCode == 201) {
      Map<String, dynamic> responseBody = jsonDecode(response.body);
      double price = double.parse(responseBody["price"]);

      newProduct = Product(
        id: responseBody["id"],
        name: responseBody["name"],
        description: responseBody["description"],
        price: price,
        is_active: responseBody["is_active"],
      );
    }
    return ProductResponse(response.statusCode, newProduct);
  }

  Future<int> updateProduct(Product product, int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jwtNullable = prefs.getString('jwt');
    String jwt = jwtNullable ?? '';

    var response = await http.put(
      Uri.parse('$apiUrl/products/${id}'),
      headers: {
        "Content-Type": "application/json",
        'Authorization': "Bearer $jwt",
      },
      body: jsonEncode(product.toJson()),
    );

    return response.statusCode;
  }

  Future<int> deleteProduct(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jwtNullable = prefs.getString('jwt');
    String jwt = jwtNullable ?? '';

    var response = await http.delete(
      Uri.parse('$apiUrl/products/$id'),
      headers: {
        "Content-Type": "application/json",
        'Authorization': "Bearer $jwt",
      },
    );

    return response.statusCode;
  }
}
