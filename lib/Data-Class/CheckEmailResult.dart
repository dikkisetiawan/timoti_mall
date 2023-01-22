
import 'package:timoti_project/enums/Sign-In-Type.dart';

class CheckEmailResult{
  bool emailExist;
  List<String> allProviders;
  bool providerExistError;
  SignInType targetProvider;

  CheckEmailResult({
    required this.emailExist,
    required this.allProviders,
    required this.providerExistError,
    required this.targetProvider
  });
}