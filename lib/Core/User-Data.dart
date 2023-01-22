import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserData {
  final User user;

  UserData(this.user);

  Future<void> updateUserEmail(String email) async {
    await user.updateEmail(email);
  }

  String getUserID() {
    return user.uid;
  }

  String getUserDisplayName() {
    if (user != null) {
      if (user.displayName != null) {
        return user.displayName as String;
      } else if (user.email != null) {
        return user.email as String;
        ;
      } else if (user.phoneNumber != null) {
        return user.phoneNumber as String;
      } else {
        return "User";
      }
    } else if (user == null) {
      return "User";
    }
    return "User";
  }

  String getUserEmail() {
    if (user != null) {
      if (user.email != null) {
        return user.email as String;
      } else {
        return "DefaultEmail@gmail.com";
      }
    }
    return "DefaultEmail@gmail.com";
  }

  String getUserPhoneNo() {
    if (user != null) {
      if (user.phoneNumber != null) {
        return user.phoneNumber as String;
      } else {
        return "016xxxxxxxxx";
      }
    }
    return "016xxxxxxxxx";
  }

  String getUserPhotoURL() {
    if (user.photoURL != null) {
      return user.photoURL as String;
    } else {
      return '';
    }
  }
}

// This is used for access firebase user data
class InheritedUserData extends InheritedWidget {
  final User user;

  InheritedUserData({
    required this.user,
    required Widget child,
  }) : super(child: child);

  //bool updateShouldNotify(InheritedWidget oldWidget) => true;
  @override
  bool updateShouldNotify(InheritedUserData oldWidget) {
    return oldWidget.user != user;
  }
}
