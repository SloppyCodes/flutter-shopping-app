import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import './product.dart';
import './../models/http_exception.dart';

class Products with ChangeNotifier {
  final String _token;
  final String _userId;
  List<Product> _items = [];

  Products(
      @required this._token, @required this._userId, @required this._items);

  bool _showFavoritesOnly = false;

  List<Product> get Items {
    return [..._items];
  }

  List<Product> get FavoriteItems {
    return _items.where((element) => element.isFavorite).toList();
  }

  Product findById(String producId) {
    return _items.firstWhere((product) => product.id == producId);
  }

  Future<void> addProduct(Product product) async {
    final url =
        'https://learning-flutter.firebaseio.com/products.json?auth=$_token';

    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
            'creatorId': _userId,
          },
        ),
      );

      if (response.statusCode == 200) {
        final newProduct = Product(
          id: json.decode(response.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl,
        );

        _items.add(newProduct);

        notifyListeners();
      }

      if (response.statusCode == 404) {
        throw Error();
      }
    } catch (error) {
      throw Error();
    }
  }

  Future<void> fetchAndSetProducts([final bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$_userId"' : '';
    var url =
        'https://learning-flutter.firebaseio.com/products.json?auth=$_token&$filterString';

    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];

      if (extractedData == null) {
        return;
      }

      url =
          'https://learning-flutter.firebaseio.com/userFavorites/$_userId.json?auth=$_token';

      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);

      extractedData.forEach(
        (key, value) {
          loadedProducts.add(
            Product(
              id: key,
              title: value['title'],
              description: value['description'],
              price: value['price'],
              imageUrl: value['imageUrl'],
              isFavorite:
                  favoriteData == null ? false : favoriteData[key] ?? false,
            ),
          );
        },
      );
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final url =
        'https://learning-flutter.firebaseio.com/products/$id.json?auth=$_token';
    final prodIndex = _items.indexWhere((element) => element.id == id);

    if (prodIndex >= 0) {
      try {
        await http.patch(
          url,
          body: json.encode(
            {
              'title': newProduct.title,
              'description': newProduct.description,
              'imageUrl': newProduct.imageUrl,
              'price': newProduct.price,
            },
          ),
        );

        _items[prodIndex] = newProduct;
        notifyListeners();
      } catch (error) {
        throw error;
      }
    }
  }

  Future<void> deleteProduct(final String productId) async {
    final url =
        'https://learning-flutter.firebaseio.com/products/$productId.json?auth=$_token';

    final existingProductIndex =
        _items.indexWhere((element) => element.id == productId);
    var existingProduct = _items[existingProductIndex];

    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product!');
    }

    existingProduct = null;
  }
}
