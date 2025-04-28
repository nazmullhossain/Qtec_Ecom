import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../../models/product_models.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc() : super(ProductInitial()) {
    on<FetchProducts>((event, emit) async {
      emit(ProductLoading());
      try {
        final response = await http.get(Uri.parse('https://fakestoreapi.com/products'));

        if (response.statusCode == 200) {
          List jsonData = jsonDecode(response.body);
          List<Product> products = jsonData.map((item) => Product.fromJson(item)).toList();
          emit(ProductLoaded(products));
        } else {
          emit(ProductError('Failed to load products'));
        }
      } catch (e) {
        emit(ProductError(e.toString()));
      }
    });
  }
}
