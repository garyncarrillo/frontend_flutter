import 'product.dart';

class ProductResponse {
  final int statusCode;
  final Product product;

  ProductResponse(this.statusCode, this.product);
}
