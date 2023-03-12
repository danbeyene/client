import 'package:flutter/material.dart';
import 'package:client/screens/client.dart';
import 'package:client/screens/contractor.dart';
import 'package:client/screens/auth/register.dart';
import 'package:client/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class Controller extends StatefulWidget {
  const Controller({Key? key}) : super(key: key);

  @override
  State<Controller> createState() => _ControllerState();
}

class _ControllerState extends State<Controller> {
  _ControllerState();
  late AuthProvider authProvider;
  late String currentUserRole;

  @override
  void initState() {
    super.initState();
    authProvider = context.read<AuthProvider>();
    readLocal();
  }

  void readLocal() {
    if (authProvider.getFirebaseUserId()?.isNotEmpty == true) {
        setState(() {
          currentUserRole = authProvider.getFirebaseUserRole()!;
        });
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Register()),
              (Route<dynamic> route) => false);
    }
  }


  routing() {
    if (currentUserRole == 'Client') {
      return const Client();
    } else if (currentUserRole == 'Contractor'){
      return const Contractor();
    }else{
      return const Register();
    }
  }

  @override
  Widget build(BuildContext context) {
    const CircularProgressIndicator();
    return routing();
  }
}
