import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:client/screens/auth/login.dart';
import 'package:client/screens/contractor.dart';
import 'package:client/allConstants/all_constants.dart';
import 'package:provider/provider.dart';

import 'package:client/providers/auth_provider.dart';


FirebaseAuth auth = FirebaseAuth.instance;
class ContractorHome extends StatefulWidget {
  const ContractorHome({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<ContractorHome> createState() => _ContractorHomeState();
}

class _ContractorHomeState extends State<ContractorHome> {
  _ContractorHomeState();
  final taskRef = FirebaseDatabase.instance.reference().child("tasks");
  var lists = [];
  User? usr = auth.currentUser;

  late AuthProvider authProvider;


  @override
  void initState() {
    authProvider = context.read<AuthProvider>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Contractor Dashboard"),
        actions: [
          IconButton(
              onPressed: () => googleSignOut(),
              icon: const Icon(Icons.logout)),
        ],
        automaticallyImplyLeading: false,
      ),
      body: WillPopScope(
        onWillPop: onBackPress,
        child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text("Your Client List", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              const Text("Tap A Client's Name To see A Task", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              FutureBuilder(
                future: taskRef
                  .orderByChild("DueDate")
                  .startAt("0")
                  .once(),
                  builder: (context, AsyncSnapshot<DatabaseEvent> snapshot){
                  if(snapshot.hasData){
                    lists.clear();
                    Map<dynamic, dynamic> values = snapshot.data as Map;
                    values.forEach((key, values) { 
                      if((values["ContractorEmail"] == usr!.email) && (values["Status"] == "active")){
                        lists.add(values["ClientEmail"]);
                      }
                    });
                    return Padding(
                        padding: const EdgeInsets.all(20.0),
                      child: ListView.builder(
                        shrinkWrap: true,
                          itemCount: lists.length,
                          itemBuilder: (BuildContext context, int index) {
                          return Card(
                            child: InkWell(
                              splashColor: Colors.blue.withAlpha(30),
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => viewActiveTask(lists[index])
                                ));
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  const Text(""),
                                  Text(lists[index]),
                                  const Text("")
                                ],
                              ),
                            ),
                          );
                          }
                      ),
                    );
                  }
                  return const CircularProgressIndicator();
                  }
              ),
            ],
          ),
        ),
      ),
      )
    );
  }

  Future<void> googleSignOut() async {
    authProvider.googleSignOut();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const Login()));
  }

  Future<bool> onBackPress() {
    openDialog();
    return Future.value(false);
  }

  Future<void> openDialog() async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return SimpleDialog(
            backgroundColor: AppColors.burgundy,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Exit Application',
                  style: TextStyle(color: AppColors.white),
                ),
                Icon(
                  Icons.exit_to_app,
                  size: 30,
                  color: Colors.white,
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Sizes.dimen_10),
            ),
            children: [
              vertical10,
              const Text(
                'Are you sure?',
                textAlign: TextAlign.center,
                style:
                TextStyle(color: AppColors.white, fontSize: Sizes.dimen_16),
              ),
              vertical15,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context, 0);
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.white),
                    ),
                  ),
                  SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context, 1);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(Sizes.dimen_8),
                      ),
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                      child: const Text(
                        'Yes',
                        style: TextStyle(color: AppColors.spaceCadet),
                      ),
                    ),
                  )
                ],
              )
            ],
          );
        })) {
      case 0:
        break;
      case 1:
        exit(0);
    }
  }

  viewActiveTask(clientEmail) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Active Tasks for You"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FutureBuilder(
                future: taskRef
                  .orderByChild("DueDate")
                  .startAt("0")
                  .once(),
                  builder: (context, AsyncSnapshot<DatabaseEvent> snapshot){
                  if(snapshot.hasData){
                    lists.clear();
                    Map<dynamic, dynamic> values = snapshot.data as Map;
                    values.forEach((key, values) {
                      if((values["ContractorEmail"] == usr!.email) && (values["Status"] == "active")){
                        lists.add(values);
                      }
                    });
                    return Padding(
                        padding: const EdgeInsets.all(20.0),
                      child: ListView.builder(
                        shrinkWrap: true,
                          itemCount: lists.length,
                          itemBuilder: (BuildContext context, int index){
                          return Card(
                            child: InkWell(
                              splashColor: Colors.blue.withAlpha(30),
                              onTap: (){},
                              onDoubleTap: (){},
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(lists[index]["ProjectName"]),
                                  Text(lists[index]["TaskName"]),
                                  Text(lists[index]["TaskDescription"]),
                                  Text("Due: ${lists[index]["DueDate"]} at ${lists[index]["DueTime"]}"),
                                  Text("Assigned by: ${lists[index]["ClientEmail"]}"),
                                  Text("Assigned To Name : ${lists[index]["ContractorName"]}"),
                                  Text("Assigned To Email: ${lists[index]["ContractorEmail"]}")
                                ],
                              ),
                            ),
                          );
                          }
                      ),
                    );
                  }
                  return const CircularProgressIndicator();
                  }
              ),
              ElevatedButton(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => const Contractor()
                    ));
                  },
                  child: const Text("Home"))
            ],
          ),
        ),
      ),
    );
  }

}
