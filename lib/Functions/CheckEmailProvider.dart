import '/Api/CheckEmailExist-Api/Fetch-CheckEmailExist-Api.dart';
import '/Data-Class/CheckEmailResult.dart';
import '/Functions/ConvertToSignInType.dart';
import '/enums/Sign-In-Type.dart';

/// Check Email Existence with Result
Future<CheckEmailResult?> checkEmailExistenceResult(
  SignInType errorType,
  String email,
) async {
  CheckEmailResult? result;

  // Call API here ....
  await fetchCheckEmailApi(email).then((value) {
    if (value.isExist != null) {
      bool isEmailExist = value.isExist as bool;

      /// If email exist
      if (isEmailExist == true) {
        int savedIndex =
            -1; // <-- Use for indexing random provider as final result
        if (value.provider != null) {
          for (int i = 0; i < value.provider!.length; ++i) {
            if (convertStringToSignInType(value.provider![i]) == errorType) {
              return result = new CheckEmailResult(
                emailExist: true,
                allProviders: value.provider!,
                providerExistError: true,
                targetProvider: SignInType.Password,
              );
            } else {
              /// Ensure its not Phone
              if (convertStringToSignInType(value.provider![i]) !=
                  SignInType.Phone) {
                savedIndex = i;
              }
            }
            if (i == value.provider!.length - 1) {
              /// Non Phone, success
              if (savedIndex != -1) {
                return result = new CheckEmailResult(
                  emailExist: true,
                  allProviders: value.provider!,
                  providerExistError: false,
                  targetProvider:
                      convertStringToSignInType(value.provider![savedIndex]),
                );
              }

              /// Phone, error
              else {
                return result = new CheckEmailResult(
                  emailExist: true,
                  allProviders: value.provider!,
                  providerExistError: true,
                  targetProvider: SignInType.Phone,
                );
              }
            }
          }
        }
      }

      /// Email not exist
      else {
        return result = new CheckEmailResult(
          emailExist: false,
          allProviders: [],
          providerExistError: true,
          targetProvider: SignInType.Null,
        );
      }
    } else {
      print("Check Email API error");
    }
  });

  return result;
}
