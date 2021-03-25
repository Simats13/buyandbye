import 'package:flutter/material.dart';
import 'package:oficihome/services/auth.dart';
import 'package:oficihome/services/database.dart';
import 'package:oficihome/templates/oficihome_app_theme.dart';
import 'package:oficihome/templates/pages/pageCompte.dart';
import 'package:oficihome/theme/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(Help());

class Help extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Aide / Support",
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

//Récupération de la collection FAQ
Future getQuestions() async {
  List questionsList = [];
  try {
    await FirebaseFirestore.instance
        .collection('FAQ')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        questionsList.add(element.data());
      });
    });
    return questionsList;
  } catch (e) {
    print(e.toString());
    return null;
  }
}

List questions = [];

class _MyHomePageState extends State<MyHomePage> {
  bool isVisible1 = false;
  bool isVisible2 = false;
  bool isVisible3 = false;

  fetchDatabaseList() async {
    dynamic result = await AuthMethods().getMagasin();
    if (result == null) {
      print('Impossible de retrouver les données');
    } else {
      setState(() {
        questions = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text("Aide / Support", style: TextStyle(color: Colors.black)),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 1,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: OficihomeAppTheme.orange,
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => PageCompte()));
            },
          ),
        ),
        body: FutureBuilder(
          future: DatabaseMethods().getFAQ(),
          builder: (context, snapshot) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  children: [
                    //Une question ?
                    Container(
                      width: size.width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: black.withOpacity(0.2))),
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Column(
                              children: [
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  "Une question ?",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            Container(
                              height: 60,
                              width: 60,
                              margin: EdgeInsets.only(top: 30, bottom: 30),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: Center(
                                        child: Icon(
                                          Icons.question_answer_rounded,
                                          size: 50,
                                        ),
                                      )),
                                ],
                              ),
                            ),
                            TextButton(
                              style: ButtonStyle(),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Foire aux questions",
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.black),
                                  ),
                                  Icon(
                                    //Si la suite est affichée, la flèche pointe vers le bas
                                    //Sinon elle pointe vers la gauche
                                    isVisible1
                                        ? Icons.arrow_drop_down
                                        : Icons.arrow_left,
                                    size: 25,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                              onPressed: () {
                                setState(() {
                                  isVisible1 = !isVisible1;
                                });
                              },
                            ),
                            //Partie cachée
                            Visibility(visible: isVisible1, child: Question())
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    //Une suggestion ?
                    Container(
                      width: size.width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: black.withOpacity(0.2))),
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Column(
                              children: [
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  "Une suggestion ?",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            Container(
                              height: 60,
                              width: 60,
                              margin: EdgeInsets.only(top: 30, bottom: 30),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: Center(
                                        child: Icon(
                                          Icons.chat,
                                          size: 50,
                                        ),
                                      )),
                                ],
                              ),
                            ),
                            TextButton(
                              style: ButtonStyle(),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Ecrivez-nous",
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.black),
                                  ),
                                  Icon(
                                    isVisible2
                                        ? Icons.arrow_drop_down
                                        : Icons.arrow_left,
                                    size: 25,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                              onPressed: () {
                                setState(() {
                                  isVisible2 = !isVisible2;
                                });
                              },
                            ),
                            //Partie cachée
                            Visibility(
                                visible: isVisible2,
                                child: Column(
                                  children: [Formulaire()],
                                ))
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    //Un problème ?
                    Container(
                      width: size.width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: black.withOpacity(0.2))),
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Column(
                              children: [
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  "Un problème ?",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            Container(
                              height: 60,
                              width: 60,
                              margin: EdgeInsets.only(top: 30, bottom: 30),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: Center(
                                        child: Icon(
                                          Icons.contact_support,
                                          size: 50,
                                        ),
                                      )),
                                ],
                              ),
                            ),
                            TextButton(
                              style: ButtonStyle(),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Contactez le support",
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.black),
                                  ),
                                  Icon(
                                    isVisible3
                                        ? Icons.arrow_drop_down
                                        : Icons.arrow_left,
                                    size: 25,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                              onPressed: () {
                                setState(() {
                                  isVisible3 = !isVisible3;
                                });
                              },
                            ),
                            //Partie cachée
                            Visibility(
                                visible: isVisible3, child: Formulaire2())
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            );
          },
        ));
  }
}

//Classe pour l'affichage de la FAQ depuis la base de données
class Question extends StatefulWidget {
  @override
  _QuestionState createState() => _QuestionState();
}

class _QuestionState extends State<Question> {
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: DatabaseMethods().getFAQ(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Text('chargement en cours...');
          return ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 25),
                    Text(snapshot.data.docs[index]['question'],
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500)),
                    SizedBox(height: 15),
                    Text(snapshot.data.docs[index]['answer'],
                        style: TextStyle(fontSize: 16)),
                  ],
                );
              });
        });
  }
}

class MyTextFormField extends StatelessWidget {
  final Function validator;
  final Function onSaved;

  MyTextFormField({
    this.validator,
    this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: TextFormField(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(15.0),
          border: InputBorder.none,
          filled: true,
          fillColor: Colors.grey[200],
        ),
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }
}

//Classe pour le formulaire de suggestion

class Formulaire extends StatefulWidget {
  @override
  _FormulaireState createState() => _FormulaireState();
}

class _FormulaireState extends State<Formulaire> {
  final _formKey = GlobalKey<FormState>();
  String email;
  String suggestion;

  addData() {
    Map<String, dynamic> userData = {
      "email": email,
      "message": suggestion,
      "date": DateTime.now()
    };

    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection('suggestions');
    collectionReference.add(userData);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 15),
            Text("E-mail :",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            SizedBox(height: 10),
            MyTextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre e-mail';
                }
                if (!value.contains('@')) {
                  return 'Mail invalide';
                }
                return null;
              },
              onSaved: (String value) {
                email = value;
              },
            ),
            SizedBox(height: 15),
            Text("Votre suggestion :",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            SizedBox(height: 10),
            MyTextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez écrire un message';
                }
                return null;
              },
              onSaved: (String value) {
                suggestion = value;
              },
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  addData();
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                            content: Text("Merci pour votre retour !"));
                      });
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => PageCompte()));
                }
              },
              child: Text('Envoyer'),
            ),
          ],
        ));
  }
}

//Classe pour le formulaire de support

class Formulaire2 extends StatefulWidget {
  @override
  _Formulaire2State createState() => _Formulaire2State();
}

class _Formulaire2State extends State<Formulaire2> {
  final _formKey = GlobalKey<FormState>();
  String email;
  String problemType;
  String problem;

  addData2() {
    Map<String, dynamic> userData = {
      "email": email,
      "Numéro de problème": problemType,
      "Problème": problem,
      "date": DateTime.now()
    };

    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection('problems');
    collectionReference.add(userData);
  }

  //Initialisation de la DropDownList
  List<DropdownMenuItem<String>> problems = [];
  String def;
  void listProblems() {
    problems.clear();
    problems.add(DropdownMenuItem(
        value: "1",
        child: Text("Problème 1",
            style: TextStyle(fontSize: 18, color: Colors.black))));
    problems.add(DropdownMenuItem(
        value: "2",
        child: Text("Problème 2",
            style: TextStyle(fontSize: 18, color: Colors.black))));
    problems.add(DropdownMenuItem(
        value: "3",
        child: Text("Problème 3",
            style: TextStyle(fontSize: 18, color: Colors.black))));
  }

  @override
  Widget build(BuildContext context) {
    listProblems();
    return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 15),
            Text("E-mail :",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            SizedBox(height: 10),
            MyTextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre e-mail';
                }
                if (!value.contains('@')) {
                  return 'Mail invalide';
                }
                return null;
              },
              onSaved: (String value) {
                email = value;
              },
            ),
            SizedBox(height: 15),
            Text("Quel type de problème ?",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            SizedBox(height: 15),
            //Menu déroulant
            DropdownButton(
                value: def,
                elevation: 2,
                items: problems,
                hint: Text("Nature du problème",
                    style: TextStyle(fontSize: 18, color: Colors.black)),
                onChanged: (value) {
                  def = value;
                  problemType = value;
                  setState(() {});
                }),
            //
            SizedBox(height: 15),
            Text("Décrivez votre problème :",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            SizedBox(height: 10),
            MyTextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un message';
                }
                return null;
              },
              onSaved: (String value) {
                problem = value;
              },
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  addData2();
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                            content: Text("Merci pour votre retour !"));
                      });
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => PageCompte()));
                }
              },
              child: Text('Envoyer'),
            ),
          ],
        ));
  }
}
