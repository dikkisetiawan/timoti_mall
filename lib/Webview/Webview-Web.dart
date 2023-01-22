import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:timoti_project/Cart/Order-Completed-Page.dart';
import 'package:timoti_project/Cart/Payment-Failed-Page.dart';
import 'package:timoti_project/Functions/Messager.dart';
import 'package:timoti_project/Test-Runner.dart';
import 'dart:ui' as ui;

import 'package:webviewx/webviewx.dart';

// void main() {
//   // runApp(TestRunner(
//   //   targetWidget: WebViewXPage(),
//   // ));
//   runApp(TestRunner(
//     targetWidget: WebViewWebEx(
//       paymentID: null,
//       title: "Test",
//       targetURL: 'https://flutter.dev',
//       orderIDS: ['OrderA'],
//     ),
//   ));
// }

class WebViewWeb extends StatefulWidget {
  final String title;
  final String targetURL;
  final String? paymentID;
  final List<String> orderIDS;

  const WebViewWeb({
    Key? key,
    required this.title,
    required this.targetURL,
    required this.paymentID,
    required this.orderIDS,
  }) : super(key: key);

  @override
  State<WebViewWeb> createState() => _WebViewWebState();
}

class _WebViewWebState extends State<WebViewWeb> {
  late WebViewXController webviewController;

  @override
  void initState() {
    super.initState();
    webviewController.loadContent(
      widget.targetURL,
      SourceType.url,
    );
    getPaymentStatusRT(widget.paymentID, widget.orderIDS);
  }

  Future<void> getPaymentStatusRT(
    String? paymentID,
    List<String> orderIDS,
  ) async {
    if (paymentID == null) {
      print("Payment ID is null");
      return;
    }

    User? firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      return;
    }

    if (firebaseUser.isAnonymous == true) {
      return;
    }

    await FirebaseFirestore.instance
        .collection("Payment")
        .doc(paymentID)
        .snapshots()
        .listen((value) {
      /// Define Temp Map Data
      Map<String, dynamic>? tempMapData = Map<String, dynamic>();

      /// Assign Data
      tempMapData = value.data() as Map<String, dynamic>;

      if (tempMapData["Status"] != null) {
        if (tempMapData["Status"] != '') {
          /// Success
          if (tempMapData["Status"] == '88 - Transferred') {
            /// Go to Order Completed Page
            Navigator.pushReplacement(
              context,
              PageTransition(
                type: PageTransitionType.rightToLeft,
                child: OrderCompletedPage(orderIDs: orderIDS),
              ),
            );
          }

          /// Failed
          else if (tempMapData["Status"] == '66 - Failed') {
            Navigator.pushReplacement(
              context,
              PageTransition(
                type: PageTransitionType.rightToLeft,
                child: PaymentFailedPage(orderIDs: widget.orderIDS),
              ),
            );
          }
        }
      }
    });
  }

  // @override
  // Widget build(BuildContext context) {
  //   // ignore: undefined_prefixed_name
  //   ui.platformViewRegistry.registerViewFactory(
  //     'WebView-html',
  //     (int viewId) => IFrameElement()
  //       // ..width = '640'
  //       // ..height = '360'
  //       ..src = widget.targetURL
  //       ..style.border = 'none',
  //   );
  //
  //   return Scaffold(
  //     appBar: AppBar(
  //       leading: InkWell(
  //         onTap: () => widget.paymentID != null
  //             ? Navigator.pushReplacement(
  //                 context,
  //                 PageTransition(
  //                   type: PageTransitionType.rightToLeft,
  //                   child: PaymentFailedPage(orderIDs: widget.orderIDS),
  //                 ),
  //               )
  //             : Navigator.pop(context),
  //         child: Icon(
  //           Icons.arrow_back_ios_sharp,
  //           color: Theme.of(context).primaryColor,
  //           size: 30,
  //         ),
  //       ),
  //       title: Text(
  //         widget.title,
  //         style: TextStyle(color: Theme.of(context).primaryColor),
  //       ),
  //       backgroundColor: Theme.of(context).backgroundColor,
  //       shadowColor: Colors.grey,
  //       elevation: 3,
  //     ),
  //     body: Directionality(
  //       textDirection: TextDirection.ltr,
  //       child: HtmlElementView(viewType: 'WebView-html'),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () => widget.paymentID != null
              ? Navigator.pushReplacement(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: PaymentFailedPage(orderIDs: widget.orderIDS),
                  ),
                )
              : Navigator.pop(context),
          child: Icon(
            Icons.arrow_back_ios_sharp,
            color: Theme.of(context).primaryColor,
            size: 30,
          ),
        ),
        title: Text(
          widget.title,
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        shadowColor: Colors.grey,
        elevation: 3,
      ),
      body: WebViewX(
        height: 500,
        width: 500,
        onWebViewCreated: (controller) => webviewController = controller,
      ),
    );
  }
}

// Use this one
class WebViewWebEx extends StatefulWidget {
  final String title;
  final String targetURL;
  final String? paymentID;
  final List<String> orderIDS;

  const WebViewWebEx({
    Key? key,
    required this.title,
    required this.targetURL,
    required this.paymentID,
    required this.orderIDS,
  }) : super(key: key);

  @override
  _WebViewWebEXState createState() => _WebViewWebEXState();
}

class _WebViewWebEXState extends State<WebViewWebEx> {
  late WebViewXController webviewController;
  final initialContent =
      '<h4> This is some hardcoded HTML code embedded inside the webview <h4> <h2> Hello world! <h2>';
  final executeJsErrorMessage =
      'Failed to execute this task because the current content is (probably) URL that allows iframe embedding, on Web.\n\n'
      'A short reason for this is that, when a normal URL is embedded in the iframe, you do not actually own that content so you cant call your custom functions\n'
      '(read the documentation to find out why).';

  Size get screenSize => MediaQuery.of(context).size;

  @override
  void initState() {
    super.initState();
    getPaymentStatusRT(widget.paymentID, widget.orderIDS);
  }

  Future<void> getPaymentStatusRT(
    String? paymentID,
    List<String> orderIDS,
  ) async {
    if (paymentID == null) {
      print("Payment ID is null");
      return;
    }

    User? firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      return;
    }

    if (firebaseUser.isAnonymous == true) {
      return;
    }

    await FirebaseFirestore.instance
        .collection("Payment")
        .doc(paymentID)
        .snapshots()
        .listen((value) {
      /// Define Temp Map Data
      Map<String, dynamic>? tempMapData = Map<String, dynamic>();

      /// Assign Data
      tempMapData = value.data() as Map<String, dynamic>;

      if (tempMapData["Status"] != null) {
        if (tempMapData["Status"] != '') {
          /// Success
          if (tempMapData["Status"] == '88 - Transferred') {
            /// Go to Order Completed Page
            Navigator.pushReplacement(
              context,
              PageTransition(
                type: PageTransitionType.rightToLeft,
                child: OrderCompletedPage(orderIDs: orderIDS),
              ),
            );
          }

          /// Failed
          else if (tempMapData["Status"] == '66 - Failed') {
            Navigator.pushReplacement(
              context,
              PageTransition(
                type: PageTransitionType.rightToLeft,
                child: PaymentFailedPage(orderIDs: widget.orderIDS),
              ),
            );
          }
        }
      }
    });
  }

  @override
  void dispose() {
    webviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () => widget.paymentID != null
              ? Navigator.pushReplacement(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: PaymentFailedPage(orderIDs: widget.orderIDS),
                  ),
                )
              : Navigator.pop(context),
          child: Icon(
            Icons.arrow_back_ios_sharp,
            color: Theme.of(context).primaryColor,
            size: 30,
          ),
        ),
        title: Text(
          widget.title,
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        shadowColor: Colors.grey,
        elevation: 3,
      ),
      body: _buildWebViewX(),
    );
  }

  Widget _buildWebViewX() {
    return WebViewX(
      key: const ValueKey('webviewx'),
      initialContent: widget.targetURL,
      initialSourceType: SourceType.urlBypass,
      height: screenSize.height,
      width: screenSize.width,
      onWebViewCreated: (controller) => webviewController = controller,
      onPageStarted: (src) =>
          debugPrint('A new page has started loading: $src\n'),
      onPageFinished: (src) =>
          debugPrint('The page has finished loading: $src\n'),
      jsContent: const {
        EmbeddedJsContent(
          js: "function testPlatformIndependentMethod() { console.log('Hi from JS') }",
        ),
        EmbeddedJsContent(
          webJs:
              "function testPlatformSpecificMethod(msg) { TestDartCallback('Web callback says: ' + msg) }",
          mobileJs:
              "function testPlatformSpecificMethod(msg) { TestDartCallback.postMessage('Mobile callback says: ' + msg) }",
        ),
      },
      dartCallBacks: {
        DartCallback(
          name: 'TestDartCallback',
          callBack: (msg) => showSnackBar(msg.toString(), context),
        )
      },
      webSpecificParams: const WebSpecificParams(
        printDebugInfo: true,
      ),
      mobileSpecificParams: const MobileSpecificParams(
        androidEnableHybridComposition: true,
      ),
      navigationDelegate: (navigation) {
        debugPrint(navigation.content.sourceType.toString());
        return NavigationDecision.navigate;
      },
    );
  }
}

// region Example
class WebViewXPage extends StatefulWidget {
  const WebViewXPage({
    Key? key,
  }) : super(key: key);

  @override
  _WebViewXPageState createState() => _WebViewXPageState();
}

class _WebViewXPageState extends State<WebViewXPage> {
  late WebViewXController webviewController;
  final initialContent =
      '<h4> This is some hardcoded HTML code embedded inside the webview <h4> <h2> Hello world! <h2>';
  final executeJsErrorMessage =
      'Failed to execute this task because the current content is (probably) URL that allows iframe embedding, on Web.\n\n'
      'A short reason for this is that, when a normal URL is embedded in the iframe, you do not actually own that content so you cant call your custom functions\n'
      '(read the documentation to find out why).';

  Size get screenSize => MediaQuery.of(context).size;

  @override
  void dispose() {
    webviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebViewX Page'),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              buildSpace(direction: Axis.vertical, amount: 10.0, flex: false),
              Container(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  'Play around with the buttons below',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              buildSpace(direction: Axis.vertical, amount: 10.0, flex: false),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 0.2),
                ),
                child: _buildWebViewX(),
              ),
              Expanded(
                child: Scrollbar(
                  isAlwaysShown: true,
                  child: SizedBox(
                    width: min(screenSize.width * 0.8, 512),
                    child: ListView(
                      children: _buildButtons(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebViewX() {
    return WebViewX(
      key: const ValueKey('webviewx'),
      initialContent: initialContent,
      initialSourceType: SourceType.html,
      height: screenSize.height / 2,
      width: min(screenSize.width * 0.8, 1024),
      onWebViewCreated: (controller) => webviewController = controller,
      onPageStarted: (src) =>
          debugPrint('A new page has started loading: $src\n'),
      onPageFinished: (src) =>
          debugPrint('The page has finished loading: $src\n'),
      jsContent: const {
        EmbeddedJsContent(
          js: "function testPlatformIndependentMethod() { console.log('Hi from JS') }",
        ),
        EmbeddedJsContent(
          webJs:
              "function testPlatformSpecificMethod(msg) { TestDartCallback('Web callback says: ' + msg) }",
          mobileJs:
              "function testPlatformSpecificMethod(msg) { TestDartCallback.postMessage('Mobile callback says: ' + msg) }",
        ),
      },
      dartCallBacks: {
        DartCallback(
          name: 'TestDartCallback',
          callBack: (msg) => showSnackBar(msg.toString(), context),
        )
      },
      webSpecificParams: const WebSpecificParams(
        printDebugInfo: true,
      ),
      mobileSpecificParams: const MobileSpecificParams(
        androidEnableHybridComposition: true,
      ),
      navigationDelegate: (navigation) {
        debugPrint(navigation.content.sourceType.toString());
        return NavigationDecision.navigate;
      },
    );
  }

  void _setUrl() {
    webviewController.loadContent(
      'https://flutter.dev',
      SourceType.url,
    );
  }

  void _setUrlBypass() {
    webviewController.loadContent(
      'https://news.ycombinator.com/',
      SourceType.urlBypass,
    );
  }

  void _setHtml() {
    webviewController.loadContent(
      initialContent,
      SourceType.html,
    );
  }

  void _setHtmlFromAssets() {
    webviewController.loadContent(
      'assets/test.html',
      SourceType.html,
      fromAssets: true,
    );
  }

  Future<void> _goForward() async {
    if (await webviewController.canGoForward()) {
      await webviewController.goForward();
      showSnackBar('Did go forward', context);
    } else {
      showSnackBar('Cannot go forward', context);
    }
  }

  Future<void> _goBack() async {
    if (await webviewController.canGoBack()) {
      await webviewController.goBack();
      showSnackBar('Did go back', context);
    } else {
      showSnackBar('Cannot go back', context);
    }
  }

  void _reload() {
    webviewController.reload();
  }

  void _toggleIgnore() {
    final ignoring = webviewController.ignoresAllGestures;
    webviewController.setIgnoreAllGestures(!ignoring);
    showSnackBar('Ignore events = ${!ignoring}', context);
  }

  Future<void> _evalRawJsInGlobalContext() async {
    try {
      final result = await webviewController.evalRawJavascript(
        '2+2',
        inGlobalContext: true,
      );
      showSnackBar('The result is $result', context);
    } catch (e) {
      showAlertDialog(
        executeJsErrorMessage,
        context,
      );
    }
  }

  Future<void> _callPlatformIndependentJsMethod() async {
    try {
      await webviewController.callJsMethod('testPlatformIndependentMethod', []);
    } catch (e) {
      showAlertDialog(
        executeJsErrorMessage,
        context,
      );
    }
  }

  Future<void> _callPlatformSpecificJsMethod() async {
    try {
      await webviewController
          .callJsMethod('testPlatformSpecificMethod', ['Hi']);
    } catch (e) {
      showAlertDialog(
        executeJsErrorMessage,
        context,
      );
    }
  }

  Future<void> _getWebviewContent() async {
    try {
      final content = await webviewController.getContent();
      showAlertDialog(content.source, context);
    } catch (e) {
      showAlertDialog('Failed to execute this task.', context);
    }
  }

  Widget buildSpace({
    Axis direction = Axis.horizontal,
    double amount = 0.2,
    bool flex = true,
  }) {
    return flex
        ? Flexible(
            child: FractionallySizedBox(
              widthFactor: direction == Axis.horizontal ? amount : null,
              heightFactor: direction == Axis.vertical ? amount : null,
            ),
          )
        : SizedBox(
            width: direction == Axis.horizontal ? amount : null,
            height: direction == Axis.vertical ? amount : null,
          );
  }

  List<Widget> _buildButtons() {
    return [
      buildSpace(direction: Axis.vertical, flex: false, amount: 20.0),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: createButton(onTap: _goBack, text: 'Back')),
          buildSpace(amount: 12, flex: false),
          Expanded(child: createButton(onTap: _goForward, text: 'Forward')),
          buildSpace(amount: 12, flex: false),
          Expanded(child: createButton(onTap: _reload, text: 'Reload')),
        ],
      ),
      buildSpace(direction: Axis.vertical, flex: false, amount: 20.0),
      createButton(
        text:
            'Change content to URL that allows iframes embedding\n(https://flutter.dev)',
        onTap: _setUrl,
      ),
      buildSpace(direction: Axis.vertical, flex: false, amount: 20.0),
      createButton(
        text:
            'Change content to URL that doesnt allow iframes embedding\n(https://news.ycombinator.com/)',
        onTap: _setUrlBypass,
      ),
      buildSpace(direction: Axis.vertical, flex: false, amount: 20.0),
      createButton(
        text: 'Change content to HTML (hardcoded)',
        onTap: _setHtml,
      ),
      buildSpace(direction: Axis.vertical, flex: false, amount: 20.0),
      createButton(
        text: 'Change content to HTML (from assets)',
        onTap: _setHtmlFromAssets,
      ),
      buildSpace(direction: Axis.vertical, flex: false, amount: 20.0),
      createButton(
        text: 'Toggle on/off ignore any events (click, scroll etc)',
        onTap: _toggleIgnore,
      ),
      buildSpace(direction: Axis.vertical, flex: false, amount: 20.0),
      createButton(
        text: 'Evaluate 2+2 in the global "window" (javascript side)',
        onTap: _evalRawJsInGlobalContext,
      ),
      buildSpace(direction: Axis.vertical, flex: false, amount: 20.0),
      createButton(
        text: 'Call platform independent Js method (console.log)',
        onTap: _callPlatformIndependentJsMethod,
      ),
      buildSpace(direction: Axis.vertical, flex: false, amount: 20.0),
      createButton(
        text:
            'Call platform specific Js method, that calls back a Dart function',
        onTap: _callPlatformSpecificJsMethod,
      ),
      buildSpace(direction: Axis.vertical, flex: false, amount: 20.0),
      createButton(
        text: 'Show current webview content',
        onTap: _getWebviewContent,
      ),
    ];
  }
}

void showAlertDialog(String content, BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => WebViewAware(
      child: AlertDialog(
        content: Text(content),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Close'),
          ),
        ],
      ),
    ),
  );
}

Widget createButton({
  dynamic onTap,
  required String text,
}) {
  return ElevatedButton(
    onPressed: onTap,
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
    ),
    child: Text(text),
  );
}
// endregion