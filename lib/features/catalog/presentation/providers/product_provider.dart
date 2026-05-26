import 'dart:async';

import 'package:caffenio/features/catalog/domain/repositories/product_repository.dart';
import 'package:caffenio/shared/models/product_model.dart';
import 'package:flutter/material.dart';

class ProductProvider extends ChangeNotifier {
  ProductProvider({required ProductRepository repository})
      : _repository = repository {
    _listenToProducts();
  }

  final ProductRepository _repository;
  StreamSubscription<List<ProductModel>>? _subscription;

  List<ProductModel> _products = [];
  bool _isLoading = true;
  bool _isActionLoading = false;
  String? _errorMessage;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
  String? get errorMessage => _errorMessage;
  bool get hasProducts => _products.isNotEmpty;

  void _listenToProducts() {
    _subscription = _repository.watchProducts().listen(
      (products) {
        _products = products;
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Error al cargar el menú. Inténtalo de nuevo.';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> addProduct(ProductModel product) async {
    _beginAction();
    try {
      await _repository.addProduct(product);
      _errorMessage = null;
    } catch (_) {
      _errorMessage = 'No se pudo agregar el producto. Inténtalo de nuevo.';
    } finally {
      _endAction();
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    _beginAction();
    try {
      await _repository.updateProduct(product);
      _errorMessage = null;
    } catch (_) {
      _errorMessage = 'No se pudo actualizar el producto. Inténtalo de nuevo.';
    } finally {
      _endAction();
    }
  }

  Future<void> deleteProduct(String productId) async {
    _beginAction();
    try {
      await _repository.deleteProduct(productId);
      _errorMessage = null;
    } catch (_) {
      _errorMessage = 'No se pudo eliminar el producto. Inténtalo de nuevo.';
    } finally {
      _endAction();
    }
  }

  void _beginAction() {
    _isActionLoading = true;
    notifyListeners();
  }

  void _endAction() {
    _isActionLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
