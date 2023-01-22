import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:timoti_project/Url-Navigation/Routes.dart';
import 'main.dart';
import 'configure_nonweb.dart' if (dart.library.html) 'configure_web.dart';

Future<void> main() async {
  configureApp();
  bool testing = true;

  String apiUrl = 'https://stgweb.timoti.asia';
  String targetVersion = '1.0.1';
  String appName = 'Staging Timoti';

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // For Facebook
  // if (kIsWeb) {
  //   FacebookAuth.instance.webInitialize(
  //     appId: '1042479106610879',
  //     cookie: true,
  //     xfbml: true,
  //     version: "v12.0",
  //   );
  // }

  runApp(App(testing, targetVersion, appName, apiUrl));
}
