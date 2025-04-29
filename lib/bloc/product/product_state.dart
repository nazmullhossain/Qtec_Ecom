import '../../models/product_models.dart';

abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> products;
  final bool hasReachedMax;

  ProductLoaded({required this.products, required this.hasReachedMax});
}

class ProductError extends ProductState {
  final String message;
  ProductError(this.message);
}
