import 'dart:async';

import 'package:afribio/models/cart_detail_model.dart';
import 'package:afribio/services/http_service.dart';

class Manager{
  final StreamController<int> _cartCount = StreamController<int>();

  Stream<int> get cartCount => _cartCount.stream;

  Stream<Cart> get cartView async*{
    yield await HttpService.getCartDetails();
  }

  Manager(){
    cartView.listen((data)=> _cartCount.add(data.commande.detail.length));
  }
}