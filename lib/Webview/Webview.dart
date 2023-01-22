import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '/Screen-Size/Get-Device-Details.dart';
import '/Screen-Size/WidgetSizeCalculation.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// Use this
class WebViewApp extends StatefulWidget {
  final String targetURL;
  final String title;

  const WebViewApp({
    Key? key,
    required this.targetURL,
    required this.title,
  }) : super(key: key);

  @override
  _WebViewAppState createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    print("Target URL: " + widget.targetURL);
  }

  @override
  Widget build(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);

    return Scaffold(
      drawer: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Theme.of(context)
              .backgroundColor, //This will change the drawer background to blue.
          //other styles
        ),
        child: Drawer(
          child: SafeArea(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                Container(
                  color: Theme.of(context).highlightColor,
                  child: DrawerHeader(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.title,
                        style: TextStyle(
                            fontSize: 30,
                            color: Theme.of(context).backgroundColor),
                      ),
                    ),
                  ),
                ),
                WebNavigationControls(_controller.future, widget.targetURL),
              ],
            ),
          ), // Populate the Drawer in the next step.
        ),
      ),
      // appBar: AppBar(
      //   title: const Text('Flutter WebView example'),
      //   // This drop down menu demonstrates that Flutter widgets can be shown over the web view.
      //   actions: <Widget>[
      //     WebNavigationControls(_controller.future),
      //     WebMenu(_controller.future),
      //   ],
      // ),
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return Container(
              child: IconButton(
                icon: Icon(
                  Icons.menu,
                  color: Theme.of(context).backgroundColor,
                  size: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                ),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              ),
            );
          },
        ),
        // leading: InkWell(
        //   onTap: () {
        //     // Navigator.pop(context);
        //     Scaffold.of(context).openDrawer();
        //   },
        //   child: Icon(
        //     Icons.menu,
        //     color: Theme.of(context).primaryColor,
        //     size: _widgetSize.getResponsiveWidth(0.05),
        //   ),
        // ),
        title: Text(
          widget.title,
          style: TextStyle(color: Theme.of(context).backgroundColor),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                Colors.green,
                Colors.green,
                Theme.of(context).accentColor,
              ])),
        ),
        shadowColor: Colors.grey,
        elevation: 3,
      ),
      // body: ModalProgressHUD(
      //   opacity: 0.50,
      //   color: Theme.of(context).highlightColor,
      //   inAsyncCall: _loading,
      //   progressIndicator: SpinKitWave(
      //     color: Theme.of(context).backgroundColor,
      //     duration: Duration(milliseconds: 350),
      //   ),
      //   child: SafeArea(
      //     child: Builder(builder: (BuildContext context) {
      //       return WebView(
      //         initialUrl: widget.targetURL,
      //         javascriptMode: JavascriptMode.unrestricted,
      //         onWebViewCreated: (WebViewController webViewController) {
      //           _controller.complete(webViewController);
      //         },
      //         onProgress: (int progress) {
      //           print("WebView is loading (progress : $progress%)");
      //         },
      //         javascriptChannels: <JavascriptChannel>{
      //           _toasterJavascriptChannel(context),
      //         },
      //         navigationDelegate: (NavigationRequest request) {
      //           if (request.url.startsWith(widget.targetURL)) {
      //             print('blocking navigation to $request}');
      //             return NavigationDecision.prevent;
      //           }
      //           print('allowing navigation to $request');
      //           return NavigationDecision.navigate;
      //         },
      //         onPageStarted: (String url) {
      //           print('Page started loading: $url');
      //           setState(() {
      //             _loading = true;
      //           });
      //         },
      //         onPageFinished: (String url) {
      //           print('Page finished loading: $url');
      //           setState(() {
      //             _loading = false;
      //           });
      //         },
      //         gestureNavigationEnabled: true,
      //       );
      //     }),
      //   ),
      // ),
      body: Builder(builder: (BuildContext context) {
        return WebView(
          initialUrl: widget.targetURL,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _controller.complete(webViewController);
          },
          onProgress: (int progress) {
            print("WebView is loading (progress : $progress%)");
          },
          javascriptChannels: <JavascriptChannel>{
            _toasterJavascriptChannel(context),
          },
          navigationDelegate: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              print('blocking navigation to $request}');
              return NavigationDecision.prevent;
            }
            print('allowing navigation to $request');
            return NavigationDecision.navigate;
          },
          onPageStarted: (String url) {
            print('Page started loading: $url');
          },
          onPageFinished: (String url) {
            print('Page finished loading: $url');
          },
          gestureNavigationEnabled: true,
        );
      }),
      // floatingActionButton: favoriteButton(),
    );
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }

  Widget favoriteButton() {
    return FutureBuilder<WebViewController>(
        future: _controller.future,
        builder: (BuildContext context,
            AsyncSnapshot<WebViewController> controller) {
          if (controller.hasData) {
            return FloatingActionButton(
              onPressed: () async {
                final String url = (await controller.data!.currentUrl())!;
                // ignore: deprecated_member_use
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Favorited $url')),
                );
              },
              child: const Icon(Icons.favorite),
            );
          }
          return Container();
        });
  }
}

class WebNavigationControls extends StatelessWidget {
  const WebNavigationControls(this._webViewControllerFuture, this.url)
      : assert(_webViewControllerFuture != null);

  final Future<WebViewController> _webViewControllerFuture;
  final String url;

  /// Open Browser
  void _onOpenBrowser(
    WebViewController controller,
    BuildContext context,
  ) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Open Browser"),
    ));
  }

  void showSnackBar(
    String textData,
    BuildContext context,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(textData),
      duration: const Duration(seconds: 1),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: _webViewControllerFuture,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
        final bool webViewReady =
            snapshot.connectionState == ConnectionState.done;
        final WebViewController? controller = snapshot.data;
        return Column(
          children: <Widget>[
            /// Home
            ListTile(
              title: Row(
                children: [
                  Icon(
                    Icons.home,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  Text(
                    'Back to App',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              onTap: () {
                int count = 0;
                Navigator.popUntil(context, (route) {
                  return count++ == 2;
                });
              },
            ),

            /// Reload Page
            ListTile(
              title: Row(
                children: [
                  Icon(
                    Icons.refresh,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  Text(
                    'Reload Page',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              onTap: () {
                if (webViewReady) {
                  controller!.reload();
                }
                Navigator.pop(context);
              },
            ),

            /// Go Back
            ListTile(
              title: Row(
                children: [
                  Icon(
                    Icons.arrow_back,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  Text(
                    'Go to Previous Page',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              onTap: () async {
                if (webViewReady) {
                  if (await controller!.canGoBack()) {
                    await controller.goBack();
                  } else {
                    showSnackBar('No back history item', context);
                    return;
                  }
                }

                Navigator.pop(context);
              },
            ),

            /// Go Forward
            ListTile(
              title: Row(
                children: [
                  Icon(
                    Icons.arrow_forward,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  Text(
                    'Go to Next Page',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              onTap: () async {
                if (webViewReady) {
                  if (await controller!.canGoForward()) {
                    await controller.goForward();
                  } else {
                    showSnackBar('No forward history item', context);
                    return;
                  }
                }

                Navigator.pop(context);
              },
            ),

            /// Open In Browser
            ListTile(
              title: Row(
                children: [
                  Icon(
                    Icons.open_in_browser,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  Text(
                    'Open In Browser',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              onTap: () {
                _onOpenBrowser(controller!, context);
                Navigator.pop(context);
              },
            ),

            // /// Clear Cache
            // ListTile(
            //   title: Row(
            //     children: [
            //       IconButton(
            //         icon: const Icon(
            //           Icons.arrow_back,
            //           color: Colors.white,
            //         ),
            //         onPressed: !webViewReady
            //             ? null
            //             : () async {
            //           if (await controller.canGoBack()) {
            //             await controller.goBack();
            //           } else {
            //             Scaffold.of(context).showSnackBar(
            //               const SnackBar(
            //                   content: Text("No back history item")),
            //             );
            //             return;
            //           }
            //         },
            //       ),
            //       Text(
            //         'Go to Previous Page',
            //         style: TextStyle(
            //           color: Colors.white,
            //         ),
            //       ),
            //     ],
            //   ),
            //   onTap: () {
            //     Navigator.pop(context);
            //   },
            // ),
          ],
        );
        // return Row(
        //   children: <Widget>[
        //     IconButton(
        //       icon: const Icon(Icons.arrow_back_ios),
        //       onPressed: !webViewReady
        //           ? null
        //           : () async {
        //         if (await controller!.canGoBack()) {
        //           await controller.goBack();
        //         } else {
        //           // ignore: deprecated_member_use
        //           Scaffold.of(context).showSnackBar(
        //             const SnackBar(content: Text("No back history item")),
        //           );
        //           return;
        //         }
        //       },
        //     ),
        //     IconButton(
        //       icon: const Icon(Icons.arrow_forward_ios),
        //       onPressed: !webViewReady
        //           ? null
        //           : () async {
        //         if (await controller!.canGoForward()) {
        //           await controller.goForward();
        //         } else {
        //           // ignore: deprecated_member_use
        //           Scaffold.of(context).showSnackBar(
        //             const SnackBar(
        //                 content: Text("No forward history item")),
        //           );
        //           return;
        //         }
        //       },
        //     ),
        //     IconButton(
        //       icon: const Icon(Icons.replay),
        //       onPressed: !webViewReady
        //           ? null
        //           : () {
        //         controller!.reload();
        //       },
        //     ),
        //   ],
        // );
      },
    );
  }
}
