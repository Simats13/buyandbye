import 'package:buyandbye/services/provider.dart';
import 'package:flutter/material.dart';
import 'package:buyandbye/templates/buyandbye_app_theme.dart';
import 'package:buyandbye/theme/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Help extends StatefulWidget {
  @override
  _HelpState createState() => _HelpState();
  const Help(this.isAdmin, {Key? key}) : super(key: key);
  final bool isAdmin;
}

class _HelpState extends State<Help> {
  bool isVisible1 = false;
  bool isVisible2 = false;
  bool isVisible3 = false;
  String? email;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return StreamBuilder<dynamic>(
        stream: ProviderUserInfo().returnData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            email = snapshot.data["email"];
          }
          return Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: BuyandByeAppTheme.white,
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(50.0),
                child: AppBar(
                  title: const Text(
                    'Aide / Support',
                    style: TextStyle(
                      color: BuyandByeAppTheme.orangeMiFonce,
                    ),
                  ),
                  backgroundColor: BuyandByeAppTheme.white,
                  automaticallyImplyLeading: false,
                  elevation: 0.0,
                  bottomOpacity: 0.0,
                  leading: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: BuyandByeAppTheme.orange,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      //Une question ?
                      Container(
                        width: size.width,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), border: Border.all(color: black.withOpacity(0.2))),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Column(
                                children: const [
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    "Une question ?",
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                              Container(
                                height: 60,
                                width: 60,
                                margin: const EdgeInsets.only(top: 30, bottom: 30),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                        borderRadius: BorderRadius.circular(100),
                                        child: const Center(
                                          child: Icon(
                                            Icons.question_answer_rounded,
                                            size: 50,
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                              TextButton(
                                style: const ButtonStyle(),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Foire aux questions",
                                      style: TextStyle(fontSize: 20, color: BuyandByeAppTheme.orange),
                                    ),
                                    Icon(
                                      //Si la suite est affichée, la flèche pointe vers le bas
                                      //Sinon elle pointe vers la gauche
                                      isVisible1 ? Icons.arrow_drop_down : Icons.arrow_left,
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
                              Visibility(
                                visible: isVisible1,
                                child: Question(widget.isAdmin),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      //Une suggestion ?
                      Container(
                        width: size.width,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), border: Border.all(color: black.withOpacity(0.2))),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Column(
                                children: const [
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    "Une suggestion ?",
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                              Container(
                                height: 60,
                                width: 60,
                                margin: const EdgeInsets.only(top: 30, bottom: 30),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                        borderRadius: BorderRadius.circular(100),
                                        child: const Center(
                                          child: Icon(
                                            Icons.chat,
                                            size: 50,
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                              TextButton(
                                style: const ButtonStyle(),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Ecrivez-nous",
                                      style: TextStyle(fontSize: 20, color: BuyandByeAppTheme.orange),
                                    ),
                                    Icon(
                                      isVisible2 ? Icons.arrow_drop_down : Icons.arrow_left,
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
                                    children: [Formulaire(email)],
                                  ))
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      //Un problème ?
                      Container(
                        width: size.width,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), border: Border.all(color: black.withOpacity(0.2))),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Column(
                                children: const [
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    "Un problème ?",
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                              Container(
                                height: 60,
                                width: 60,
                                margin: const EdgeInsets.only(top: 30, bottom: 30),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                        borderRadius: BorderRadius.circular(100),
                                        child: const Center(
                                          child: Icon(
                                            Icons.contact_support,
                                            size: 50,
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                              TextButton(
                                style: const ButtonStyle(),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Contactez le support",
                                      style: TextStyle(fontSize: 20, color: BuyandByeAppTheme.orange),
                                    ),
                                    Icon(
                                      isVisible3 ? Icons.arrow_drop_down : Icons.arrow_left,
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
                              Visibility(visible: isVisible3, child: Formulaire2(email)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ));
        });
  }
}

//Classe pour l'affichage de la FAQ depuis la base de données
class Question extends StatefulWidget {
  @override
  _QuestionState createState() => _QuestionState();
  const Question(this.isAdmin, {Key? key}) : super(key: key);
  final bool isAdmin;
}

class _QuestionState extends State<Question> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: ProviderGetFAQ().returnData(widget.isAdmin),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          return ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: (snapshot.data! as QuerySnapshot).docs.length,
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 25),
                    Text(snapshot.data.docs[index]['question'],
                        textAlign: TextAlign.justify, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 15),
                    Text(snapshot.data.docs[index]['answer'],
                        textAlign: TextAlign.justify,
                        style: const TextStyle(
                          fontSize: 16,
                        )),
                  ],
                );
              });
        });
  }
}

class MyTextFormField extends StatelessWidget {
  final Function? validator;
  final Function? onSaved;

  const MyTextFormField({
    Key? key,
    this.validator,
    this.onSaved,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(15.0),
          border: InputBorder.none,
          filled: true,
          fillColor: Colors.grey[200],
        ),
        validator: validator as String? Function(String?)?,
        onSaved: onSaved as void Function(String?)?,
      ),
    );
  }
}

//Classe pour le formulaire de suggestion
class Formulaire extends StatefulWidget {
  @override
  _FormulaireState createState() => _FormulaireState();
  const Formulaire(this.email, {Key? key}) : super(key: key);
  final String? email;
}

class _FormulaireState extends State<Formulaire> {
  final _formKey = GlobalKey<FormState>();
  String? email;
  String? suggestion;

  addData() {
    Map<String, dynamic> userData = {"email": widget.email, "message": suggestion, "date": DateTime.now()};

    CollectionReference collectionReference = FirebaseFirestore.instance.collection('suggestions');
    collectionReference.add(userData);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 15),
            const Text("Votre suggestion :", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            MyTextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez écrire un message';
                }
              },
              onSaved: (String? value) {
                suggestion = value;
              },
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              child: const Text('Envoyer'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  addData();
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(content: const Text("Merci pour votre retour !"), actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("Fermer"))
                        ]);
                      });
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ));
  }
}

//Classe pour le formulaire de support

class Formulaire2 extends StatefulWidget {
  @override
  _Formulaire2State createState() => _Formulaire2State();
  const Formulaire2(this.email, {Key? key}) : super(key: key);
  final String? email;
}

class _Formulaire2State extends State<Formulaire2> {
  final _formKey = GlobalKey<FormState>();
  String? email;
  String? problemType;
  String? problem;

  addData2() {
    Map<String, dynamic> userData = {"email": widget.email, "Numéro de problème": problemType, "Problème": problem, "date": DateTime.now()};
    CollectionReference writeProblems = FirebaseFirestore.instance.collection('problems');
    writeProblems.add(userData);
  }

  //Initialisation de la DropDownList
  List<DropdownMenuItem<String>> problems = [];
  String? def;
  void listProblems() {
    problems.clear();
    problems.add(const DropdownMenuItem(value: "1", child: Text("Problème 1", style: TextStyle(fontSize: 18))));
    problems.add(const DropdownMenuItem(value: "2", child: Text("Problème 2", style: TextStyle(fontSize: 18))));
    problems.add(const DropdownMenuItem(value: "3", child: Text("Problème 3", style: TextStyle(fontSize: 18))));
  }

  bool nullType = false;
  @override
  Widget build(BuildContext context) {
    listProblems();
    return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 15),
            const Text("Quel type de problème ?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 15),
            //Menu déroulant
            DropdownButton(
                value: def,
                elevation: 2,
                items: problems,
                hint: const Text("Nature du problème", style: TextStyle(fontSize: 18)),
                onChanged: (dynamic value) {
                  def = value;
                  problemType = value;
                  setState(() {});
                }),
            const SizedBox(height: 15),
            nullType
                ? const Text("Veuillez sélectionner le type de problème", style: TextStyle(fontSize: 12.5, color: Color.fromRGBO(210, 40, 40, 1)))
                : const SizedBox.shrink(),
            const SizedBox(height: 15),
            const Text("Décrivez votre problème :", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            MyTextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un message';
                }
                return null;
              },
              onSaved: (value) {
                problem = value;
              },
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                if (problemType != null) {
                  setState(() {
                    nullType = false;
                  });
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    addData2();
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(content: const Text("Merci pour votre retour !"), actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("Fermer"))
                          ]);
                        });
                    Navigator.pop(context);
                  }
                } else {
                  setState(() {
                    nullType = true;
                  });
                }
              },
              child: const Text('Envoyer'),
            ),
          ],
        ));
  }
}
