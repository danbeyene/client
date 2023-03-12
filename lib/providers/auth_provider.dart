
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:client/allConstants/all_constants.dart';
import 'package:client/models/user.dart';
import 'package:flutter/material.dart';

enum Status {
  uninitialized,
  authenticated,
  authenticating,
  authenticateError,
  authenticateCanceled,
}

class AuthProvider extends ChangeNotifier {
  final GoogleSignIn googleSignIn;
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;
  final SharedPreferences prefs;

  Status _status = Status.uninitialized;

  Status get status => _status;

  AuthProvider(
      {required this.googleSignIn,
        required this.firebaseAuth,
        required this.firebaseFirestore,
        required this.prefs});

  String? getFirebaseUserId() {
    return prefs.getString(FirestoreConstants.id);
  }

  String? getFirebaseUserRole() {
    return prefs.getString(FirestoreConstants.userRole);
  }
  String? getFirebaseUserName() {
    return prefs.getString(FirestoreConstants.userName);
  }
  String? getFirebaseUserEmail() {
    return prefs.getString(FirestoreConstants.userEmail);
  }
  String? getFirebaseUserGit() {
    return prefs.getString(FirestoreConstants.userGit);
  }

  Future<bool> isLoggedIn() async {
    bool isLoggedIn = await googleSignIn.isSignedIn();
    if (isLoggedIn &&
        prefs.getString(FirestoreConstants.id)?.isNotEmpty == true) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> handleGoogleSignIn(BuildContext context) async {
    _status = Status.authenticating;
    notifyListeners();

    GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser != null) {
      GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      User? firebaseUser =
          (await firebaseAuth.signInWithCredential(credential)).user;

      if (firebaseUser != null) {
        final QuerySnapshot result = await firebaseFirestore
            .collection(FirestoreConstants.pathUserCollection)
            .where(FirestoreConstants.id, isEqualTo: firebaseUser.uid)
            .get();
        final List<DocumentSnapshot> document = result.docs;
        if(document.isEmpty){
          return false;
        }else {
          DocumentSnapshot documentSnapshot = document[0];
          UserModel userModel = UserModel.fromDocument(documentSnapshot);
          await prefs.setString(FirestoreConstants.id, userModel.id);
          await prefs.setString(
              FirestoreConstants.userName, userModel.userName);
          await prefs.setString(
              FirestoreConstants.userEmail, userModel.userEmail);
          await prefs.setString(
              FirestoreConstants.userGit, userModel.userGit);
          await prefs.setString(
              FirestoreConstants.userRole, userModel.userRole);
        }

        _status = Status.authenticated;
        notifyListeners();
        return true;
      } else {
        _status = Status.authenticateError;
        notifyListeners();
        return false;
      }
    } else {
      _status = Status.authenticateCanceled;
      notifyListeners();
      return false;
    }
  }

  Future<bool> handleEmailPasswordSignIn(String userEmail, String userPassword) async {
    _status = Status.authenticating;
    notifyListeners();


      User? firebaseUser =
          (await firebaseAuth.signInWithEmailAndPassword(email: userEmail, password: userPassword)).user;

      if (firebaseUser != null) {
        final QuerySnapshot result = await firebaseFirestore
            .collection(FirestoreConstants.pathUserCollection)
            .where(FirestoreConstants.id, isEqualTo: firebaseUser.uid)
            .get();
        final List<DocumentSnapshot> document = result.docs;
        if(document.isEmpty){
          return false;
        }else {
          DocumentSnapshot documentSnapshot = document[0];
          UserModel userModel = UserModel.fromDocument(documentSnapshot);
          debugPrint("Test documentSnopshot-----------------------------------${documentSnapshot.get(FirestoreConstants.userName)}");
          debugPrint(
              "user model file ----------------------------------- $document");

          await prefs.setString(FirestoreConstants.id, userModel.id);
          debugPrint(
              "User id -----------------------------------  ${userModel.id}");
          await prefs.setString(
              FirestoreConstants.userName, userModel.userName);
          debugPrint("User name -----------------------------------${userModel.userName}");
          await prefs.setString(
              FirestoreConstants.userEmail, userModel.userEmail);
          debugPrint("User email -----------------------------------${userModel
              .userEmail}");
          await prefs.setString(
              FirestoreConstants.userGit, userModel.userGit);
          debugPrint("User git -----------------------------------${userModel
              .userGit}");
          await prefs.setString(
              FirestoreConstants.userRole, userModel.userRole);
          debugPrint("User role -----------------------------------${userModel
              .userRole}");
        }
        _status = Status.authenticated;
        notifyListeners();
        return true;
      } else {
        _status = Status.authenticateError;
        notifyListeners();
        return false;
      }
  }

  Future<bool> handleSignUp(String userName, String userEmail, String userGit, String userPassword, String userRole) async {
    _status = Status.authenticating;
    notifyListeners();

      User? firebaseUser =
          (await firebaseAuth.createUserWithEmailAndPassword(
                       email: userEmail, password: userPassword)).user;

      if (firebaseUser != null) {
        final QuerySnapshot result = await firebaseFirestore
            .collection(FirestoreConstants.pathUserCollection)
            .where(FirestoreConstants.id, isEqualTo: firebaseUser.uid)
            .get();
        final List<DocumentSnapshot> document = result.docs;
        if (document.isEmpty) {
          firebaseFirestore
              .collection(FirestoreConstants.pathUserCollection)
              .doc(firebaseUser.uid)
              .set({
            FirestoreConstants.userName: userName,
            FirestoreConstants.userEmail: userEmail,
            FirestoreConstants.userGit: userGit,
            FirestoreConstants.userRole: userRole,
            FirestoreConstants.photoUrl: firebaseUser.photoURL,
            FirestoreConstants.id: firebaseUser.uid,
            "createdAt: ": DateTime.now().millisecondsSinceEpoch.toString(),
            FirestoreConstants.chattingWith: null
          });

          User? currentUser = firebaseUser;
          await prefs.setString(FirestoreConstants.id, currentUser.uid);
          await prefs.setString(
              FirestoreConstants.userName, userName);
          await prefs.setString(
              FirestoreConstants.userGit, userGit);
          await prefs.setString(
              FirestoreConstants.userRole, userRole);
          await prefs.setString(
              FirestoreConstants.userEmail, userEmail);
          await prefs.setString(
              FirestoreConstants.photoUrl, currentUser.photoURL ?? "");
        } else {
          DocumentSnapshot documentSnapshot = document[0];
          UserModel userModel = UserModel.fromDocument(documentSnapshot);
          await prefs.setString(FirestoreConstants.id, userModel.id);
          await prefs.setString(
              FirestoreConstants.userName, userModel.userName);
          await prefs.setString(FirestoreConstants.userEmail, userModel.userEmail);
          await prefs.setString(
              FirestoreConstants.userGit, userModel.userGit);
          await prefs.setString(
              FirestoreConstants.userRole, userModel.userRole);
        }
        _status = Status.authenticated;
        notifyListeners();
        return true;
      } else {
        _status = Status.authenticateError;
        notifyListeners();
        return false;
      }

  }

  Future<void> googleSignOut() async {
    _status = Status.uninitialized;
    await firebaseAuth.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
  }
}
