import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';
import 'package:timoti_project/Functions/ConvertToSignInType.dart';
import 'package:timoti_project/Functions/Messager.dart';
import 'package:timoti_project/Screen-Size/Get-Device-Details.dart';
import 'package:timoti_project/enums/Sign-In-Type.dart';

class AuthService {
  // Dependencies
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Shared State for Widgets
  late Stream<User?> user; // firebase user
  late Stream<Map<String, dynamic>?> profile;
  PublishSubject loading = PublishSubject();

  // constructor
  AuthService() {
    user = (_auth.authStateChanges());

    profile = user.switchMap((value) {
      if (value != null) {
        return _db
            .collection('Customers')
            .doc(value.uid)
            .snapshots()
            .map((snap) => snap.data());
      } else {
        return Stream.empty();
      }
    });
  }

  Future<void> updateUserData(User user) async {
    DocumentReference ref = _db.collection('Customers').doc(user.uid);
    var date = new DateTime.now();
    // var newDate = new DateTime(date.year, date.month, date.day, date.hour + 8, date.minute, date.second);
    // String targetDate = DateFormat('yyyy-MM-dd hh:mm:ss').format(newDate);
    String targetDate = DateFormat('yyyy-MM-dd hh:mm:ss').format(date);

    return ref.update({
      // 'Customer_Code': user.uid,
      // 'Customer_Note': '',
      // 'Customer_ID': user.uid,
      // 'Email': user.email,
      // 'displayName': user.displayName != null ? user.displayName : user.phoneNumber,
      // 'lastSeen': DateTime.now(),
      'Last_Login': targetDate,
      // 'Updated_At': targetDate,
      // 'Full_Name': user.displayName != null ? user.displayName : user.phoneNumber,
      // 'Phone': user.phoneNumber != null ? user.phoneNumber : null,
      'Accept_Marketing': true,
      'Agent_ID': "N/A",
      // 'Created_At': targetDate,
      // 'Date_Of_Birth': '',
      // 'Deleted_Status': 'N/A',
      // 'Facebook_ID': '',
      // 'Google_ID': '',
      // 'Is_Verified': '',
      // 'Language': '',
      // 'Profile_Pic': user.photoUrl != null ? user.photoUrl : '',
      // 'Redeem_Point': 0,
      // 'Referrer_Code':"",
      // 'Verification_Contact': '',
      // 'Verification_Email': '',
    });
  }

  Future<void> createUserDataViaPassword(User user, String name) async {
    DocumentReference ref = _db.collection('Customers').doc(user.uid);
    String targetDate =
        DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now());

    /// Create Data
    await ref.set({
      'Customer_Code': user.uid,
      'Customer_Note': '',
      'Customer_ID': user.uid,
      'Email': user.email,
      // 'displayName': user.displayName != null ? user.displayName : user.phoneNumber,
      // 'lastSeen': DateTime.now(),
      'Last_Login': targetDate,
      'Updated_At': targetDate,
      'Full_Name': name,
      'Phone': user.phoneNumber != null ? user.phoneNumber : null,
      'Accept_Marketing': true,
      'Agent_ID': "N/A",
      // 'Created_At': targetDate,
      'Date_Of_Birth': '',
      'Deleted_Status': 'N/A',
      'Facebook_ID': '',
      'Google_ID': '',
      'Is_Verified': '',
      'Language': '',
      'Profile_Pic': user.photoURL != null ? user.photoURL : '',
      // 'Redeem_Point': 0,
      'Referrer_Code': "",
      'Verification_Contact': '',
      'Verification_Email': '',
    });

    /// Check and Create Provider Data
    await checkAndCreateProvidersData(user, SignInType.Password);
  }

  // region Google
  Future<bool> googleSignIn(BuildContext context, bool canCreateDoc) async {
    loading.add(true);
    bool userLoginBefore = false;

    GoogleSignInAccount googleUser =
        await _googleSignIn.signIn() as GoogleSignInAccount;
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final User user =
        (await _auth.signInWithCredential(credential)).user as User;

    /// Find the user data exist or not
    DocumentSnapshot userData =
        await _db.collection('Customers').doc(user.uid).get();
    if (userData.exists == true) {
      print("=========================");
      print("Google User Login Before");
      userLoginBefore = true;
      updateUserData(user);
    } else {
      if (canCreateDoc == true) {
        print("=========================");
        print("Google User New Account");

        /// Create Data
        createUserDataGoogle(user, googleUser.email);
      } else {
        showSnackBar('User not allow to create data', context);
      }
    }

    loading.add(false);
    // state.setLoadingState(false);

    // // SignInMethod signInMethod = Provider.of(context, listen: false);
    // signInMethod.updateSignInMethod(SignInType.Google);

    return userLoginBefore;
  }

  /// For google
  void createUserDataGoogle(User user, String email) async {
    DocumentReference ref = _db.collection('Customers').doc(user.uid);
    String targetDate =
        DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now());

    print('user.displayName : ' + (user.displayName as String));
    print('user.uid : ' + user.uid);

    await ref.set({
      'Customer_Code': user.uid,
      'Customer_Note': '',
      'Customer_ID': user.uid,
      'Email': email,
      // 'displayName': user.displayName != null ? user.displayName : user.phoneNumber,
      // 'lastSeen': DateTime.now(),
      'Last_Login': targetDate,
      'Updated_At': targetDate,
      'Full_Name': user.displayName != null ? user.displayName : email,
      'Phone': '',
      'Accept_Marketing': true,
      'Agent_ID': "N/A",
      // 'Created_At': targetDate,
      'Date_Of_Birth': '',
      'Deleted_Status': 'N/A',
      'Facebook_ID': '',
      'Google_ID': '',
      'Is_Verified': '',
      'Language': '',
      'Profile_Pic': '',
      // 'Redeem_Point': 0,
      'Referrer_Code': "",
      'Verification_Contact': '',
      'Verification_Email': '',
    });

    /// Check and Create Provider Data
    await checkAndCreateProvidersData(user, SignInType.Google);
  }

  Future<void> googleSignOut() async {
    await _googleSignIn.signOut();
  }
  // endregion

  // region Facebook
  // Future<bool> signInWithFacebook(
  //     BuildContext context, bool canCreateDoc) async {
  //   bool userLoginBefore = false;
  //   loading.add(true);

  //   await _auth.signOut();

  //   /// Ensure user login
  //  // await FacebookAuth.instance.login();

  //   /// Get AccessToken
  //   final AccessToken accessToken =
  //       await FacebookAuth.instance.accessToken as AccessToken;
  //   final AuthCredential credential =
  //       FacebookAuthProvider.credential(accessToken.token);

  //   /// Get Fb User data
  //   final fbUserData = await FacebookAuth.instance.getUserData();
  //   print("***********");
  //   print("User Data");
  //   print(fbUserData.toString());

  //   /// User Email
  //   print("User Facebook Email: " + fbUserData["email"].toString());

  //   /// Sign In Facebook
  //   final User user =
  //       (await _auth.signInWithCredential(credential)).user as User;

  //   /// Find the user data exist or not
  //   DocumentSnapshot userData =
  //       await _db.collection('Customers').doc(user.uid).get();

  //   if (userData.exists == true) {
  //     print("=========================");
  //     print("Facebook User Login Before");
  //     userLoginBefore = true;
  //     updateUserData(user);
  //   } else {
  //     if (canCreateDoc == true) {
  //       print("=========================");
  //       print("Facebook User New Account");

  //       String targetEmail = '';
  //       if (fbUserData["email"] != null) {
  //         targetEmail = fbUserData["email"];
  //       }

  //       /// Create Data
  //       createUserDataFacebook(user, targetEmail);
  //     } else {
  //       showSnackBar('User not allow to create data', context);
  //     }
  //   }

  //   loading.add(false);

  //   return userLoginBefore;
  // }

  /// For Facebook
  void createUserDataFacebook(User user, String email) async {
    print("Facebook create account init");
    DocumentReference ref = _db.collection('Customers').doc(user.uid);
    String targetDate =
        DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now());

    print('user.displayName : ' + (user.displayName as String));
    print('user.uid : ' + user.uid);

    await ref.set({
      'Customer_Code': user.uid,
      'Customer_Note': '',
      'Customer_ID': user.uid,
      'Email': email,
      // 'displayName': user.displayName != null ? user.displayName : user.phoneNumber,
      // 'lastSeen': DateTime.now(),
      'Last_Login': targetDate,
      'Updated_At': targetDate,
      'Full_Name':
          user.displayName != null ? user.displayName : user.phoneNumber,
      'Phone': '',
      'Accept_Marketing': true,
      'Agent_ID': "N/A",
      // 'Created_At': targetDate,
      'Date_Of_Birth': '',
      'Deleted_Status': 'N/A',
      'Facebook_ID': '',
      'Google_ID': '',
      'Is_Verified': '',
      'Language': '',
      'Profile_Pic': '',
      // 'Redeem_Point': 0,
      'Referrer_Code': "",
      'Verification_Contact': '',
      'Verification_Email': '',
    });

    /// Check and Create Provider Data
    await checkAndCreateProvidersData(user, SignInType.Facebook);
  }

  // Future<void> facebookSignOut() async {
  //   await FacebookAuth.instance.logOut();
  // }
  // endregion

  // region Link Account (Google + FB + Password)
  /// Link Google
  Future<void> linkGoogleAccount(User user) async {
    loading.add(true);

    GoogleSignInAccount googleUser =
        await _googleSignIn.signIn() as GoogleSignInAccount;
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await user.linkWithCredential(credential);

    loading.add(false);
  }

  // /// Link Facebook
  // Future<void> linkFacebookAccount(User user) async {
  //   loading.add(true);

  //   /// Ensure user login
  //   await FacebookAuth.instance.login();

  //   /// Get AccessToken
  //   final AccessToken accessToken =
  //       await FacebookAuth.instance.accessToken as AccessToken;
  //   final AuthCredential credential =
  //       FacebookAuthProvider.credential(accessToken.token);

  //   await user.linkWithCredential(credential);

  //   loading.add(false);
  // }

  Future<void> linkPasswordAccount(
    User user,
    String t_email,
    String t_password,
  ) async {
    /// Get Email Credential
    final AuthCredential credential = EmailAuthProvider.credential(
      email: t_email,
      password: t_password,
    );

    /// Link Account
    await user.linkWithCredential(credential);
  }
  // endregion

  void updatePhone(User user, String number) async {
    FirebaseFirestore.instance.collection("Customers").doc(user.uid).update({
      'Phone': number,
    }).then((value) {
      print("Update Phone Success");
    });
  }

  Future<void> signOut() async {
    await _auth.signOut();
    // user = _auth.currentUser as Stream<User>;
  }

  // region Check User Account
  /// Check if user has password login
  bool userUsePassword(User user) {
    bool usePassword = false;
    List<UserInfo> userInfo = user.providerData;
    for (int i = 0; i < userInfo.length; ++i) {
      if (convertStringToSignInType(userInfo[i].providerId) ==
          SignInType.Password) {
        print("Found Password");
        usePassword = true;
        break;
      }
    }
    return usePassword;
  }

  /// Check if user has phone login
  bool userUsePhone(User user) {
    bool usePhone = false;
    List<UserInfo> userInfo = user.providerData;
    for (int i = 0; i < userInfo.length; ++i) {
      if (convertStringToSignInType(userInfo[i].providerId) ==
          SignInType.Phone) {
        print("Found Phone");
        usePhone = true;
        break;
      }
    }
    return usePhone;
  }

  /// Check if user has google login
  bool userUseGoogle(User user) {
    bool useGoogle = false;
    List<UserInfo> userInfo = user.providerData;
    for (int i = 0; i < userInfo.length; ++i) {
      if (convertStringToSignInType(userInfo[i].providerId) ==
          SignInType.Google) {
        print("Found Google");
        useGoogle = true;
        break;
      }
    }
    return useGoogle;
  }

  /// Check if user has facebook login
  bool userUseFacebook(User user) {
    bool useFb = false;
    List<UserInfo> userInfo = user.providerData;
    for (int i = 0; i < userInfo.length; ++i) {
      if (convertStringToSignInType(userInfo[i].providerId) ==
          SignInType.Facebook) {
        print("Found Facebook");
        useFb = true;
        break;
      }
    }
    return useFb;
  }
// endregion

  /// Used for verify if user is guest login
  // If Guest login prompt login message || If Existing account go to next page
  void verifyGuestBeforeNextPage(
    Widget nextPage,
    BuildContext context,
  ) {
    /// Already Login
    if (FirebaseAuth.instance.currentUser != null) {
      if (FirebaseAuth.instance.currentUser?.isAnonymous == true) {
        print("*** User is Guest Login");
        Future.delayed(Duration.zero, () async {
          showLoginMessage(0, 15, context);
        });
      } else {
        print("*** Existing Account");

        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: nextPage,
          ),
        );
      }
      // isRefresh = true;
    }

    /// Not Login
    else {
      Future.delayed(Duration.zero, () async {
        showLoginMessage(0, 15, context);
      });
    }
  }

  // region Upgrade Guest Account
  /// Password
  // Password upgrade Guest account to Permanent account
  Future<bool> upgradeWithPassword(
    String emailString,
    String passwordString,
    DeviceDetails _deviceDetails,
    BuildContext context,
    String userDisplayName,
  ) async {
    bool isSuccess = false;

    /// Ensure is Guest Account
    if (FirebaseAuth.instance.currentUser != null) {
      if (FirebaseAuth.instance.currentUser!.isAnonymous == true) {
        print("Upgrading Guest with Password");

        /// 1. Create the email and password credential, to upgrade the anonymous user.
        var credential = EmailAuthProvider.credential(
          email: emailString,
          password: passwordString,
        );

        /// 2. Links the credential to the currently signed in user (the anonymous user).
        FirebaseAuth.instance.currentUser
            ?.linkWithCredential(credential)
            .then((value) {
          print("** Guest Account successfully upgraded");

          /// Update user (display name)
          FirebaseAuth.instance.currentUser
              ?.updateDisplayName(userDisplayName)
              .then((value) {
            print("Email is: " +
                (FirebaseAuth.instance.currentUser?.email as String));

            /// Create User Data
            createUserDataViaPassword(
                FirebaseAuth.instance.currentUser!, userDisplayName);
            return isSuccess = true;
          });
        }).catchError((error) {
          showMessage('', error.message, _deviceDetails, context);
        });
      } else {
        print("** Upgrade Failed. Not Guest Login");
        showMessage(
            '', 'Upgrade Failed. Not Guest Login', _deviceDetails, context);

        return isSuccess = false;
      }
    } else {
      print("** Upgrade Failed. No Account Login");
      showMessage(
          '', 'Upgrade Failed. No Account Login', _deviceDetails, context);
      return isSuccess = false;
    }
    return isSuccess;
  }

  /// Google
  // Google upgrade Guest account to Permanent account
  Future<bool> upgradeWithGoogle(
    DeviceDetails _deviceDetails,
    BuildContext context,
  ) async {
    bool isSuccess = false;
    User? firebaseUser = FirebaseAuth.instance.currentUser;

    /// Ensure is Guest Account
    if (firebaseUser != null) {
      if (firebaseUser.isAnonymous == true) {
        print("Upgrading Guest with Google");

        /// 1. Create credential, to upgrade the anonymous user.
        GoogleSignInAccount googleUser =
            await _googleSignIn.signIn() as GoogleSignInAccount;
        GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        var credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // final User user =
        // (await _auth.signInWithCredential(credential)).user as User;

        /// 2. Links the credential to the currently signed in user (the anonymous user).
        FirebaseAuth.instance.currentUser
            ?.linkWithCredential(credential)
            .then((value) {
          print("** Guest Account successfully upgraded");

          /// Update user (display name)
          FirebaseAuth.instance.currentUser
              ?.updateDisplayName(googleUser.email)
              .then((value) {
            /// Create User Data
            createUserDataGoogle(
                FirebaseAuth.instance.currentUser!, googleUser.email);
            return isSuccess = true;
          }).catchError((error) {
            showMessage('', error.message, _deviceDetails, context);
          });
        }).catchError((error) {
          showMessage('', error.message, _deviceDetails, context);
        });
      } else {
        print("** Upgrade Failed. Not Guest Login");
        showMessage(
            '', 'Upgrade Failed. Not Guest Login', _deviceDetails, context);

        return isSuccess = false;
      }
    } else {
      print("** Upgrade Failed. No Account Login");
      showMessage(
          '', 'Upgrade Failed. No Account Login', _deviceDetails, context);
      return isSuccess = false;
    }
    return isSuccess;
  }

  // /// Facebook
  // // Google upgrade Guest account to Permanent account
  // Future<bool> upgradeWithFacebook(
  //   String emailString,
  //   String passwordString,
  //   DeviceDetails _deviceDetails,
  //   BuildContext context,
  //   String userDisplayName,
  // ) async {
  //   bool isSuccess = false;
  //   User? firebaseUser = FirebaseAuth.instance.currentUser;

  //   /// Ensure is Guest Account
  //   if (firebaseUser != null) {
  //     if (firebaseUser.isAnonymous == true) {
  //       print("Upgrading Guest with Google");

  //       /// 1. Create credential, to upgrade the anonymous user.
  //       await FacebookAuth.instance.login();

  //       /// Get AccessToken
  //       final AccessToken accessToken =
  //           await FacebookAuth.instance.accessToken as AccessToken;
  //       var credential = FacebookAuthProvider.credential(accessToken.token);

  //       /// 2. Links the credential to the currently signed in user (the anonymous user).
  //       FirebaseAuth.instance.currentUser
  //           ?.linkWithCredential(credential)
  //           .then((value) {
  //         print("** Guest Account successfully upgraded");

  //         /// Update user (display name)
  //         FirebaseAuth.instance.currentUser
  //             ?.updateDisplayName(userDisplayName)
  //             .then((value) {
  //           /// Create User Data
  //           createUserDataFacebook(FirebaseAuth.instance.currentUser!, userDisplayName);
  //           return isSuccess = true;
  //         }).catchError((error) {
  //           showMessage('', error.message, _deviceDetails, context);
  //         });
  //       }).catchError((error) {
  //         showMessage('', error.message, _deviceDetails, context);
  //       });
  //     } else {
  //       print("** Upgrade Failed. Not Guest Login");
  //       showMessage(
  //           '', 'Upgrade Failed. Not Guest Login', _deviceDetails, context);

  //       return isSuccess = false;
  //     }
  //   } else {
  //     print("** Upgrade Failed. No Account Login");
  //     showMessage(
  //         '', 'Upgrade Failed. No Account Login', _deviceDetails, context);
  //     return isSuccess = false;
  //   }
  //   return isSuccess;
  // }
  // endregion'

  // region Login and Link Account
  // /// Login and Link Account (Google / Facebook)
  // Future<void> loginAndLinkAccount(
  //   SignInType loginType,
  //   SignInType linkType,
  //   String email,
  //   String password,
  //   BuildContext context,
  // ) async {
  //   if (linkType == loginType) {
  //     showSnackBar('Not allow to login and link the same method', context);
  //   }
  //   switch (loginType) {
  //     case SignInType.Google:

  //       /// Call Google Login Service
  //       await googleSignIn(context, false).then((value) {
  //         /// Link Facebook
  //         if (linkType == SignInType.Facebook) {
  //           linkFacebookAccount(FirebaseAuth.instance.currentUser as User)
  //               .then((value) {
  //             showSnackBar("Successfully Linked Account", context);
  //           }).catchError((error) {
  //             showSnackBar(error.message, context);
  //           });
  //         }

  //         /// Link Password
  //         else if (linkType == SignInType.Password) {
  //           linkPasswordAccount(
  //                   FirebaseAuth.instance.currentUser as User, email, password)
  //               .then((value) {
  //             showSnackBar("Successfully Linked Account", context);
  //           }).catchError((error) {
  //             showSnackBar(error.message, context);
  //           });
  //         }
  //       }).catchError((error) {
  //         showSnackBar(error.message, context);
  //       });
  //       break;
  //     case SignInType.Facebook:

  //       /// Call Facebook Login Service
  //       await authService.signInWithFacebook(context, false).then((value) {
  //         /// Link Facebook
  //         if (linkType == SignInType.Google) {
  //           linkGoogleAccount(FirebaseAuth.instance.currentUser as User)
  //               .then((value) {
  //             showSnackBar("Successfully Linked Account", context);
  //           }).catchError((error) {
  //             showSnackBar(error.message, context);
  //           });
  //         }

  //         /// Link Password
  //         else if (linkType == SignInType.Password) {
  //           linkPasswordAccount(
  //                   FirebaseAuth.instance.currentUser as User, email, password)
  //               .then((value) {
  //             showSnackBar("Successfully Linked Account", context);
  //           }).catchError((error) {
  //             showSnackBar(error.message, context);
  //           });
  //         }
  //       }).catchError((error) {
  //         showSnackBar(error.message, context);
  //       });
  //       break;
  //     default:
  //       showSnackBar(
  //           "Login and Link Failed: Non using Google / Facebook / Password",
  //           context);
  //       break;
  //   }
  // }
  // endregion

  // region Providers
  /// Create Provider Data
  Future<void> createProviderData(User user, SignInType signInType) async {
    String targetProvider = convertSignInTypeToString(signInType);
    List<String> providerList = [targetProvider];
    String targetDate =
        DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now());

    DocumentReference ref =
        await FirebaseFirestore.instance.collection('Providers').doc(user.uid);

    await ref.set({
      'Created_At': targetDate,
      'CustomerId': user.uid,
      'Email': user.email,
      'ProviderIds': providerList,
    });
  }

  /// Check providers data existence
  Future<bool> checkProvidersDataExistence(String customerId) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('Providers')
        .doc(customerId)
        .get();
    return doc.exists;
  }

  /// Check & Create Provider if necessary
  Future<void> checkAndCreateProvidersData(
      User user, SignInType signInType) async {
    /// Check providers data exist or not
    await checkProvidersDataExistence(user.uid).then((isExist) {
      /// If Data not exist
      if (isExist == false) {
        createProviderData(user, signInType);
      }

      /// Data Existed
      else {
        print("*** Provider Data Existed!!!!!!!");
      }
    });
  }
  // endregion
}

final AuthService authService = AuthService();
