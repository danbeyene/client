import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:client/screens/client.dart';
import 'package:client/screens/add_contractor.dart';
import 'package:client/screens/auth/login.dart';
import 'package:client/allConstants/all_constants.dart';

import 'package:client/providers/auth_provider.dart';

FirebaseAuth auth = FirebaseAuth.instance;

class ClientHome extends StatefulWidget {
  const ClientHome({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<ClientHome> createState() => _ClientHomeState();
}

class _ClientHomeState extends State<ClientHome> {
  _ClientHomeState();

  var lists = [];
  User? usr = auth.currentUser;
  final projectNameController = TextEditingController();
  final taskNameController = TextEditingController();
  final taskDescriptionController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final taskRef = FirebaseDatabase.instance.reference().child('tasks');
  final addedContractorRef =
      FirebaseDatabase.instance.reference().child('addedContractors');
  final Stream<QuerySnapshot> _userStream = FirebaseFirestore.instance
      .collection('users')
      .where('userRole', isEqualTo: 'Contractor')
      .snapshots();

  late AuthProvider authProvider;

  @override
  void initState() {
    authProvider = context.read<AuthProvider>();
    super.initState();
  }

  @override
  void dispose() {
    projectNameController.dispose();
    taskNameController.dispose();
    taskDescriptionController.dispose();
    dateController.dispose();
    timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Client Dashboard'),
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
                  const SizedBox(
                    height: 10,
                  ),
                  const Text('Manually Added Contractors',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(
                    height: 5,
                  ),
                  const Text(
                    '(Tap A Contractor To assign Task)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  FutureBuilder(
                      future: addedContractorRef
                          .orderByChild('contractorName')
                          .startAt('0')
                          .once(),
                      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                        if (snapshot.hasData) {
                          lists.clear();
                          Map<dynamic, dynamic> values =
                              snapshot.data as Map;
                          values.forEach((key, values) {
                            if (values["contractorEmail"] != usr!.email &&
                                values["clientEmail"] != usr!.email) {
                              lists.add(values);
                            }
                          });
                          return Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: lists.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Card(
                                    color: Colors.white,
                                    child: InkWell(
                                      splashColor: Colors.blue.withAlpha(30),
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    createTask(
                                                        lists[index]
                                                            ["contractorName"],
                                                        lists[index]
                                                            ["contractorEmail"],
                                                        lists[index][
                                                            "contractorGit"])));
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          const Text(""),
                                          Text(
                                            lists[index],
                                            style:
                                                const TextStyle(fontSize: 17),
                                          ),
                                          const Text("")
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          );
                        }
                        return const CircularProgressIndicator();
                      }),
                  const Text(
                    "Add Contractor",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const AddContractor(),
                  const SizedBox(
                    height: 15,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => viewActiveTask()));
                      },
                      child: const Text('View Active Tasks')),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => viewCompleteTask()));
                      },
                      child: const Text('View Completed Tasks')),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => viewAllContractors()));
                      },
                      child: const Text('view all contractors')),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
        ));
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

  createTask(
      String contractorName, String contractorEmail, String contractorGit) {
    projectNameController.clear();
    taskNameController.clear();
    taskDescriptionController.clear();
    dateController.clear();
    timeController.clear();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Create Task'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
          child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: TextFormField(
                          controller: projectNameController,
                          decoration: InputDecoration(
                              labelText: "Enter Project Name",
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              )),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "please Enter Project name";
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: TextFormField(
                          controller: taskNameController,
                          decoration: InputDecoration(
                              labelText: "Enter Task Name",
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0))),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please Enter Task Name";
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: TextFormField(
                          minLines: 6,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          controller: taskDescriptionController,
                          decoration: InputDecoration(
                              labelText: "Enter Task description",
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0))),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please Enter Task Description";
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: TextFormField(
                          keyboardType: TextInputType.datetime,
                          controller: dateController,
                          onTap: () async {
                            var date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime(2100));
                            dateController.text =
                                date.toString().substring(0, 10);
                          },
                          decoration: InputDecoration(
                              labelText: "Enter Due Date",
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0))),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please Enter Due Date";
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: TextFormField(
                          keyboardType: TextInputType.datetime,
                          controller: timeController,
                          onTap: () async {
                            var date = await showTimePicker(
                                context: context, initialTime: TimeOfDay.now());
                            timeController.text =
                                "${date!.hour}:${date.minute}";
                          },
                          decoration: InputDecoration(
                              labelText: "Enter Due Time",
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0))),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Enter Due Time";
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    taskRef.push().set({
                                      "ClientEmail": usr!.email,
                                      "ContractorName": contractorName,
                                      "ContractorEmail": contractorEmail,
                                      "ContractorGit": contractorGit,
                                      "ProjectName": projectNameController.text,
                                      "TaskName": taskNameController.text,
                                      "TaskDescription":
                                          taskDescriptionController.text,
                                      "DueDate": dateController.text,
                                      "DueTime": timeController.text,
                                      "Status": "active",
                                    }).then((_) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content:
                                                  Text('Successfully Added')));
                                      projectNameController.clear();
                                      taskNameController.clear();
                                      taskDescriptionController.clear();
                                      dateController.clear();
                                      timeController.clear();
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const Client()));
                                    }).catchError((onError) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                              SnackBar(content: Text(onError)));
                                    });
                                  }
                                },
                                child: const Text('Submit'))
                          ],
                        ),
                      )
                    ],
                  ),
                ))
          ],
        ),
      )),
    );
  }

  viewActiveTask() {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Active Tasks'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FutureBuilder(
                  future: taskRef.orderByChild("DueDate").startAt("0").once(),
                  builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                    if (snapshot.hasData) {
                      lists.clear();
                      Map<dynamic, dynamic> values = snapshot.data as Map;
                      values.forEach((key, values) {
                        if (values["ClientEmail"] == usr!.email &&
                            values["Status"] == "active") {
                          lists.add(values);
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
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                editActiveTask(
                                                    values,
                                                    lists[index]["ProjectName"],
                                                    lists[index]["TaskName"],
                                                    lists[index]
                                                        ["TaskDescription"],
                                                    lists[index]["DueDate"],
                                                    lists[index]["DueTime"])));
                                  },
                                  onDoubleTap: () {
                                    markCompleted(
                                        values,
                                        lists[index]["ProjectName"],
                                        lists[index]["TaskName"],
                                        lists[index]["TaskDescription"],
                                        lists[index]["DueDate"],
                                        lists[index]["DueTime"]);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                viewActiveTask()));
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(lists[index]["ProjectName"]),
                                      Text(lists[index]["TaskName"]),
                                      Text(lists[index]["TaskDescription"]),
                                      Text(
                                          "Due: ${lists[index]["DueDate"]} at ${lists[index]["DueTime"]}"),
                                      Text(
                                          "Assigned By Email: ${lists[index]["ClientEmail"]}"),
                                      Text(
                                          "Assigned To Name: ${lists[index]["ContractorName"]}"),
                                      Text(
                                          "Assigned To Email: ${lists[index]["ContractorEmail"]}"),
                                      Linkify(
                                        onOpen: (link) async {
                                          if (await canLaunchUrl(
                                              lists[index]["ContractorGit"])) {
                                            await launchUrl(
                                                lists[index]["ContractorGit"]);
                                          } else {
                                            throw 'Could not launch $link';
                                          }
                                        },
                                        text:
                                            "Assigned To Git: ${lists[index]["ContractorGit"]}",
                                        style: const TextStyle(
                                            color: Colors.black),
                                        linkStyle:
                                            const TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                      );
                    }
                    return const CircularProgressIndicator();
                  }),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => viewCompleteTask()));
                  },
                  child: const Text("View Completed Tasks")),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Client()));
                  },
                  child: const Text("Home"))
            ],
          ),
        ),
      ),
    );
  }

  viewCompleteTask() {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Completed Tasks"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FutureBuilder(
                  future: taskRef.orderByChild("DueDate").startAt("0").once(),
                  builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                    if (snapshot.hasData) {
                      lists.clear();
                      Map<dynamic, dynamic> values = snapshot.data as Map;
                      values.forEach((key, values) {
                        if ((values["ClientEmail"] == usr!.email) &&
                            (values["Status"] == "complete")) {
                          lists.add(values);
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
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                editCompleteTask(
                                                    values,
                                                    lists[index]["ProjectName"],
                                                    lists[index]["TaskName"],
                                                    lists[index]
                                                        ["TaskDescription"],
                                                    lists[index]["DueDate"],
                                                    lists[index]["DueTime"])));
                                  },
                                  onDoubleTap: () {
                                    markActive(
                                        values,
                                        lists[index]["ProjectName"],
                                        lists[index]["TaskName"],
                                        lists[index]["TaskDescription"],
                                        lists[index]["DueDate"],
                                        lists[index]["DueTime"]);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                viewCompleteTask()));
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(lists[index]["ProjectName"]),
                                      Text(lists[index]["TaskName"]),
                                      Text(lists[index]["TaskDescription"]),
                                      Text(
                                          "Due: ${lists[index]["DueDate"]} at ${lists[index]["DueTime"]}"),
                                      Text(
                                          "Assigned By Email: ${lists[index]["ClientEmail"]}"),
                                      Text(
                                          "Assigned To Name: ${lists[index]["ContractorName"]}"),
                                      Text(
                                          "Assigned To Email: ${lists[index]["ContractorEmail"]}"),
                                      Linkify(
                                        onOpen: (link) async {
                                          if (await canLaunch(
                                              lists[index]["ContractorGit"])) {
                                            await launch(
                                                lists[index]["ContractorGit"]);
                                          } else {
                                            throw 'Could not launch $link';
                                          }
                                        },
                                        text:
                                            "Assigned To Git: ${lists[index]["ContractorGit"]}",
                                        style: const TextStyle(
                                            color: Colors.black),
                                        linkStyle:
                                            const TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                      );
                    }
                    return const CircularProgressIndicator();
                  }),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => viewActiveTask()));
                  },
                  child: const Text("View Active Tasks")),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Client()));
                  },
                  child: const Text("Home"))
            ],
          ),
        ),
      ),
    );
  }

  viewAllContractors() {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("All Contractors"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text("All Registered Contractor List"),
              const Text("Tap A Contractor's Name To Assign A Task"),
              StreamBuilder(
                  stream: _userStream,
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Text("something is wrong");
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (_, index) {
                            return Card(
                              child: InkWell(
                                splashColor: Colors.blue.withAlpha(30),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => createTask(
                                              snapshot.data!.docChanges[index]
                                                  .doc['userName'],
                                              snapshot.data!.docChanges[index]
                                                  .doc['userEmail'],
                                              snapshot.data!.docChanges[index]
                                                  .doc['userGit'])));
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(snapshot.data!.docChanges[index]
                                        .doc['userName']),
                                    Text(snapshot.data!.docChanges[index]
                                        .doc['userEmail']),
                                    Linkify(
                                      onOpen: (link) async {
                                        if (await canLaunch(snapshot
                                            .data!
                                            .docChanges[index]
                                            .doc['userGit'])) {
                                          await launch(snapshot
                                              .data!
                                              .docChanges[index]
                                              .doc['userGit']);
                                        } else {
                                          throw 'Could not launch $link';
                                        }
                                      },
                                      text:
                                          "Assigned To Git: ${snapshot.data!.docChanges[index].doc['userGit']}",
                                      style:
                                          const TextStyle(color: Colors.black),
                                      linkStyle:
                                          const TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                    );
                  }),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => viewActiveTask()));
                  },
                  child: const Text("View Active Tasks")),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Client()));
                  },
                  child: const Text('Home'))
            ],
          ),
        ),
      ),
    );
  }

  editActiveTask(
      values, projectName, taskName, taskDescription, taskDate, taskTime) {
    projectNameController.clear();
    taskNameController.clear();
    taskDescriptionController.clear();
    dateController.clear();
    timeController.clear();

    projectNameController.text = projectName;
    taskNameController.text = taskName;
    taskDescriptionController.text = taskDescription;
    dateController.text = taskDate;
    timeController.text = taskTime;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Edit Task"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: TextFormField(
                controller: projectNameController,
                decoration: InputDecoration(
                    labelText: "Enter Project Name",
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0))),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Project Name can not be empty";
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: TextFormField(
                controller: taskNameController,
                decoration: InputDecoration(
                    labelText: "Enter Task Name",
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0))),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Task Name can not be empty";
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: TextFormField(
                minLines: 6,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                controller: taskDescriptionController,
                decoration: InputDecoration(
                    labelText: "Enter Task Description",
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0))),
                validator: (value) {
                  if (value!.isEmpty) {
                    return " Task Description can not be empty";
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: TextFormField(
                keyboardType: TextInputType.datetime,
                controller: dateController,
                onTap: () async {
                  var date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100));
                  dateController.text = date.toString().substring(0, 10);
                },
                decoration: InputDecoration(
                    labelText: "Enter Due Date",
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0))),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please Enter Due date";
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: TextFormField(
                keyboardType: TextInputType.datetime,
                controller: timeController,
                onTap: () async {
                  var date = await showTimePicker(
                      context: context, initialTime: TimeOfDay.now());
                  timeController.text = "${date!.hour}:${date.minute}";
                },
                decoration: InputDecoration(
                    labelText: "Enter Due Time",
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0))),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please Enter Due Time";
                  }
                  return null;
                },
              ),
            ),
            ElevatedButton(
                onPressed: () => updateActiveTask(
                    values,
                    projectNameController.text,
                    taskNameController.text,
                    taskDescriptionController.text,
                    dateController.text,
                    timeController.text),
                child: const Text('Submit'))
          ],
        ),
      ),
    );
  }

  void markCompleted(
      values, projectName, taskName, taskDescription, taskDate, taskTime) {
    Map<String, dynamic> childrenPathValueMap = {};
    values.forEach((key, values) {
      if ((values["ClientEmail"] == usr!.email) &&
          projectName == values["ProjectName"] &&
          taskName == values["TaskName"] &&
          taskDescription == values["TaskDescription"] &&
          taskDate == values["DueDate"] &&
          taskTime == values["DueTime"]) {
        childrenPathValueMap["$key/Status"] = "complete";
      }
    });
    taskRef.update(childrenPathValueMap);
  }

  editCompleteTask(
      values, projectName, taskName, taskDescription, taskDate, taskTime) {
    projectNameController.clear();
    taskNameController.clear();
    taskDescriptionController.clear();
    dateController.clear();
    timeController.clear();
    projectNameController.text = projectName;
    taskNameController.text = taskName;
    taskDescriptionController.text = taskDescription;
    dateController.text = taskDate;
    timeController.text = taskTime;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Edit Completed Task"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: TextFormField(
                controller: projectNameController,
                decoration: InputDecoration(
                    labelText: "Enter Project name",
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0))),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please Enter Project Name";
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: TextFormField(
                controller: taskNameController,
                decoration: InputDecoration(
                    labelText: "Enter Task Name",
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0))),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please Enter Task Name";
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: TextFormField(
                minLines: 6,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                controller: taskDescriptionController,
                decoration: InputDecoration(
                    labelText: "Enter Task Description",
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0))),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please Enter Task Description";
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: TextFormField(
                keyboardType: TextInputType.datetime,
                controller: dateController,
                onTap: () async {
                  var date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100));
                  dateController.text = date.toString().substring(0, 10);
                },
                decoration: InputDecoration(
                    labelText: "Enter Due Date",
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0))),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please Enter Date";
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: TextFormField(
                keyboardType: TextInputType.datetime,
                controller: timeController,
                onTap: () async {
                  var date = await showTimePicker(
                      context: context, initialTime: TimeOfDay.now());
                  timeController.text = "${date!.hour}:${date.minute}";
                },
                decoration: InputDecoration(
                    labelText: "Enter Due Time",
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0))),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please Enter Due Time";
                  }
                  return null;
                },
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  updateCompleteTask(
                      values,
                      projectNameController.text,
                      taskNameController.text,
                      taskDescriptionController.text,
                      dateController.text,
                      timeController.text);
                },
                child: const Text("Submit"))
          ],
        ),
      ),
    );
  }

  void markActive(
      values, projectName, taskName, taskDescription, taskDate, taskTime) {
    Map<String, dynamic> childrenPathValueMap = {};
    values.forEach((key, values) {
      if ((values["ClientEmail"] == usr!.email) &&
          projectName == values["ProjectName"] &&
          taskName == values["TaskName"] &&
          taskDescription == values["TaskDescription"] &&
          taskDate == values["DueDate"] &&
          taskTime == values["DueTime"]) {
        childrenPathValueMap["$key/Status"] = "active";
      }
    });
    taskRef.update(childrenPathValueMap);
  }

  updateActiveTask(values, newProjectName, newTaskName, newTaskDescription,
      newTaskDate, newTaskTime) {
    projectNameController.clear();
    taskNameController.clear();
    taskDescriptionController.clear();
    dateController.clear();
    timeController.clear();
    Map<String, dynamic> childrenPathValueMap = {};
    values.forEach((key, values) {
      if ((values["ClientEmail"] == usr!.email)) {
        childrenPathValueMap["$key/ProjectName"] = newProjectName;
        childrenPathValueMap["$key/TaskName"] = newTaskName;
        childrenPathValueMap["$key/TaskDescription"] = newTaskDescription;
        childrenPathValueMap["$key/DueDate"] = newTaskDate;
        childrenPathValueMap["$key/DueTime"] = newTaskTime;
      }
    });
    taskRef.update(childrenPathValueMap);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => viewActiveTask()));
  }

  void updateCompleteTask(values, newProjectName, newTaskName,
      newTaskDescription, newTaskDate, newTaskTime) {
    Map<String, dynamic> childrenPathValueMap = {};
    values.forEach((key, values) {
      if ((values["ClientEmail"] == usr!.email)) {
        childrenPathValueMap["$key/ProjectName"] = newProjectName;
        childrenPathValueMap["$key/TaskName"] = newTaskName;
        childrenPathValueMap["$key/TaskDescription"] = newTaskDescription;
        childrenPathValueMap["$key/DueDate"] = newTaskDate;
        childrenPathValueMap["$key/DueTime"] = newTaskTime;
      }
    });
    taskRef.update(childrenPathValueMap);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => viewCompleteTask()));
  }
}
