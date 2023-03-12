import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:client/screens/client.dart';

FirebaseAuth auth= FirebaseAuth.instance;
class AddContractor extends StatefulWidget {
  const AddContractor({Key? key}) : super(key: key);

  @override
  State<AddContractor> createState() => _AddContractorState();
}

class _AddContractorState extends State<AddContractor> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final gitController = TextEditingController();
  final addedContractorsRef = FirebaseDatabase.instance.reference().child("addedContractors");
  User? usr = auth.currentUser;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    gitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Enter Contractor's Full Name",
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0)
                    )
                  ),
                  validator: (value){
                    if(value!.isEmpty){
                      return "Name can not be empty";
                    }
                    else if(!RegExp(r"^[a-z ,.\'-]+$").hasMatch(value)){
                      return "Please Enter valid Full Name";
                    } else{
                      return null;
                    }
                  },
                  onSaved: (value){
                    nameController.text =value!;
                  },
                  keyboardType: TextInputType.text,
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Enter Contractor's Email",
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0)
                    )
                  ),
                  validator: (value){
                    if(value!.isEmpty){
                      return "Email can not be Empty";
                    }else  if(!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]").hasMatch(value)){
                      return "Please Enter valid Email";
                    }else{
                      return null;
                    }
                  },
                  onSaved: (value){
                    emailController.text = value!;
                  },
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: gitController,
                  decoration: InputDecoration(
                    labelText: "Enter Contractor's Git URL",
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    )
                  ),
                  validator: (value){
                    if(value!.isEmpty){
                      return "Git URL can not be empty";
                    }else if(!RegExp(r'(http|https)://[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:/~+#-]*[\w@?^=%&amp;/~+#-])?').hasMatch(value)){
                      return "Please enter a valid Git URL";
                    }else{
                      return null;
                    }
                  },
                  onSaved: (value){
                    gitController.text = value!;
                  },
                  keyboardType: TextInputType.url,
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ElevatedButton(
                        onPressed: (){
                          if(_formKey.currentState!.validate()){
                            addedContractorsRef.push().set({
                              "contractorName": nameController.text,
                              "contractorEmail": emailController.text,
                              "contractorGit": gitController.text,
                              "clientEmail": usr!.email
                            }).then((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Successfully Added")
                                )
                              );
                              nameController.clear();
                              emailController.clear();
                              gitController.clear();
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => const Client()
                              ));
                            }).catchError((onError){
                              ScaffoldMessenger.of(context).showSnackBar(
                                 SnackBar(
                                    content: Text(onError)
                                )
                              );
                            });
                          }
                        },
                        child: const Text("Add")
                    )
                  ],
                ),
              )
            ],
          ),
        )
    );
  }
}
