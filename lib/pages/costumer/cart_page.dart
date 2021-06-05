import 'dart:convert';

import 'package:afribio/models/cart_detail_model.dart';
import 'package:afribio/screens/home_screen_costumer.dart';
import 'package:afribio/services/cart_manage_service.dart';
import 'package:afribio/services/http_service.dart';
import 'package:afribio/utilities/globals.dart';
import 'package:afribio/widgets/cart_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartPage extends StatefulWidget {
  final List<Detail> cartDetails;

  const CartPage({Key key, this.cartDetails}) : super(key: key);
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  double cartTotal = 0;
  final adresseText = TextEditingController();

  void getCartTotal() {
    for (int i = 0; i < widget.cartDetails.length; i++) {
      setState(() {
        cartTotal += (double.parse(widget.cartDetails[i].prixUnitaire)) *
                (double.parse(widget.cartDetails[i].quantite));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getCartTotal();
  }


  void deleteFromCart({int index}) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try{
      String jsonData = prefs.getString('cartJsonArr');
      Iterable i = jsonDecode(jsonData);
      List<Detail> existCart = List<Detail>.from(i.map((model)=>Detail.fromJson(model)));
      existCart.removeAt(index);
      String data = jsonEncode(existCart);
      prefs.setInt('cart_count', existCart.length);
      prefs.setString("cartJsonArr", data);
      setState(() {
        widget.cartDetails.removeAt(index);
        double total = 0;
        for(int i=0; i<widget.cartDetails.length; i++){
          double pu = double.parse(existCart[i].prixUnitaire);
          double qte = double.parse(widget.cartDetails[i].quantite);
          total += pu *qte;
        }
        setState(() {
          cartTotal = 0;
          cartTotal = total;
        });
      });

    }
    catch(e)
    {
      print('error $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        iconTheme: IconThemeData(color: Colors.black87),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.shopping_basket_rounded,
              size: 18,
            ),
            SizedBox(
              width: 8,
            ),
            Text(
              "Mon panier",
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16.0,
                  letterSpacing: 1.0,
                  color: Colors.black87),
            ),
          ],
        ),
        elevation: 1,
        backgroundColor: Colors.white,
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    return Column(
      children: [
        Expanded(
          child: Container(
              height: 500,
              child: widget.cartDetails.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/icons/panier.png",
                            fit: BoxFit.scaleDown,
                            height: 200,
                            width: 200,
                          ),
                          Text(
                            "Votre panier est vide !",
                            style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.black87,
                                letterSpacing: 1.0),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: widget.cartDetails.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return CartItemWidget(
                          cartDetail: widget.cartDetails[index],
                          onDelete: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            String posVenteId = prefs.getString("pos_vente_id");
                            showAlertDialog(
                                content:
                                    "Etes-vous sur de vouloir effacer ce produit du panier ?",
                                title: "Alert de suppression",
                                context: context,
                                onOk: () async {
                                  EasyLoading.show();
                                  await HttpService.deleteItemToCommand(
                                          posVenteId: posVenteId,
                                          produitId: widget
                                              .cartDetails[index].produitId)
                                      .then((res) {
                                    EasyLoading.dismiss();
                                    String status = res["reponse"]["status"];
                                    if (status == "success") {
                                      EasyLoading.dismiss();
                                      deleteFromCart(index: index);
                                      Navigator.pop(context);
                                    }
                                  });
                                });
                          },
                        );
                      })),
        ),
        Container(
          height: 60,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.white, Colors.grey[50]],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter)),
          child: Padding(
            padding: EdgeInsets.only(left: 15.0, right: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Net à payer",
                      style: TextStyle(
                          color: Colors.black54,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.0),
                    ),
                    SizedBox(
                      height: 3.0,
                    ),
                    Text(
                      "$cartTotal Fc",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0),
                    )
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 15),
                  height: 40,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Colors.green[500], Colors.green[700]]),
                      borderRadius: BorderRadius.circular(20)),
                  child: FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      onPressed: () async {
                        showAlertGetAdresseDialog(
                            context: context,
                            controller: adresseText,
                            title: "Veuillez entrer votre adresse !!",
                            onOk: () async {
                              if (adresseText.text == "") {
                                EasyLoading.showInfo(
                                    "vous devez entrer votre adresse !",
                                    duration: Duration(seconds: 1));
                                return;
                              } else if (cartTotal == 0) {
                                EasyLoading.showInfo(
                                    "vous pouvez pas effectuer cette action tant que votre panier est vide!",
                                    duration: Duration(seconds: 1));
                                return;
                              } else {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                EasyLoading.show();
                                await HttpService.confirmCommand(
                                        adress: adresseText.text)
                                    .then((value) {
                                  print(value);
                                  if (value["error"] != null) {
                                    EasyLoading.showInfo(
                                        "Echec de la confirmation de la commande, veuillez rééssayer SVP!",
                                        duration: Duration(seconds: 2));
                                  }
                                  if (value["reponse"]["status"] == "success") {
                                    EasyLoading.showSuccess(
                                        "votre commande est effectuée !",
                                        duration: Duration(seconds: 2));
                                    prefs.setString("pos_vente_id", "");
                                    prefs.setString("cartJsonArr", "[]");
                                    prefs.setInt("cart_count", 0);

                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                HomeScreenCost()),
                                        (Route<dynamic> route) => false);
                                  } else {
                                    EasyLoading.showInfo(
                                        "Echec de la confirmation de la commande, veuillez rééssayer SVP!",
                                        duration: Duration(seconds: 2));
                                  }
                                });
                              }
                            });
                      },
                      child: Text(
                        "commander".toUpperCase(),
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 1.5,
                            fontSize: 12.0),
                      )),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  cart() {
    FutureBuilder<List<Detail>>(
        future: CartManager.getCart(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/icons/panier.png",
                    fit: BoxFit.scaleDown,
                    height: 200,
                    width: 200,
                  ),
                  Text(
                    "Votre panier est vide !",
                    style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black87,
                        letterSpacing: 1.0),
                  ),
                ],
              ),
            );
          }
          if (snapshot.data == null) {
            return Center();
          } else {
            EasyLoading.dismiss();
            return ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: snapshot.data.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return CartItemWidget(
                    cartDetail: snapshot.data[index],
                    onDelete: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      String posVenteId = prefs.getString("pos_vente_id");
                      showAlertDialog(
                          content:
                              "Etes-vous sur de vouloir effacer ce produit du panier ?",
                          title: "Alert de suppression",
                          context: context,
                          onOk: () async {
                            EasyLoading.show();
                            await HttpService.deleteItemToCommand(
                                    posVenteId: posVenteId,
                                    produitId: snapshot.data[index].produitId)
                                .then((res) {
                              EasyLoading.dismiss();
                              String status = res["reponse"]["status"];
                              if (status == "success") {
                                EasyLoading.showToast(
                                    "vous venez d'enlever un produit dans votre panier !",
                                    duration: Duration(seconds: 2));
                                snapshot.data.removeAt(index);
                                for (int i = 0; i < snapshot.data.length; i++) {
                                  setState(() {
                                    cartTotal +=
                                        int.parse(snapshot.data[i].quantite) *
                                            int.parse(
                                                snapshot.data[i].prixUnitaire);
                                  });
                                }
                                Navigator.pop(context);
                              }
                            });
                          });
                    },
                  );
                });
          }
        });
  }
}
