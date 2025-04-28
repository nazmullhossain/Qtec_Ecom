import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../../models/product_models.dart';
import '../../utils/db_helper.dart';
import 'product_event.dart';
import 'product_state.dart';

// product_bloc.dart
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final _dbHelper = DatabaseHelper();
  int _page = 1;
  final int _pageSize = 10;
  List<Product> _allProducts = [];

  ProductBloc() : super(ProductInitial()) {
    on<FetchProducts>(_onFetchProducts);
  }

  Future<void> _onFetchProducts(FetchProducts event, Emitter<ProductState> emit) async {
    if (state is ProductLoading) return;

    emit(ProductLoading());

    try {
      final response = await http.get(Uri.parse('https://fakestoreapi.com/products'));
      if (response.statusCode == 200) {
        List jsonData = jsonDecode(response.body);
        _allProducts = jsonData.map((e) => Product.fromJson(e)).toList();

        // Paginate manually
        int start = (_page - 1) * _pageSize;
        int end = start + _pageSize;
        List<Product> paginated = _allProducts.sublist(start, end > _allProducts.length ? _allProducts.length : end);

        await _dbHelper.insertProducts(paginated);
        List<Product> dbProducts = await _dbHelper.getAllProducts();

        emit(ProductLoaded(dbProducts));
        _page++;
      } else {
        emit(ProductError('Failed to load'));
      }
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
}

