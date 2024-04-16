import 'package:flutter/material.dart';
import '../services/product_service.dart';
import '../services/product.dart';
import "../services/product_response.dart";

class ProductScreen extends StatefulWidget {
  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final ProductService _productService = ProductService();
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    _products = await _productService.getProducts();
    setState(() {});
  }

  void _deleteProduct(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete this product?"),
          actions: <Widget>[
            MaterialButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            MaterialButton(
              onPressed: () {
                _performDelete(id);
                Navigator.of(context).pop();
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _performDelete(int id) {
    setState(() {
      _products.removeWhere((product) => product.id == id);
      _productService.deleteProduct(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Products")),
      body: ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, index) {
          Product product = _products[index];
          return ListTile(
            title: Text(product.name),
            subtitle: Text(product.description),
            trailing: Text("\$${product.price}"),
            onTap: () => _showEditDialog(context, product),
            onLongPress: () => _deleteProduct(context, product.id),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addProduct(context),
        child: Icon(Icons.add),
      ),
    );
  }

  void _showEditDialog(BuildContext context, Product product) {
    String name = product.name;
    String description = product.description;
    double price = product.price;
    bool isActive = product.is_active;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Product"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Name'),
                  controller: TextEditingController(text: name),
                  onChanged: (value) => name = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Description'),
                  controller: TextEditingController(text: description),
                  onChanged: (value) => description = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Price'),
                  controller: TextEditingController(text: price.toString()),
                  onChanged: (value) => price = double.tryParse(value) ?? 0.0,
                ),
                SwitchListTile(
                  title: Text('Is Active'),
                  value: isActive,
                  onChanged: (value) {
                    setState(() {
                      isActive = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            MaterialButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            MaterialButton(
              onPressed: () async {
                if (name.isNotEmpty && description.isNotEmpty && price > 0) {
                  int id = product.id;
                  bool status = await _updateProduct(
                      id, name, description, price, isActive);

                  if (status) {
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Failed to update the product")));
                  }
                }
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _updateProduct(int id, String name, String description,
      double price, bool isActive) async {
    Product editProduct = Product(
      name: name,
      description: description,
      price: price,
      is_active: isActive,
    );

    int statusCode = await _productService.updateProduct(editProduct, id);

    if (statusCode == 201) {
      _loadProducts();
    }
    return statusCode == 201;
  }

  void _addProduct(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String name = '';
        String description = '';
        double price = 0.0;
        bool isActive = true;

        return AlertDialog(
          title: Text("Add Product"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Name'),
                  onChanged: (value) => name = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Description'),
                  onChanged: (value) => description = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Price'),
                  onChanged: (value) => price = double.tryParse(value) ?? 0.0,
                ),
                SwitchListTile(
                  title: Text('Is Active'),
                  value: isActive,
                  onChanged: (value) {
                    setState(() {
                      isActive = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            MaterialButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            MaterialButton(
              onPressed: () async {
                if (name.isNotEmpty && description.isNotEmpty && price > 0) {
                  bool status =
                      await _saveProduct(name, description, price, isActive);

                  if (status) {
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("No fue posible guardar el product")));
                  }
                }
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _saveProduct(
      String name, String description, double price, bool isActive) async {
    // Create a new product instance and add it to the list

    // Save the product to the database or service
    Product newProduct = Product(
      name: name,
      description: description,
      price: price,
      is_active: isActive,
    );
    ProductResponse response = await _productService.addProduct(newProduct);

    if (response.statusCode == 201) {
      setState(() {
        _products.add(response.product);
      });
    }
    return response.statusCode == 201;
  }
}
