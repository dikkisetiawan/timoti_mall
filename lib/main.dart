import 'package:country_code_picker/country_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timoti_project/Account/AccountPage.dart';
import 'package:timoti_project/Account/AppVersion-Page.dart';
import 'package:timoti_project/Account/ChangeEmailPage.dart';
import 'package:timoti_project/Account/ChangePasswordPage.dart';
import 'package:timoti_project/Account/ChangePhoneNo/ChangePhoneNumber-Step1.dart';
import 'package:timoti_project/Account/ChangePhoneNo/ChangePhoneNumber-Step2.dart';
import 'package:timoti_project/Account/LinkEmail.dart';
import 'package:timoti_project/Account/LinkPhone/LinkPhone-Step1.dart';
import 'package:timoti_project/Account/LinkPhone/LinkPhone-Step2.dart';
import 'package:timoti_project/Account/PurchaseHistory/Purchase-History-Main.dart';
import 'package:timoti_project/Account/PurchaseHistory/Purchase-OrderDetails.dart';
import 'package:timoti_project/Account/SettingsPage.dart';
import 'package:timoti_project/Account/UpdateProfilePage.dart';
import 'package:timoti_project/Address-Page/Address-Add.dart';
import 'package:timoti_project/Address-Page/Address-Edit.dart';
import 'package:timoti_project/Address-Page/Address-Main.dart';
import 'package:timoti_project/Cart/Cart-Checkout.dart';
import 'package:timoti_project/Coming-Soon-Page.dart';
import 'package:timoti_project/ForgetPassword-Page/ForgetPassword-Page.dart';
import 'package:timoti_project/Google-Map/Map-Page.dart';
import 'package:timoti_project/Home/HomePage.dart';
import 'package:timoti_project/Home/Product-Details-Page.dart';
import 'package:timoti_project/Introduction-Page/Introduction-Page.dart';
import 'package:timoti_project/Login-Register-Page/LoginPage.dart';
import 'package:timoti_project/Login-Register-Page/RegisterPage.dart';
import 'package:timoti_project/Message/MessagePage.dart';
import 'package:timoti_project/Nav.dart';
import 'package:timoti_project/Phone-Auth/PhoneAuthLogin-Step1.dart';
import 'package:timoti_project/Phone-Auth/PhoneAuthLogin-Step2.dart';
import 'package:timoti_project/Phone-Auth/PhoneAuthRegister-Step1.dart';
import 'package:timoti_project/Phone-Auth/PhoneAuthRegister-Step2.dart';
import 'package:timoti_project/QrCode-Page/Qr-Code-Page.dart';
import 'package:timoti_project/QrCode-Page/Qr-Request-Page.dart';
import 'package:timoti_project/QrCode-Page/Qr-Scanner.dart';
import 'package:timoti_project/Url-Navigation/Routes.dart';
import 'package:timoti_project/Wallet/SendWallet/SelectContactPage.dart';
import 'package:timoti_project/Wallet/SendWallet/SendWallet-ThankYouPage.dart';
import 'package:timoti_project/Wallet/TopUp/TopUp-Payment-Method.dart';
import 'package:timoti_project/Wallet/TopUp/TopUpPage.dart';
import 'package:timoti_project/Wallet/WalletPage.dart';
import 'package:timoti_project/Webview/Webview.dart';
import 'package:timoti_project/enums/Sign-In-Type.dart';
import 'package:timoti_project/enums/User-Sign-In-Method.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class App extends StatefulWidget {
  static const routeName = "/App";
  static String appVersion = "1.1.0";
  static bool testing = false;
  static String appName = "";
  static String apiURL = '';

  App(
    bool isTesting,
    String targetAppversion,
    String targetAppname,
    String targetApiURL,
  ) {
    testing = isTesting;
    appVersion = targetAppversion;
    appName = targetAppname;
    apiURL = targetApiURL;
  }

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  bool isFirstLoggedIn = false;
  User? firebaseUser = FirebaseAuth.instance.currentUser;

  _AppState() {
    if (kIsWeb) {
      print("***********************");
      print("Running On Web!");
    } else {
      print("***********************");
      print("NOT RUNNING On Web!");
    }

    checkFirebaseUserExist();
  }

  // region Function
  /// Check firebase user exist
  void checkFirebaseUserExist() {
    /// Detect Guest Login
    if (firebaseUser != null) {
      if (firebaseUser?.isAnonymous == true) {
        print("*** User is Guest Login");
      } else {
        print("*** Normal Login");
      }
      isFirstLoggedIn = false;
      // setState(() {});
    } else {
      isFirstLoggedIn = true;
    }
  }

  /// Define route
  Widget getHomeRoute() {
    /// Using Mobile
    if (kIsWeb == false) {
      print("***********************");
      print("RUNNING On Mobile!");
      if (isFirstLoggedIn == true) {
        return IntroductionPage();
      } else {
        return Nav();
      }
    }

    /// Using Web
    else {
      print("***********************");
      print("RUNNING On Web!");
      return Nav();
    }
  }
  // endregion

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MultiProvider(
      providers: [
        StreamProvider<dynamic>.value(
          initialData: FirebaseAuth.instance.currentUser,
          value: FirebaseAuth.instance.authStateChanges(),
          // value: FirebaseAuth.instance.authStateChanges() as Stream<User>?,
        ),
      ],
      child: MaterialApp(
        scrollBehavior: kIsWeb == true ? AppScrollBehavior() : null,
        theme: ThemeData(
          // textTheme: GoogleFonts.lexendDecaTextTheme(textTheme
          //   Theme.of(context).textTheme,
          // ),
          fontFamily: 'MyriadPro',

          /// Box Color
          shadowColor: Color(0XFFFFFFFF),
          dividerColor: Colors.grey,
          // accentColor: Color(0xFF6BD82F),

          /// Other Primary Text Color
          primaryColor: Colors.black,

          /// Login page text color
          primaryColorLight: Colors.white,

          /// Yellow
          highlightColor: Color(0xFFE1AE31),

          /// Home App Bar Color
          cardColor: Color(0xFFF4E5BC),

          /// Home Background Color
          backgroundColor: Color(0xFFF0F0F0),

          /// Login Background Color
          focusColor: Color(0xFF161616),
        ),
        debugShowCheckedModeBanner: App.testing == false ? false : true,
        title: App.appName,
        // home: PhoneAuthRegisterStepOneScreen(singlePage: true,), // <--- Uncomment for testing
        home: getHomeRoute(),
        routes: {
          Nav.routeName: (context) => Nav(),
          // LoginScreen.routeName: (context) => LoginScreen(),
          RegisterScreen.routeName: (context) => RegisterScreen(),
          IntroductionPage.routeName: (context) => IntroductionPage(),
          WalletPage.routeName: (context) => WalletPage(),
          MessagePage.routeName: (context) => MessagePage(),
          QrCodePage.routeName: (context) => QrCodePage(),
          TopUpPage.routeName: (context) => TopUpPage(),
          TopUpPaymentMethodPage.routeName: (context) =>
              TopUpPaymentMethodPage(),
          PhoneAuthLoginStepOneScreen.routeName: (context) =>
              PhoneAuthLoginStepOneScreen(),
          PhoneAuthLoginStepTwoScreen.routeName: (context) =>
              PhoneAuthLoginStepTwoScreen(),
          QrScanner.routeName: (context) => QrScanner(),
          QrRequestPage.routeName: (context) => QrRequestPage(),
          ComingSoonPage.routeName: (context) => ComingSoonPage(),
          PurchaseHistoryMain.routeName: (context) => PurchaseHistoryMain(),
          ProductDetailsPage.routeName: (context) => ProductDetailsPage(),
          CartCheckoutPage.routeName: (context) => CartCheckoutPage(),
          AddressMainPage.routeName: (context) => AddressMainPage(),
          AddressAddPage.routeName: (context) => AddressAddPage(),
          AddressEditPage.routeName: (context) => AddressEditPage(),
          OrderDetailsPage.routeName: (context) => OrderDetailsPage(),
          UpdateProfilePage.routeName: (context) => UpdateProfilePage(),
          ChangePassword.routeName: (context) => ChangePassword(),
          ChangeEmail.routeName: (context) => ChangeEmail(),
          LinkPhoneStepOne.routeName: (context) => LinkPhoneStepOne(),
          LinkPhoneStepTwo.routeName: (context) => LinkPhoneStepTwo(),
          ChangePhoneNumberStepOne.routeName: (context) =>
              ChangePhoneNumberStepOne(),
          ChangePhoneNumberStepTwo.routeName: (context) =>
              ChangePhoneNumberStepTwo(),
          SettingsPage.routeName: (context) => SettingsPage(),
          SelectContactPage.routeName: (context) => SelectContactPage(),
          LinkEmail.routeName: (context) => LinkEmail(),
          GoogleMapPage.routeName: (context) => GoogleMapPage(),
          AppVersionPage.routeName: (context) => AppVersionPage(),
          ForgetPasswordPage.routeName: (context) => ForgetPasswordPage(),
          SendThankYouPage.routeName: (context) => SendThankYouPage(),
        },
        supportedLocales: [
          Locale("af"),
          Locale("am"),
          Locale("ar"),
          Locale("az"),
          Locale("be"),
          Locale("bg"),
          Locale("bn"),
          Locale("bs"),
          Locale("ca"),
          Locale("cs"),
          Locale("da"),
          Locale("de"),
          Locale("el"),
          Locale("en"),
          Locale("es"),
          Locale("et"),
          Locale("fa"),
          Locale("fi"),
          Locale("fr"),
          Locale("gl"),
          Locale("ha"),
          Locale("he"),
          Locale("hi"),
          Locale("hr"),
          Locale("hu"),
          Locale("hy"),
          Locale("id"),
          Locale("is"),
          Locale("it"),
          Locale("ja"),
          Locale("ka"),
          Locale("kk"),
          Locale("km"),
          Locale("ko"),
          Locale("ku"),
          Locale("ky"),
          Locale("lt"),
          Locale("lv"),
          Locale("mk"),
          Locale("ml"),
          Locale("mn"),
          Locale("ms"),
          Locale("nb"),
          Locale("nl"),
          Locale("nn"),
          Locale("no"),
          Locale("pl"),
          Locale("ps"),
          Locale("pt"),
          Locale("ro"),
          Locale("ru"),
          Locale("sd"),
          Locale("sk"),
          Locale("sl"),
          Locale("so"),
          Locale("sq"),
          Locale("sr"),
          Locale("sv"),
          Locale("ta"),
          Locale("tg"),
          Locale("th"),
          Locale("tk"),
          Locale("tr"),
          Locale("tt"),
          Locale("uk"),
          Locale("ug"),
          Locale("ur"),
          Locale("uz"),
          Locale("vi"),
          Locale("zh")
        ],
        localizationsDelegates: [
          CountryLocalizations.delegate,
        ],
      ),
    );
  }
}

/// For Web to swipe
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
