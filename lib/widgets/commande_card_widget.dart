import 'package:afribio/models/user_commande_model.dart';
import 'package:flutter/material.dart';

class CommandeCard extends StatelessWidget {
  final UserCommands commandes;
  final int total;
  final Function onCancel;
  final index;

  CommandeCard({Key key, this.commandes, this.total, this.onCancel, this.index})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 5, left: 5, right: 5),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 180,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(left: 10, right: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color:Colors.grey[300],
                  )
                )
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Colors.red, Colors.orangeAccent]),
                        borderRadius: BorderRadius.circular(10)),
                    margin: EdgeInsets.only(left: 0, right: 5),
                    padding:
                        EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                    child: Row(
                      children: [
                        Icon(
                          Icons.departure_board_rounded,
                          color: Colors.white,
                          size: 15,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "Livraison dans ${commandes.commandes[index].delaiLivraison}",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 12.0,
                              letterSpacing: 1.0),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 2),
                    width: 120,
                    child: OutlineButton(
                      child: Text("Annuler", style: TextStyle(color: Colors.red[300]),),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                        ),
                        borderSide: BorderSide(
                          color: Colors.red[300],
                          width: 1
                        ),
                        disabledBorderColor: Colors.red[300],
                        onPressed: onCancel,
                    ),
                  )

                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: commandes.commandes[index].details.length,
                  itemBuilder: (context, i) {
                    return Container(
                      height: 100,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey[400], width: 1),
                          borderRadius: BorderRadius.circular(8)),
                      margin: EdgeInsets.all(5),
                      width: MediaQuery.of(context).size.width / 4,
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child: Center(
                              child: Image.network(
                                commandes.commandes[index].details[i].image.replaceAll("http", "https"),
                                width: 50,
                                height: 50,
                                fit: BoxFit.scaleDown,
                              ),
                            )),
                            Text(
                              commandes.commandes[index].details[i].titre,
                              style: TextStyle(
                                  color: Colors.green[900],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.0),
                            ),
                            SizedBox(
                              height: 2,
                            ),
                            Text(
                              "Prix: ${commandes.commandes[index].details[i].prixUnitaire}Fc",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.0,
                                  fontSize: 10),
                            ),
                            SizedBox(
                              height: 2,
                            ),
                            Text(
                              "QTE: ${commandes.commandes[index].details[i].quantite} Kg",
                              style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                  fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
