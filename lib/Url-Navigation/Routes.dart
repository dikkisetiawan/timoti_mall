import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:timoti_project/Url-Navigation/LandingPage.dart';
import 'package:timoti_project/Url-Navigation/SplashScreen.dart';

class MyFluroRouterClass {
  static final FluroRouter router = FluroRouter();
  static final String baseURL = '/UrlNavigation';
  // Define the route
  static void setupRouter() {
    router.define(
      '/',
      handler: _splashHandler,
    );
    router.define(
      baseURL + '/:pageName',
      handler: _pageHandler,
      transitionType: TransitionType.fadeIn,
    );

    router.define(
      baseURL + '/:pageName/:pageParam',
      handler: _pageParamHandler,
      transitionType: TransitionType.fadeIn,
    );
  }

  // These route handler is to handle each page w/without param in url
  static Handler _splashHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, List<String>> params) =>
          SplashScreen());

  static Handler _pageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) =>
        LandingPage(
      pageName: params['pageName']![0],
    ),
  ); // Pass param, the param name is from the setupRouter below

  static Handler _pageParamHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) =>
        LandingPage(
          pageName: params['pageName']![0],
      detailsPageName: params['pageParam']![0],
    ),
  );
}
