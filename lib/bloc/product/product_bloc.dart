import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:qtec_ecom/repository/product_repository.dart';
import '../../models/product_models.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  int _page = 1;
  final int _limit = 10;
  bool _isFetching = false;

  ProductBloc({required ProductRepository productRepository}) : super(ProductInitial()) {
    on<FetchProducts>(_onFetchProducts);
  }

  Future<void> _onFetchProducts(FetchProducts event, Emitter<ProductState> emit) async {
    if (_isFetching) return;
    _isFetching = true;

    try {
      final currentState = state;
      List<Product> oldProducts = [];

      if (currentState is ProductLoaded) {
        oldProducts = currentState.products;
      } else {
        emit(ProductLoading());
      }

      final response = await http.get(
        Uri.parse('https://fakestoreapi.com/products?limit=$_limit'),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as List;
        final products = jsonData.map((e) => Product.fromJson(e)).toList();

        if (products.isEmpty) {
          emit(ProductLoaded(products: oldProducts, hasReachedMax: true));
        } else {
          _page++;
          emit(ProductLoaded(
            products: [...oldProducts, ...products],
            hasReachedMax: products.length < _limit,
          ));
        }
      } else {
        emit(ProductError('Failed to load products'));
      }
    } catch (e) {
      emit(ProductError(e.toString()));
    } finally {
      _isFetching = false;
    }
  }
}
