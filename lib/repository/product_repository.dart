// product_repository.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/product_models.dart';



import '../utils/db_helper.dart';

class ProductRepository {
  final DatabaseHelper dbHelper = DatabaseHelper();

  Future<List<Product>> fetchProductsFromAPI() async {
    final response = await http.get(Uri.parse('https://fakestoreapi.com/products'));
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      List<Product> products = data.map((e) => Product.fromJson(e)).toList();


      await dbHelper.insertProducts(products);

      return products;
    } else {
      throw Exception('Failed to load products from API');
    }
  }

  Future<List<Product>> getProductsFromLocalDB() async {
    return await dbHelper.getAllProducts();
  }
}
