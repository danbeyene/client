import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:client/allConstants/all_constants.dart';

class UserModel  {
  final String id;
  final String photoUrl;
  final String userName;
  final String userGit;
  final String userEmail;
  final String userRole;

  const UserModel(
      {required this.id,
      required this.photoUrl,
      required this.userName,
      required this.userGit,
      required this.userEmail,
        required this.userRole,});

  factory UserModel.fromDocument(DocumentSnapshot snapshot) {

    return UserModel(
        id: snapshot.id,
        photoUrl: snapshot.get(FirestoreConstants.photoUrl) ?? "",
        userName: snapshot.get(FirestoreConstants.userName) ?? "",
        userGit: snapshot.get(FirestoreConstants.userGit) ?? "",
        userEmail: snapshot.get(FirestoreConstants.userEmail) ?? "",
        userRole: snapshot.get(FirestoreConstants.userRole) ?? ""
    );
  }


}
