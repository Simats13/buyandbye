import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:buyandbye/templates/buyandbye_app_theme.dart';
import 'package:dropdown_date_picker/dropdown_date_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class PageCBEdit extends StatefulWidget {
  final int expYear, expMonth;
  final VoidCallback newData;
  final Function(String) onNameChanged;
  final Function(String) onDateChanged;
  final String idCard,
      customerID,
      nameCard,
      newNameCard,
      streetCard,
      streetCard2,
      cityCard,
      postalCodeCard,
      stateCard;
  const PageCBEdit(
      {Key key,
      this.expYear,
      this.expMonth,
      this.idCard,
      this.customerID,
      this.nameCard,
      this.streetCard,
      this.streetCard2,
      this.cityCard,
      this.postalCodeCard,
      this.stateCard,
      this.newNameCard,
      this.newData,
      this.onDateChanged,
      this.onNameChanged})
      : super(key: key);

  @override
  _PageCBEditState createState() => _PageCBEditState();
}

class _PageCBEditState extends State<PageCBEdit> {
  String nameCardEdit,
      streetCardEdit,
      streetCard2Edit,
      postalCodeCardEdit,
      stateCardEdit,
      countryCardEdit,
      dropdownYear,
      dropdownMonth;

  int chooseYear, chooseMonth;
  var year = [];
  var month = [];
  bool isEnabled1 = false;
  bool isEnabled2 = false;
  bool isEnabled3 = false;
  bool isEnabled4 = false;
  bool isEnabled5 = false;
  bool isEnabled6 = false;
  bool isEnabled7 = false;
  // Controlleur des champs de texte. Remplace ceux crée précédemment
  TextEditingController nameCard = new TextEditingController();
  TextEditingController streetCard = new TextEditingController();
  TextEditingController streetCard2 = new TextEditingController();
  TextEditingController cityCard = new TextEditingController();
  TextEditingController postalCodeCard = new TextEditingController();
  TextEditingController stateCard = new TextEditingController();
  TextEditingController countryCard = new TextEditingController();
  final dateTime = DateTime.now();
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> paymentIntentData;
  List code = [
    "'AF','AX','AL','DZ','AS','AD','AO','AI','AQ','AG','AR','AM','AW','AU','AT','AZ','BS','BH','BD','BB','BY','BE','BZ','BJ','BM','BT','BA','BW','BV','BR','IO','BN','BG','BF','BI','KH','CM','CA','CV','KY','CF','TD','CL','CN','CX','CC','CO','KM','CG','CK','CR','CI','HR','CU','CW','CY','CZ','DK','DJ','DM','DO','EC','EG','SV','GQ','ER','EE','ET','FK','FO','FJ','FI','FR','GF','PF','TF','GA','GM','GE','DE','GH','GI','GR','GL','GD','GP','GU','GT','GG','GN','GW','GY','HT','HM','VA','HN','HK','HU','IS','IN','ID','IQ','IE','IM','IL','IT','JM','JP','JE','JO','KZ','KE','KI','KW','KG','LA','LV','LB','LS','LR','LY','LI','LT','LU','MO','MG','MW','MY','MV','ML','MT','MH','MQ','MR','MU','YT','MX','MC','MN','ME','MS','MA','MZ','MM','NA','NR','NP','NL','NC','NZ','NI','NE','NG','NU','NF','MP','NO','OM','PK','PW','PA','PG','PY','PE','PH','PN','PL','PT','PR','QA','RE','RO','RU','RW','BL','KN','LC','MF','PM','VC','WS','SM','ST','SA','SN','RS','SC','SL','SG','SX','SK','SI','SB','SO','ZA','GS','SS','ES','LK','SD','SR','SJ','SZ','SE','CH','SY','TJ','TH','TL','TG','TK','TO','TT','TN','TR','TM','TC','TV','UG','UA','AE','GB','US','UM','UY','UZ','VU','VN','WF','EH','YE','ZM','ZW',"
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    for (var i = dateTime.year; i < dateTime.year + 20; i++) {
      year.add(i.toString());
    }
    for (var i = 1; i <= 12; i++) {
      month.add(i.toString());
    }
    dropdownYear = widget.expYear.toString();
    dropdownMonth = widget.expMonth.toString();
    print(widget.nameCard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BuyandByeAppTheme.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: AppBar(
          leading: IconButton(
            icon:
                Icon(Icons.arrow_back, color: BuyandByeAppTheme.orangeMiFonce),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: RichText(
            text: TextSpan(
              // style: Theme.of(context).textTheme.bodyText2,
              children: [
                TextSpan(
                    text: 'Modification informations CB',
                    style: TextStyle(
                      fontSize: 15,
                      color: BuyandByeAppTheme.orangeMiFonce,
                      fontWeight: FontWeight.bold,
                    )),
                WidgetSpan(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Icon(
                      Icons.credit_card,
                      color: BuyandByeAppTheme.orangeMiFonce,
                      size: 25,
                    ),
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: BuyandByeAppTheme.white,
          automaticallyImplyLeading: false,
          elevation: 0.0,
          bottomOpacity: 0.0,
          actions: [
            Padding(
                padding: EdgeInsets.only(right: 20),
                child: GestureDetector(
                  onTap: () async {
                    try {
                      Platform.isIOS
                          ? showCupertinoDialog(
                              context: context,
                              builder: (context) => CupertinoAlertDialog(
                                    title: Text(
                                        "Suppression de la carte bancaire"),
                                    content: Text(
                                        "Souhaitez-vous réellement supprimer la carte bancaire ?"),
                                    actions: [
                                      // Close the dialog
                                      CupertinoButton(
                                          child: Text('Annuler'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          }),
                                      CupertinoButton(
                                        child: Text(
                                          'Suppression',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        onPressed: () async {
                                          Navigator.of(context).pop(false);
                                          Navigator.of(context).pop(false);
                                        },
                                      )
                                    ],
                                  ))
                          : showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text("Suppression de la carte bancaire"),
                                content: Text(
                                    "Souhaitez-vous réellement supprimer la carte bancaire ?"),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text("Annuler"),
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                  ),
                                  TextButton(
                                    child: Text(
                                      'Suppression',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    onPressed: () async {
                                      Navigator.of(context).pop(false);
                                    },
                                  ),
                                ],
                              ),
                            );
                    } catch (e) {
                      print(e);
                    }
                  },
                  child: Icon(Icons.delete_forever, color: Colors.red),
                ))
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(5, 0, 0, 5),
                child: SizedBox(
                  height: 70,
                  width: MediaQuery.of(context).size.width - 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Text("Mois d'expiration "),
                          Platform.isIOS
                              ? TextButton(
                                  child: Row(
                                    children: [
                                      Text(dropdownMonth,
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black)),
                                      SizedBox(width: 10),
                                      Icon(Icons.arrow_drop_down,
                                          size: 30, color: Colors.black)
                                    ],
                                  ),
                                  onPressed: () {
                                    showCupertinoModalPopup(
                                      context: context,
                                      builder: (context) => Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 200,
                                        child: CupertinoPicker(
                                          itemExtent: 50,
                                          backgroundColor: Colors.white,
                                          children: [
                                            for (String name in month)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8.0),
                                                child: Text(
                                                  name,
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ),
                                          ],
                                          onSelectedItemChanged: (value) {
                                            setState(() {
                                              dropdownMonth = month[value];
                                            });
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : DropdownButton<String>(
                                  value: dropdownMonth,
                                  icon: const Icon(
                                      Icons.keyboard_arrow_down_rounded),
                                  iconSize: 24,
                                  elevation: 16,
                                  onChanged: (newValue) {
                                    setState(() {
                                      dropdownMonth = newValue;
                                    });
                                  },
                                  items: month.map((map) {
                                    return DropdownMenuItem(
                                      child: Text(map),
                                      value: map,
                                    );
                                  }).toList(),
                                ),
                        ],
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        children: [
                          Text("Année d'expiration"),
                          Platform.isIOS
                              ? TextButton(
                                  child: Row(
                                    children: [
                                      Text(dropdownYear,
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black)),
                                      SizedBox(width: 10),
                                      Icon(Icons.arrow_drop_down,
                                          size: 30, color: Colors.black)
                                    ],
                                  ),
                                  onPressed: () {
                                    showCupertinoModalPopup(
                                      context: context,
                                      builder: (context) => Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 200,
                                        child: CupertinoPicker(
                                            itemExtent: 50,
                                            backgroundColor: Colors.white,
                                            onSelectedItemChanged: (value) {
                                              setState(() {
                                                dropdownYear = year[value];
                                                print(dropdownYear);
                                              });
                                            },
                                            children: [
                                              for (String name in year)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 8.0),
                                                  child: Text(name,
                                                      style: TextStyle(
                                                          color: Colors.black)),
                                                )
                                            ]),
                                      ),
                                    );
                                  },
                                )
                              : DropdownButton(
                                  value: dropdownYear,
                                  icon: const Icon(
                                      Icons.keyboard_arrow_down_rounded),
                                  iconSize: 24,
                                  elevation: 16,
                                  onChanged: (newValue) {
                                    setState(() {
                                      dropdownYear = newValue.toString();
                                    });
                                  },
                                  items: year.map((map) {
                                    return DropdownMenuItem(
                                      child: Text(map),
                                      value: map,
                                    );
                                  }).toList(),
                                ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                color: null,
                thickness: 2,
                indent: 10,
                endIndent: 10,
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(5, 0, 0, 5),
                child: SizedBox(
                  height: 50,
                  width: MediaQuery.of(context).size.width - 50,
                  child: Container(
                    child: TextFormField(
                      // initialValue: widget.nameCard,
                      onChanged: (value) {
                        setState(() {
                          if (value.length > 0) {
                            isEnabled1 = true;
                          } else {
                            isEnabled1 = false;
                          }
                        });
                      },
                      controller: nameCard,
                      autofocus: false,
                      style: TextStyle(fontSize: 15.0),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        suffixIcon: isEnabled1
                            ? IconButton(
                                onPressed: () {
                                  setState(() {
                                    nameCard.clear();
                                    isEnabled1 = !isEnabled1;
                                  });
                                },
                                icon: Icon(Icons.clear),
                              )
                            : null,
                        filled: true,
                        labelText: "Nom du titulaire de la carte",
                        fillColor: Colors.grey.withOpacity(0.15),
                        contentPadding: const EdgeInsets.only(
                            left: 14.0, bottom: 6.0, top: 8.0),
                      ),
                    ),
                  ),
                ),
              ),
              // Padding(
              //   padding: EdgeInsets.fromLTRB(5, 0, 0, 5),
              //   child: SizedBox(
              //     height: 50,
              //     width: MediaQuery.of(context).size.width - 50,
              //     child: Container(
              //       child: TextFormField(
              //         // initialValue: widget.streetCard,
              //         onChanged: (value) {
              //           setState(() {
              //             if (value.length > 0) {
              //               isEnabled2 = true;
              //             } else {
              //               isEnabled2 = false;
              //             }
              //           });
              //         },
              //         controller: streetCard,
              //         autofocus: false,
              //         style: TextStyle(fontSize: 15.0),
              //         decoration: InputDecoration(
              //           border: InputBorder.none,
              //           filled: true,
              //           suffixIcon: isEnabled2
              //               ? IconButton(
              //                   onPressed: () {
              //                     setState(() {
              //                       streetCard.clear();
              //                       isEnabled2 = !isEnabled2;
              //                     });
              //                   },
              //                   icon: Icon(Icons.clear),
              //                 )
              //               : null,
              //           labelText: "Rue",
              //           fillColor: Colors.grey.withOpacity(0.15),
              //           contentPadding: const EdgeInsets.only(
              //               left: 14.0, bottom: 6.0, top: 8.0),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              // Padding(
              //   padding: EdgeInsets.fromLTRB(5, 0, 0, 5),
              //   child: SizedBox(
              //     height: 50,
              //     width: MediaQuery.of(context).size.width - 50,
              //     child: Container(
              //       child: TextFormField(
              //         // initialValue: widget.streetCard2,
              //         onChanged: (value) {
              //           setState(() {
              //             if (value.length > 0) {
              //               isEnabled3 = true;
              //             } else {
              //               isEnabled3 = false;
              //             }
              //           });
              //         },
              //         autofocus: false,
              //         controller: streetCard2,
              //         style: TextStyle(fontSize: 15.0),
              //         decoration: InputDecoration(
              //           border: InputBorder.none,
              //           suffixIcon: isEnabled3
              //               ? IconButton(
              //                   onPressed: () {
              //                     setState(() {
              //                       streetCard2.clear();
              //                       isEnabled3 = !isEnabled3;
              //                     });
              //                   },
              //                   icon: Icon(Icons.clear),
              //                 )
              //               : null,
              //           labelText: "Rue (Ligne 2)",
              //           filled: true,
              //           fillColor: Colors.grey.withOpacity(0.15),
              //           contentPadding: const EdgeInsets.only(
              //               left: 14.0, bottom: 6.0, top: 8.0),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              // Padding(
              //   padding: EdgeInsets.fromLTRB(5, 0, 0, 5),
              //   child: SizedBox(
              //     height: 50,
              //     width: MediaQuery.of(context).size.width - 50,
              //     child: Container(
              //       child: TextFormField(
              //         onChanged: (value) {
              //           setState(() {
              //             if (value.length > 0) {
              //               isEnabled4 = true;
              //             } else {
              //               isEnabled4 = false;
              //             }
              //           });
              //         },
              //         autofocus: false,
              //         controller: cityCard,
              //         style: TextStyle(fontSize: 15.0),
              //         decoration: InputDecoration(
              //           border: InputBorder.none,
              //           suffixIcon: isEnabled4
              //               ? IconButton(
              //                   onPressed: () {
              //                     setState(() {
              //                       cityCard.clear();
              //                       isEnabled4 = !isEnabled4;
              //                     });
              //                   },
              //                   icon: Icon(Icons.clear),
              //                 )
              //               : null,
              //           labelText: "Ville",
              //           filled: true,
              //           fillColor: Colors.grey.withOpacity(0.15),
              //           contentPadding: const EdgeInsets.only(
              //               left: 14.0, bottom: 6.0, top: 8.0),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              // Padding(
              //   padding: EdgeInsets.fromLTRB(5, 0, 0, 5),
              //   child: SizedBox(
              //     height: 50,
              //     width: MediaQuery.of(context).size.width - 50,
              //     child: Container(
              //       child: TextFormField(
              //         onChanged: (value) {
              //           setState(() {
              //             if (value.length > 0) {
              //               isEnabled5 = true;
              //             } else {
              //               isEnabled5 = false;
              //             }
              //           });
              //         },
              //         autofocus: false,
              //         controller: postalCodeCard,
              //         style: TextStyle(fontSize: 15.0),
              //         decoration: InputDecoration(
              //           border: InputBorder.none,
              //           suffixIcon: isEnabled5
              //               ? IconButton(
              //                   onPressed: () {
              //                     setState(() {
              //                       postalCodeCard.clear();
              //                       isEnabled5 = !isEnabled5;
              //                     });
              //                   },
              //                   icon: Icon(Icons.clear),
              //                 )
              //               : null,
              //           labelText: "Code postal",
              //           filled: true,
              //           fillColor: Colors.grey.withOpacity(0.15),
              //           contentPadding: const EdgeInsets.only(
              //               left: 14.0, bottom: 6.0, top: 8.0),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              // Padding(
              //   padding: EdgeInsets.fromLTRB(5, 0, 0, 5),
              //   child: SizedBox(
              //     height: 50,
              //     width: MediaQuery.of(context).size.width - 50,
              //     child: Container(
              //       child: TextFormField(
              //         onChanged: (value) {
              //           setState(() {
              //             if (value.length > 0) {
              //               isEnabled6 = true;
              //             } else {
              //               isEnabled6 = false;
              //             }
              //           });
              //         },
              //         autofocus: false,
              //         controller: stateCard,
              //         style: TextStyle(fontSize: 15.0),
              //         decoration: InputDecoration(
              //           border: InputBorder.none,
              //           suffixIcon: isEnabled6
              //               ? IconButton(
              //                   onPressed: () {
              //                     setState(() {
              //                       stateCard.clear();
              //                       isEnabled6 = !isEnabled6;
              //                     });
              //                   },
              //                   icon: Icon(Icons.clear),
              //                 )
              //               : null,
              //           labelText: "Département",
              //           filled: true,
              //           fillColor: Colors.grey.withOpacity(0.15),
              //           contentPadding: const EdgeInsets.only(
              //               left: 14.0, bottom: 6.0, top: 8.0),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.black,
                      textStyle:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    var date = dropdownMonth + '/' + dropdownYear;

                    // Si un champ est vide, on envoi la valeur déjà présente
                    var nameCardEdit =
                        nameCard.text == "" ? widget.nameCard : nameCard.text;

                    var streetCardEdit = streetCard.text == ""
                        ? widget.streetCard
                        : streetCard.text;

                    var streetCard2Edit = streetCard2.text == ""
                        ? widget.streetCard2
                        : streetCard2.text;
                    var cityCardEdit =
                        cityCard.text == "" ? widget.cityCard : cityCard.text;
                    var postalCodeCardEdit =
                        cityCard.text == "" ? widget.cityCard : cityCard.text;
                    var stateCardEdit = stateCard.text == ""
                        ? widget.stateCard
                        : stateCard.text;

                    widget.onNameChanged(nameCardEdit);
                    // widget.onDateChanged(date);

                    // Validate returns true if the form is valid, or false otherwise.

                    final isValid = _formKey.currentState.validate();

                    if (isValid) {
                      _formKey.currentState.save();
                      final url =
                          "https://us-central1-oficium-11bf9.cloudfunctions.net/app/update_cards?customerCard=${widget.customerID}&idCard=${widget.idCard}&monthCard=$dropdownMonth&yearCard=$dropdownYear&nameCard=$nameCardEdit";

                      final response = await http.post(
                        Uri.parse(url),
                        headers: {
                          'Content-Type': 'application/json',
                        },
                        body: json.encode({
                          'a': 'a',
                        }),
                      );
                      widget.newData();
                      paymentIntentData = jsonDecode(response.body);
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Enregistrer et continuer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
