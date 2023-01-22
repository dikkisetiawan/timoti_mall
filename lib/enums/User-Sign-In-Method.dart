import 'package:flutter/cupertino.dart';
import '/enums/Sign-In-Type.dart';

class SignInMethod extends ChangeNotifier {
  SignInType type;

  SignInMethod(this.type);

  SignInType getSignInMethod() {
    return this.type;
  }

  void updateSignInMethod(SignInType typeValue) {
    this.type = typeValue;
  }
}
