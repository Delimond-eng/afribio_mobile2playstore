import 'package:afribio/manager/global_manager.dart';
import 'package:afribio/models/user_commande_model.dart';
import 'package:afribio/screens/home_screen_costumer.dart';
import 'package:afribio/services/http_service.dart';
import 'package:afribio/utilities/globals.dart';
import 'package:afribio/widgets/commande_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shimmer/shimmer.dart';

class UserCommandePage extends StatefulWidget {
  UserCommandePage({Key key}) : super(key: key);

  @override
  _UserCommandePageState createState() => _UserCommandePageState();
}

class _UserCommandePageState extends State<UserCommandePage> {
  int total = 0;
  final GlobalManager manager = GlobalManager();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          brightness: Brightness.light,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.person_rounded,
                size: 20,
                color: Colors.black87,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                "Mon afribio",
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15.0,
                    letterSpacing: 2,
                    color: Colors.black87),
              ),
            ],
          ),
        ),
        body: Padding(
          padding: EdgeInsets.only(top: 2, bottom: 2),
          child: FutureBuilder<UserCommands>(
            future: HttpService.getUserCommandes(),
            builder: (context, AsyncSnapshot<UserCommands> snapshot) {
              if (snapshot.data == null) {
                return Center(child: Text("Chargement..."));
              }
              else if(snapshot.data.commandes.isEmpty){
                return Center(child: Text("Empty"),);
              }
              else if (snapshot.hasData) {
                return RefreshIndicator(
                  onRefresh: onRefresh,
                  child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: snapshot.data.commandes.length,
                      itemBuilder: (context, index) {
                        return CommandeCard(
                          commandes: snapshot.data,
                          index: index,
                          onCancel: () {
                            showAlertDialog(
                                context: context,
                                title: "Annulation",
                                content: "Etes-vous sûr de vouloir annuler votre commande ?",
                                onOk: () async {
                                  try {
                                    EasyLoading.show();
                                    await HttpService.cancelCommand(
                                        posVenteId: snapshot.data
                                            .commandes[index].posVenteId)
                                        .then((resp) {
                                      String status = resp["reponse"]["status"];
                                      if (status == "success") {
                                        EasyLoading.showSuccess(
                                            "votre commande a été annulée !",
                                            duration: Duration(seconds: 1));
                                      }
                                    });
                                  }
                                  catch (e) {
                                    print(e);
                                  }
                                  finally {
                                    Navigator.pop(context);
                                  }
                                }
                            );
                          },
                        );
                      }
                  ),
                );
              }else return Center(child: Text("Empty"),);
            }
          )
        ));
  }
  Future<Null> onRefresh() async {
    await Future.delayed(Duration(seconds: 8));
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => HomeScreenCost()),
            (Route<dynamic> route) => false);
    return null;
  }
}
