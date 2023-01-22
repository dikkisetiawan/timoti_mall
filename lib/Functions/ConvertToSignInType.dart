import '/enums/Sign-In-Type.dart';

SignInType convertStringToSignInType(String data) {
  /// Google
  if (data == 'google.com') {
    return SignInType.Google;
  }

  /// Facebook
  else if (data == 'facebook.com') {
    return SignInType.Facebook;
  }

  /// Phone
  else if (data == 'phone') {
    return SignInType.Phone;
  }

  /// Password
  else if (data == 'password') {
    return SignInType.Password;
  }

  /// Invalid String Data
  else {
    return SignInType.Null;
  }
}

String convertSignInTypeToString(SignInType data) {
  /// Google
  if (data == SignInType.Google) {
    return 'Google';
  }

  /// Facebook
  else if (data == SignInType.Facebook) {
    return 'Facebook';
  }

  /// Phone
  else if (data == SignInType.Phone) {
    return 'Phone';
  }

  /// Password
  else if (data == SignInType.Password) {
    return 'Password';
  }

  /// Invalid String Data
  else {
    return 'ERROR';
  }
}
