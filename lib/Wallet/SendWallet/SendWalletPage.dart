import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '/Api/CheckPhoneExist-Api/Fetch-CheckPhoneExist-Api.dart';
import '/Api/CustomerToken-Api/Fetch-GetToken-Api.dart';
import '/Api/SendWallet-Api/Fetch-SendWallet-Api.dart';
import '/CheckInternet/CheckInternetFunction.dart';
import '/Custom-UI/Custom-LoadingUI.dart';
import '/Screen-Size/Get-Device-Details.dart';
import '/Screen-Size/WidgetSizeCalculation.dart';
import '/Screen-Size/ui-utils.dart';
import '/Wallet/SendWallet/SendWallet-ThankYouPage.dart';
import '/enums/device-screen-type.dart';
import 'package:string_validator/string_validator.dart';

class SendWalletPage extends StatefulWidget {
  final String name;
  final String phoneNumber;

  SendWalletPage({
    required this.name,
    required this.phoneNumber,
  });

  @override
  _SendWalletPageState createState() => _SendWalletPageState();
}

class _SendWalletPageState extends State<SendWalletPage> {
  final formatCurrency = new NumberFormat.currency(
    locale: "ms-MY",
    symbol: "",
    decimalDigits: 2,
  );
  bool phoneExist = false;
  String receiverID = '';

  String walletAmount = '0';
  bool loading = false;

  void initState() {
    checkPhoneExistAPI().then((value) {
      if (phoneExist == true) {
        getWalletAmountInit();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> checkPhoneExistAPI() async {
    if (this.mounted) {
      loading = true;
      setState(() {});
    }

    await fetchCheckPhoneApi(widget.phoneNumber).then((value) {
      if (value.isExist == true) {
        if (this.mounted) {
          receiverID = value.customerId as String;
          phoneExist = true;
          loading = false;
          setState(() {});
        }
      } else {
        if (this.mounted) {
          phoneExist = false;
          loading = false;
          setState(() {});
        }
      }
    });
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

  PreferredSize getCustomAppBar(
    String title,
    WidgetSizeCalculation _widgetSize,
    DeviceDetails _deviceDetails,
    BuildContext context,
  ) {
    var mediaQuery = MediaQuery.of(context);

    return PreferredSize(
      preferredSize: getDeviceType(mediaQuery) == DeviceScreenType.Mobile
          ? Size.fromHeight(55.0)
          : Size.fromHeight(80.0),
      child: Material(
        elevation: 8,
        shadowColor: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  decoration:
                      BoxDecoration(color: Theme.of(context).backgroundColor),
                ),
                SafeArea(
                  minimum: getDeviceType(mediaQuery) == DeviceScreenType.Mobile
                      ? EdgeInsets.fromLTRB(
                          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                          0,
                          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                          0,
                        )
                      : EdgeInsets.fromLTRB(
                          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                          0,
                          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                          0,
                        ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// Empty Box
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.arrow_back_ios_sharp,
                          color: Theme.of(context).primaryColor,
                          size:
                              _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                        ),
                      ),

                      /// Title
                      SizedBox(
                        width:
                            getDeviceType(mediaQuery) == DeviceScreenType.Mobile
                                ? _widgetSize.getResponsiveWidth(0.6, 0.6, 0.6)
                                : _widgetSize.getResponsiveWidth(0.5, 0.5, 0.5),
                        child: Center(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: _deviceDetails.getTitleFontSize(),
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      /// Empty
                      SizedBox(
                        width: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);

    return Scaffold(
      appBar: getCustomAppBar(
        "Send Money",
        _widgetSize,
        _deviceDetails,
        context,
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
            minWidth: MediaQuery.of(context).size.width,
          ),
          child: loading == true
              ? Center(
                  child: CustomLoading(),
                )
              : SingleChildScrollView(
                  child: phoneExist == false
                      ?

                      /// Stateless Widget Not Exist Phone No
                      UserNotExistUI(
                          widgetSize: _widgetSize,
                          deviceDetails: _deviceDetails,
                          phoneNumber: widget.phoneNumber,
                          name: widget.name,
                        )
                      :

                      /// Phone Exist
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Wallet Balance
                            Container(
                              width: _widgetSize.getResponsiveWidth(1, 1, 1),
                              height:
                                  _widgetSize.getResponsiveWidth(0.2, 0.2, 0.2),
                              color: Theme.of(context).shadowColor,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: _widgetSize.getResponsiveWidth(
                                            0.05, 0.05, 0.05)),
                                    child: Image.asset(
                                      'assets/icon/logo.png',
                                      width: _widgetSize.getResponsiveWidth(
                                          0.1, 0.1, 0.1),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "Wallet Balance: ",
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w400,
                                      fontSize:
                                          _deviceDetails.getNormalFontSize(),
                                    ),
                                  ),
                                  Text(
                                    "RM " +
                                        formatCurrency
                                            .format(double.parse(walletAmount))
                                            .toString(),
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w400,
                                      fontSize:
                                          _deviceDetails.getNormalFontSize(),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// Stateless Receiver Name
                            ReceiverNameUI(
                              widgetSize: _widgetSize,
                              deviceDetails: _deviceDetails,
                              phoneNumber: widget.phoneNumber,
                              name: widget.name,
                            ),

                            /// Input Field and Note
                            SendWalletInputField(
                              walletAmount: walletAmount,
                              targetUID: receiverID,
                              widgetSize: _widgetSize,
                              deviceDetails: _deviceDetails,
                              formatCurrency: formatCurrency,
                            ),
                          ],
                        ),
                ),
        ),
      ),
    );
  }
}

// region User Not Exist
class UserNotExistUI extends StatelessWidget {
  final String name;
  final String phoneNumber;
  final WidgetSizeCalculation widgetSize;
  final DeviceDetails deviceDetails;

  UserNotExistUI({
    required this.name,
    required this.phoneNumber,
    required this.deviceDetails,
    required this.widgetSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: widgetSize.getResponsiveHeight(0.15, 0.15, 0.15)),
        Icon(
          Icons.error,
          color: Theme.of(context).primaryColor,
          size: widgetSize.getResponsiveWidth(0.25, 0.25, 0.25),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
              widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
              widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
              widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
              0),
          child: Text(
            "Oops, User Not Exist!",
            style: TextStyle(
              fontSize: deviceDetails.getTitleFontSize(),
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
              widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
              widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
              widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
              0),
          child: Text(
            "Ask your friend to register this App!",
            style: TextStyle(
              fontSize: deviceDetails.getNormalFontSize(),
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
              widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
              widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
              widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
              0),
          child: Text(
            name + " (" + phoneNumber + ")",
            style: TextStyle(
              fontSize: deviceDetails.getNormalFontSize(),
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
// endregion

// region Receiver UI
class ReceiverNameUI extends StatelessWidget {
  final String name;
  final String phoneNumber;
  final WidgetSizeCalculation widgetSize;
  final DeviceDetails deviceDetails;

  ReceiverNameUI({
    required this.name,
    required this.phoneNumber,
    required this.deviceDetails,
    required this.widgetSize,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
        widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
        widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
        widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: 8.0),
        child: Wrap(
          children: [
            Text(
              "You are sending to ",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                color: Theme.of(context).primaryColor,
                fontSize: deviceDetails.getNormalFontSize(),
              ),
            ),
            Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                color: Theme.of(context).highlightColor,
                fontSize: deviceDetails.getNormalFontSize(),
              ),
            ),
            Text(
              " (" + phoneNumber + ")",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                color: Theme.of(context).highlightColor,
                fontSize: deviceDetails.getNormalFontSize(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
// endregion

// region Send Wallet UI
class SendWalletInputField extends StatefulWidget {
  final WidgetSizeCalculation widgetSize;
  final DeviceDetails deviceDetails;
  final NumberFormat formatCurrency;
  final String targetUID;
  final String walletAmount;

  SendWalletInputField({
    required this.widgetSize,
    required this.deviceDetails,
    required this.formatCurrency,
    required this.targetUID,
    required this.walletAmount,
  });

  @override
  _SendWalletInputFieldState createState() => _SendWalletInputFieldState();
}

class _SendWalletInputFieldState extends State<SendWalletInputField> {
  TextEditingController _amountController = TextEditingController();
  TextEditingController _noteController = TextEditingController();
  String validateErrorString = '';
  bool _amountError = false;

  bool _loading = false;

  void initState() {
    _loading = false;
    super.initState();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // region UI
  Widget getSendButton(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
    String receiverID,
  ) {
    return Center(
      child: InkWell(
        onTap: _loading == true
            ? null
            : () {
                FocusScope.of(context).unfocus();
                if (validate() == true) {
                  hasInternet().then((value) async {
                    if (value == true) {
                      final user = FirebaseAuth.instance.currentUser;
                      user?.getIdTokenResult().then((value) {
                        _loading = true;
                        setState(() {});
                        // log(value.token as String);
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
                            print("Error Message: " +
                                (value.errorMessage as String));
                            _loading = false;
                            setState(() {});
                          }
                        });
                      });
                    }
                  });
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
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            0,
            0,
            0,
            _widgetSize.getResponsiveHeight(0.01, 0.01, 0.01),
          ),
          child: Text(
            "Amount",
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: _deviceDetails.getNormalFontSize(),
            ),
          ),
        ),
        SizedBox(
          width: _widgetSize.getResponsiveWidth(1, 1, 1),
          height: _widgetSize.getResponsiveHeight(0.17, 0.17, 0.17),
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
    );
  }

  Widget getNoteUI(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }

  void showSnackBar(String myString) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(myString),
      duration: const Duration(seconds: 1),
      // action: SnackBarAction(
      //   label: 'ACTION',
      //   onPressed: () { },
      // ),
    ));
  }
  // endregion

  // region Function
  Future<String> getToken() async {
    if (!mounted) {
      return '';
    }

    String token = '';
    await FirebaseFirestore.instance
        .collection('Setting_Config')
        .doc('ApiUserInfo')
        .get()
        .then((value) {
      if (value["AccessToken"] != null) {
        if (value["AccessToken"] != '') {
          token = value["AccessToken"];
          // print("Token: " + token);
        }
      }
    });

    setState(() {});

    return token;
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
    // print("Token: " + token);
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

  bool validate() {
    bool temp = false;
    if (_amountController.text.isEmpty) {
      _amountError = true;
      _amountController.text = 'Please enter your preferred amount';
    } else if (!isInt(_amountController.text)) {
      _amountController.clear();
      _amountError = true;
    } else if (double.parse(_amountController.text) >
        double.parse(widget.walletAmount)) {
      _amountController.text = 'Max Amount is RM ${widget.walletAmount}';
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
    return Padding(
      padding: EdgeInsets.fromLTRB(
        widget.widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
        0,
        widget.widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
        0,
      ),
      child: Column(
        children: [
          /// Input Amount
          getAmountInputUI(widget.deviceDetails, widget.widgetSize),

          /// Note
          getNoteUI(widget.deviceDetails, widget.widgetSize),

          /// Spacing
          SizedBox(
            height: widget.widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
          ),

          /// Send button
          getSendButton(
              widget.deviceDetails, widget.widgetSize, widget.targetUID),

          /// Spacing
          SizedBox(
            height: widget.widgetSize.getResponsiveHeight(0.1, 0.1, 0.1),
          ),
        ],
      ),
    );
  }
}
// endregion
