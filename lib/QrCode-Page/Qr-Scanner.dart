import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/Api/CustomerToken-Api/Fetch-GetToken-Api.dart';
import '/Api/SendWallet-Api/Fetch-SendWallet-Api.dart';
import '/CheckInternet/CheckInternetFunction.dart';
import '/Custom-UI/Custom-LoadingUI.dart';
import '/Screen-Size/Get-Device-Details.dart';
import '/Wallet/SendWallet/SendWallet-ThankYouPage.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '/Screen-Size/WidgetSizeCalculation.dart';
import 'package:string_validator/string_validator.dart';
import 'package:intl/intl.dart';

class QrScanner extends StatefulWidget {
  static const routeName = '/QrScanner';
  const QrScanner({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QrScannerState();
}

class _QrScannerState extends State<QrScanner> {
  final formatCurrency = new NumberFormat.currency(
    locale: "ms-MY",
    symbol: "",
    decimalDigits: 2,
  );

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isWalletLoading = false;
  String walletAmount = '0';

  TextEditingController _amountController = TextEditingController();
  TextEditingController _noteController = TextEditingController();
  String validateErrorString = '';
  bool _amountError = false;

  bool _loading = false;
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void initState() {
    getWalletAmountInit();
    super.initState();
  }

  @override
  void dispose() {
    if (controller != null) {
      controller?.dispose();
    }
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  /// Get Wallet Amount In Real Time Update
  void getWalletAmountInit() async {
    User firebaseUser = FirebaseAuth.instance.currentUser as User;

    FirebaseFirestore.instance
        .collection("Customers")
        .doc(firebaseUser.uid)
        .snapshots()
        .listen((value) {
      /// Define Temp Map Data
      Map<String, dynamic> walletMapData = Map<String, dynamic>();

      /// Assign Data
      walletMapData = value.data() as Map<String, dynamic>;

      if (walletMapData["walletAmount"] != null) {
        if (walletMapData["walletAmount"] != '') {
          walletAmount = walletMapData["walletAmount"];
          if (this.mounted) {
            setState(() {});
          }
        }
      } else {
        walletAmount = '0';
        if (this.mounted) {
          setState(() {});
        }
      }
    });
  }

  // region UI
  Widget getSendButton(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
    String receiverID,
  ) {
    return Center(
      child: InkWell(
        onTap: () {
          if (_loading == false) {
            FocusScope.of(context).unfocus();
            if (validate() == true) {
              hasInternet().then((value) async {
                if (value == true) {
                  final user = FirebaseAuth.instance.currentUser;
                  user?.getIdTokenResult().then((value) {
                    // log(value.token as String);
                    _loading = true;
                    setState(() {});
                    fetchGetTokenApi(value.token as String).then((value) {
                      if (value.errorMessage == null) {
                        // log(value.accessToken as String);
                        sendWallet(
                          _deviceDetails,
                          value.accessToken as String,
                          user.uid,
                          receiverID,
                          _amountController.text,
                          _noteController.text,
                        );
                      } else {
                        print(
                            "Error Message: " + (value.errorMessage as String));
                        _loading = false;
                        setState(() {});
                      }
                    });
                  });
                } else {
                  /// No internet
                  showSnackBar();
                }
              });
            }
          }
        },
        child: Container(
          width: _widgetSize.getResponsiveWidth(0.5, 0.5, 0.5),
          height: _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
          decoration: BoxDecoration(
            color: Theme.of(context).highlightColor,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: _loading == true
                ? CustomLoading()
                : Text(
                    "Send",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: _deviceDetails.getNormalFontSize(),
                      color: Theme.of(context).backgroundColor,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  /// Get Bearer Token
  Future<String> getToken() async {
    String token = '';
    await FirebaseFirestore.instance
        .collection('Setting_Config')
        .doc('ApiUserInfo')
        .get()
        .then((value) {
      /// Define Temp Map Data
      Map<String, dynamic> apiMapData = Map<String, dynamic>();

      /// Assign Data
      apiMapData = value.data() as Map<String, dynamic>;

      if (apiMapData["AccessToken"] != null) {
        if (apiMapData["AccessToken"] != '') {
          token = apiMapData["AccessToken"];
          // print("Token: " + token);
        }
      }
    });

    setState(() {});

    return token;
  }

  Widget textCustomInputBorder(
    TextEditingController controller,
    String labelText,
    String hintText,
    bool verification,
    String errorText,
    bool hiddenInput,
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    return TextField(
      onTap: () {
        hintText = '';
        labelText = "";
      },
      onChanged: (value) {
        checkValue(value);
      },
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
      ],
      controller: controller,
      style: TextStyle(
        fontSize: _deviceDetails.getTitleFontSize(),
        height: 2.0,
        color:
            verification == true ? Colors.red : Theme.of(context).primaryColor,
      ),
      cursorColor: Theme.of(context).primaryColor,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(context).shadowColor,
        labelText: labelText,
        labelStyle: TextStyle(
          color: verification == true
              ? Colors.red
              : Theme.of(context).primaryColor,
          fontSize: _deviceDetails.getNormalFontSize(),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: new BorderSide(
            color: verification == true
                ? Colors.red
                : Theme.of(context).highlightColor,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: new BorderSide(
            color: verification == true
                ? Colors.red
                : Theme.of(context).highlightColor,
          ),
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey,
          fontSize: _deviceDetails.getNormalFontSize() - 2,
        ),
      ),
      obscureText: hiddenInput,
    );
  }

  Widget getAmountInputUI(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    return SizedBox(
      width: _widgetSize.getResponsiveWidth(1, 1, 1),
      height: _widgetSize.getResponsiveHeight(0.17, 0.17, 0.17),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
              0,
              _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
              0,
            ),
            child: textCustomInputBorder(
              _amountController,
              "Enter your preferred amount",
              "",
              _amountError,
              validateErrorString,
              false,
              _deviceDetails,
              _widgetSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget getNoteUI(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    return Padding(
      padding:
          EdgeInsets.only(left: _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1)),
      child: Wrap(
        direction: Axis.vertical,
        crossAxisAlignment: WrapCrossAlignment.start,
        children: <Widget>[
          /// Title
          Padding(
            padding: EdgeInsets.fromLTRB(
              0,
              0,
              0,
              _widgetSize.getResponsiveHeight(0.01, 0.01, 0.01),
            ),
            child: Text(
              "Note",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: _deviceDetails.getNormalFontSize(),
              ),
            ),
          ),
          Container(
            height: _widgetSize.getResponsiveHeight(0.15, 0.15, 0.15),
            width: _widgetSize.getResponsiveWidth(0.8, 0.8, 0.8),
            color: Theme.of(context).shadowColor,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                cursorColor: Theme.of(context).primaryColor,
                inputFormatters: <TextInputFormatter>[
                  LengthLimitingTextInputFormatter(50),
                ],
                controller: _noteController,
                maxLines: 6,
                style: TextStyle(
                  fontSize: _deviceDetails.getNormalFontSize(),
                  color: Theme.of(context).primaryColor,
                ),
                decoration: InputDecoration.collapsed(
                  hintText: "Enter your note here (Max 50 Characters)",
                  hintStyle: TextStyle(
                    fontSize: _deviceDetails.getNormalFontSize(),
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQrView(
    BuildContext context,
    WidgetSizeCalculation _widgetSize,
  ) {
    return QRView(
      key: qrKey,
      cameraFacing: CameraFacing.back,
      onQRViewCreated: _onQRViewCreated,
      formatsAllowed: [BarcodeFormat.qrcode],
      overlay: QrScannerOverlayShape(
        borderColor: Theme.of(context).highlightColor,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: _widgetSize.getResponsiveWidth(0.55, 0.55, 0.55),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  // endregion

  // region Function
  void showSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('No internet connection'),
      duration: const Duration(seconds: 1),
      // action: SnackBarAction(
      //   label: 'ACTION',
      //   onPressed: () { },
      // ),
    ));
  }

  /// Call Wallet API
  void sendWallet(
    DeviceDetails _deviceDetails,
    String token,
    String senderID,
    String receiverID,
    String amount,
    String note,
  ) async {
    _loading = true;
    setState(() {});
    // print('senderID: ' + senderID);
    // print('receiverID: ' + receiverID);
    // print('amount: ' + amount);
    // print('note: ' + note);

    await fetchSendWalletApi(
      token,
      senderID,
      receiverID,
      amount,
      note,
    ).then((value) {
      if (value.isSuccess == true) {
        _loading = false;
        setState(() {});

        Navigator.popAndPushNamed(context, SendThankYouPage.routeName);

        // showDialog(
        //   context: context,
        //   barrierDismissible: false,
        //   builder: (BuildContext context) {
        //     return AlertDialog(
        //       // title: Text(""),
        //       backgroundColor: Theme.of(context).highlightColor,
        //       content: Text(
        //         'Send Wallet Successful',
        //         style: TextStyle(
        //           color: Theme.of(context).backgroundColor,
        //           fontSize: _deviceDetails.getNormalFontSize(),
        //           fontWeight: FontWeight.w700,
        //         ),
        //       ),
        //       actions: [
        //         FlatButton(
        //           child: Text(
        //             "Ok",
        //             style: TextStyle(
        //               fontWeight: FontWeight.w700,
        //               color: Theme.of(context).backgroundColor,
        //               fontSize: _deviceDetails.getNormalFontSize(),
        //             ),
        //           ),
        //           onPressed: () {
        //             Navigator.of(context).pop();
        //           },
        //         ),
        //       ],
        //     );
        //   },
        // );
      } else {
        _loading = false;
        setState(() {});

        /// Show Error Message
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              // title: Text(""),
              backgroundColor: Theme.of(context).highlightColor,
              content: Text(
                value.errorMessage as String,
                style: TextStyle(
                  color: Theme.of(context).backgroundColor,
                  fontSize: _deviceDetails.getNormalFontSize(),
                  fontWeight: FontWeight.w700,
                ),
              ),
              actions: [
                TextButton(
                  child: Text(
                    "Ok",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).backgroundColor,
                      fontSize: _deviceDetails.getNormalFontSize(),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    });
  }

  void checkValue(String value) {
    if (int.parse(value) > double.parse(walletAmount)) {
      _amountController.text = walletAmount;
    } else if (int.parse(value) < 1) {
      _amountController.text = 1.toString();
    }
  }

  bool validate() {
    bool temp = false;
    if (_amountController.text.isEmpty) {
      _amountError = true;
      _amountController.text = 'Please enter your preferred amount';
    } else if (!isInt(_amountController.text)) {
      _amountController.clear();
      _amountError = true;
    } else if (double.parse(_amountController.text) >
        double.parse(walletAmount)) {
      _amountController.text = 'Max Amount is RM $walletAmount';
      _amountError = true;
    } else {
      _amountError = false;
      temp = true;
    }
    return temp;
  }
  // endregion

  @override
  Widget build(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
            // print('out');
          },
          child: Icon(
            Icons.arrow_back_ios_sharp,
            color: Theme.of(context).primaryColor,
            size: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
          ),
        ),
        title: Text(
          "Scan To Pay",
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        shadowColor: Colors.grey,
        elevation: 3,
      ),
      body: result == null
          ?

          /// Before Scan
          Stack(
              children: <Widget>[
                Container(child: _buildQrView(context, _widgetSize)),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    /// Flash Light
                    Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).shadowColor,
                          borderRadius: BorderRadius.circular(20)),
                      width: _widgetSize.getResponsiveWidth(0.5, 0.5, 0.5),
                      height: _widgetSize.getResponsiveWidth(0.15, 0.15, 0.15),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            controller?.toggleFlash();
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.highlight,
                              color: Theme.of(context).primaryColor,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Tap to turn on light',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w600),
                            )
                          ],
                        ),
                      ),
                    ),

                    /// Spacing
                    SizedBox(
                      height: 10,
                    ),

                    /// Wallet Balance
                    Container(
                      width: _widgetSize.getResponsiveWidth(1, 1, 1),
                      height: _widgetSize.getResponsiveWidth(0.2, 0.2, 0.2),
                      color: Theme.of(context).shadowColor,
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                left: _widgetSize.getResponsiveWidth(
                                    0.05, 0.05, 0.05)),
                            child: Image.asset(
                              'assets/icon/logo.png',
                              width:
                                  _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: _widgetSize.getResponsiveWidth(
                                    0.03, 0.03, 0.03)),
                            child: Text(
                              "Wallet Balance: ",
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: _deviceDetails.getNormalFontSize(),
                              ),
                            ),
                          ),
                          Text(
                            "RM " +
                                formatCurrency
                                    .format(double.parse(walletAmount))
                                    .toString(),
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: _deviceDetails.getTitleFontSize(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            )
          :

          /// After Scan
          SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text(
                  //     'Barcode Type: ${describeEnum(result.format)}   Data: ${result.code}'),
                  /// Wallet Balance
                  Container(
                    width: _widgetSize.getResponsiveWidth(1, 1, 1),
                    height: _widgetSize.getResponsiveWidth(0.2, 0.2, 0.2),
                    color: Theme.of(context).shadowColor,
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: _widgetSize.getResponsiveWidth(
                                  0.05, 0.05, 0.05)),
                          child: Image.asset(
                            'assets/icon/logo.png',
                            width:
                                _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: _widgetSize.getResponsiveWidth(
                                  0.03, 0.03, 0.03)),
                          child: Text(
                            "Wallet Balance: ",
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: _deviceDetails.getNormalFontSize(),
                            ),
                          ),
                        ),
                        Text(
                          "RM " +
                              formatCurrency
                                  .format(double.parse(walletAmount))
                                  .toString(),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: _deviceDetails.getTitleFontSize(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// Spacing
                  SizedBox(
                    height: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                  ),

                  if (result != null)
                    Padding(
                      padding: EdgeInsets.only(
                          left: _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1)),
                      child: Text(
                        "You are sending to ${result?.code?.split(':')[1]}",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                          fontSize: _deviceDetails.getNormalFontSize(),
                        ),
                      ),
                    ),

                  /// Spacing
                  SizedBox(
                    height: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                  ),

                  /// Input Amount
                  getAmountInputUI(_deviceDetails, _widgetSize),

                  // /// Spacing
                  // SizedBox(height: _widgetSize.getResponsiveWidth(0.05,0.05,0.05),),

                  /// Note
                  getNoteUI(_deviceDetails, _widgetSize),

                  /// Spacing
                  SizedBox(
                    height: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                  ),

                  /// Send button
                  if (result != null)
                    getSendButton(_deviceDetails, _widgetSize,
                        result?.code?.split(':')[0] as String)
                ],
              ),
            ),
    );
  }
}
