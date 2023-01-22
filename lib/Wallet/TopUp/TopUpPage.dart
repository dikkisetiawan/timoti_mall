import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:timoti_project/Api/BillPlz-TopUp-Api/Fetch-TopUp-BillPlz-Api.dart';
import 'package:timoti_project/Api/CustomerToken-Api/Fetch-GetToken-Api.dart';
import 'package:timoti_project/Api/Payex-TopUp-Api/Fetch-TopUp-BillPlz-Api.dart';
import 'package:timoti_project/CheckInternet/CheckInternetFunction.dart';
import 'package:timoti_project/Custom-UI/Custom-DefaultAppBar.dart';
import 'package:timoti_project/Custom-UI/Custom-LoadingUI.dart';
import 'package:timoti_project/Data-Class/PaymentMethodResultClass.dart';
import 'package:timoti_project/Functions/Messager.dart';
import 'package:timoti_project/Functions/Wallet-Amount-RealTime.dart';
import 'package:timoti_project/Screen-Size/Get-Device-Details.dart';
import 'package:timoti_project/Screen-Size/WidgetSizeCalculation.dart';
import 'package:timoti_project/Webview/Webview.dart';
import 'package:timoti_project/enums/Payment-Method-Type.dart';
import 'package:page_transition/page_transition.dart';
import 'package:string_validator/string_validator.dart';
import 'package:url_launcher/url_launcher.dart';

class TopUpPage extends StatefulWidget {
  static const routeName = '/Top-Up-Page';

  @override
  _TopUpPageState createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  bool isLoading = false;
  TextEditingController _amountController = TextEditingController();
  String validateErrorString = '';
  bool _amountError = false;
  int maxAmount = 300;
  int minAmount = 10;

  var formatCurrency = new NumberFormat.currency(
    locale: "en_US",
    symbol: "",
    decimalDigits: 0,
  );
  String walletAmount = '0';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void setLoadingStatus(bool value) {
    isLoading = value;
    if (this.mounted) {
      setState(() {});
    }
  }

  void checkValue(String value) {
    if (int.parse(value) > maxAmount) {
      _amountController.text = maxAmount.toString();
    }
  }

  // region UI
  String getTargetTopUpMethodString(PaymentMethodResultClass data) {
    /// BillPlz Payment
    if (data.type == PaymentMethodType.BillPlz) {
      return "Pay by: BillPlz Payment";
    }

    /// Payex Payment
    else if (data.type == PaymentMethodType.Payex) {
      return "Pay by: Payex Payment";
    }

    /// EGHL Payment
    else {
      if (data.type == PaymentMethodType.EGHL) {}
      return "Pay by: EGHL Payment";
    }
  }

  /// Data UI
  Widget getTopUpMethodUI(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
    PaymentMethodResultClass data,
  ) {
    return ListTile(
      tileColor: Theme.of(context).shadowColor,
      title: Text(
        getTargetTopUpMethodString(data),
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.w600,
          fontSize: _deviceDetails.getTitleFontSize(),
        ),
      ),
    );
  }

  /// Wallet UI
  Widget getWalletAmountUI(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    return ListTile(
      tileColor: Theme.of(context).shadowColor,
      title: Row(
        children: [
          Text(
            'Wallet Amount: ',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: _deviceDetails.getTitleFontSize(),
            ),
          ),
          WalletAmountRealTimeText(
            fontSize: _deviceDetails.getTitleFontSize(),
            fontColor: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }

  // region Amount UI
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
        // setState(() {
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
        color: verification == true
            ? Colors.red
            : Theme.of(context).highlightColor,
      ),
      cursorColor: Theme.of(context).highlightColor,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(context).shadowColor,
        labelText: labelText,
        labelStyle: TextStyle(
          color: verification == true
              ? Colors.red
              : Theme.of(context).highlightColor,
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
          Expanded(
            child: Padding(
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
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
                _widgetSize.getResponsiveWidth(0.02, 0.02, 0.02),
                0,
                0,
              ),
              child: Text(
                "Min top up amount is RM $minAmount",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getAmountButtonsUI(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    return SizedBox(
      height: _widgetSize.getResponsiveHeight(0.07, 0.07, 0.07),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
          0,
          _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
          0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            amountButton(50, _deviceDetails, _widgetSize),
            SizedBox(
              width: _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
            ),
            amountButton(100, _deviceDetails, _widgetSize),
            SizedBox(
              width: _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
            ),
            amountButton(maxAmount, _deviceDetails, _widgetSize),
          ],
        ),
      ),
    );
  }

  Widget amountButton(
    int value,
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    return Expanded(
      child: InkWell(
        onTap: () => {
          setState(() {
            _amountController.text = value.toString();
          })
        },
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                spreadRadius: 1,
                blurRadius: 10,
                offset: Offset(7, 5), // changes position of shadow
              ),
            ],
            color: Theme.of(context).shadowColor,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              "RM " + formatCurrency.format(value).toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: _deviceDetails.getNormalFontSize(),
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // endregion

  Widget getTopUpButton(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
    PaymentMethodResultClass data,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(
            top: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05)),
        child: InkWell(
          onTap: () {
            if (isLoading == false) {
              FocusScope.of(context).unfocus();
              if (validate() == true) {
                hasInternet().then((value) async {
                  if (value == true) {
                    setLoadingStatus(true);
                    FirebaseAuth.instance.currentUser
                        ?.getIdToken()
                        .then((value) {
                      setLoadingStatus(false);

                      // Begin Loading for Get Token
                      setLoadingStatus(true);
                      fetchGetTokenApi(value).then((value) {
                        setLoadingStatus(false);
                        if (value.errorMessage == null) {
                          String? token = value.accessToken;
                          // log(token);
                          if (token != null) {
                            topUpProcess(data, token, _deviceDetails);
                          } else {
                            showMessage(
                              'Error',
                              'Unable to retrieve customer token',
                              _deviceDetails,
                              context,
                            );
                          }
                        }
                      });
                    });
                  } else {
                    showSnackBar('No Internet Connection', context);
                  }
                });
              }
            }
          },
          child: Container(
            width: _widgetSize.getResponsiveWidth(0.5, 0.5, 0.5),
            height: _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: Offset(7, 5), // changes position of shadow
                ),
              ],
              color: Theme.of(context).highlightColor,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: isLoading == true
                  ? CustomLoading()
                  : Text(
                      "Top Up",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: _deviceDetails.getNormalFontSize(),
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
  // endregion

  // region Function
  Future<int> getMinAmount() async {
    if (!mounted) {
      return 0;
    }

    int number = 0;
    await FirebaseFirestore.instance
        .collection('Setting_Config')
        .doc('TopUpSettings')
        .get()
        .then((value) {
      if (value["minTopUp"] != null) {
        if (value["minTopUp"] != '') {
          number = value["minTopUp"];
          // print("Token: " + token);
        }
      }
    });

    setState(() {});

    return number;
  }

  Future<int> getMaxAmount() async {
    if (!mounted) {
      return 0;
    }

    int number = 0;
    await FirebaseFirestore.instance
        .collection('Setting_Config')
        .doc('TopUpSettings')
        .get()
        .then((value) {
      if (value["maxTopUp"] != null) {
        if (value["maxTopUp"] != '') {
          number = value["maxTopUp"];
          // print("Token: " + token);
        }
      }
    });

    setState(() {});

    return number;
  }

  bool validate() {
    bool temp = false;
    if (_amountController.text.isEmpty) {
      _amountError = true;
      _amountController.text = 'Please enter your preferred amount';
    } else if (!isInt(_amountController.text)) {
      _amountController.clear();
      _amountError = true;
    } else if (int.parse(_amountController.text) > maxAmount) {
      _amountController.text = 'Max Top Up is RM $maxAmount';
      _amountError = true;
    } else if (int.parse(_amountController.text) < minAmount) {
      _amountError = true;
      _amountController.text = 'Min Top Up is RM $minAmount';
    } else {
      _amountError = false;
      temp = true;
    }
    return temp;
  }

  /// Determine Top Up Process
  Future<void> topUpProcess(
    PaymentMethodResultClass data,
    String token,
    DeviceDetails _deviceDetails,
  ) async {
    if (!mounted) {
      return;
    }

    /// BillPlz
    if (data.type == PaymentMethodType.BillPlz) {
      // Call BillPlz Top Up API
      billPlzTopUpApi(
        token,
        double.parse(_amountController.text).toStringAsFixed(2),
        _deviceDetails,
      );
    }

    /// BillPlz
    else if (data.type == PaymentMethodType.Payex) {
      // Call BillPlz Top Up API
      payexTopUpApi(
        token,
        double.parse(_amountController.text).toStringAsFixed(2),
        _deviceDetails,
      );
    }

    /// EGHL
    else {
      // Call EGHL Top Up API
      billPlzTopUpApi(
        token,
        double.parse(_amountController.text).toStringAsFixed(2),
        _deviceDetails,
      );
    }
  }

  /// BillPLz Top Up API
  Future<void> billPlzTopUpApi(
    String token,
    String amount,
    DeviceDetails _deviceDetails,
  ) async {
    if (FirebaseAuth.instance.currentUser == null) {
      return;
    }
    if (FirebaseAuth.instance.currentUser!.isAnonymous == true) {
      print("** Is Guest! Invalid Action");
      return;
    }

    /// Get Name
    String name = '';
    if (FirebaseAuth.instance.currentUser!.displayName != null) {
      name = FirebaseAuth.instance.currentUser!.displayName as String;
    } else {
      name = "Customer";
    }

    /// Get Email
    String email = '';
    if (FirebaseAuth.instance.currentUser!.email != null) {
      email = FirebaseAuth.instance.currentUser!.email as String;
    } else {
      email = "";
    }
    print("-- BillPlz Top Up Api Called ----------------------");
    setLoadingStatus(true);
    await fetchTopUpBillPlzApi(
      token,
      amount,
      name,
      email,
    ).then((value) {
      if (value.paymentForm != null) {
        if (value.paymentForm!.url != null) {
          String targetURL = value.paymentForm!.url as String;

          print("url: " + targetURL);
          launchURL(targetURL, "Top Up Wallet");
        } else {
          setLoadingStatus(false);
          showMessage(
            'Error BillPlz Top Up Api has error',
            'The payment url is null',
            _deviceDetails,
            context,
          );
        }
      } else {
        setLoadingStatus(false);
        showMessage(
            'Error', 'BillPlz Top Up Api has error', _deviceDetails, context);
      }
    });
  }

  /// Payex Top Up API
  Future<void> payexTopUpApi(
    String token,
    String amount,
    DeviceDetails _deviceDetails,
  ) async {
    if (FirebaseAuth.instance.currentUser == null) {
      return;
    }
    if (FirebaseAuth.instance.currentUser!.isAnonymous == true) {
      print("** Is Guest! Invalid Action");
      return;
    }

    /// Get Name
    String name = '';
    if (FirebaseAuth.instance.currentUser!.displayName != null) {
      name = FirebaseAuth.instance.currentUser!.displayName as String;
    } else {
      name = "Customer";
    }

    /// Get Email
    String email = '';
    if (FirebaseAuth.instance.currentUser!.email != null) {
      email = FirebaseAuth.instance.currentUser!.email as String;
    } else {
      email = "";
    }
    print("-- Payex Top Up Api Called ----------------------");
    setLoadingStatus(true);
    await fetchTopUpPayexApi(
      token,
      amount,
      name,
      email,
    ).then((value) {
      if (value.paymentForm != null) {
        if (value.paymentForm!.url != null) {
          String targetURL = value.paymentForm!.url as String;

          print("url: " + targetURL);
          launchURL(targetURL, "Top Up Wallet");
        } else {
          setLoadingStatus(false);
          showMessage(
            'Error Payex Top Up Api has error',
            'The payment url is null',
            _deviceDetails,
            context,
          );
        }
      } else {
        setLoadingStatus(false);
        showMessage(
          'Error',
          'Payex Top Up Api has error',
          _deviceDetails,
          context,
        );
      }
    });
  }

  Future<void> launchURL(
    String url,
    String title,
  ) async {
    if (kIsWeb) {
      setLoadingStatus(false);

      if (await canLaunch(url)) {
        await launch(
          url,
          forceSafariVC: true,
          forceWebView: true,
          // webOnlyWindowName: '_self',
          webOnlyWindowName: '_blank',
        );
      } else {
        throw 'Could not launch $url';
      }
      // await Navigator.pushReplacement(
      //   context,
      //   PageTransition(
      //     type: PageTransitionType.rightToLeft,
      //     child: WebViewWebEx(
      //       title: title,
      //       targetURL: url,
      //       orderIDS: orderID,
      //       paymentID: paymentID,
      //     ),
      //   ),
      // );
    } else {
      await Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeft,
          child: WebViewApp(
            targetURL: url,
            title: title,
          ),
        ),
      );

      setLoadingStatus(false);
    }
  }
  // endregion

  @override
  Widget build(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);
    PaymentMethodResultClass data =
        ModalRoute.of(context)?.settings.arguments as PaymentMethodResultClass;

    return Scaffold(
      appBar: CustomDefaultAppBar(
        widgetSize: _widgetSize,
        appbarTitle: data.paymentMethodName + ' Top Up',
        onTapFunction: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: getPageContent(
                context,
                _deviceDetails,
                _widgetSize,
                data,
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
    );
  }

  List<Widget> getPageContent(
    BuildContext context,
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
    PaymentMethodResultClass data,
  ) {
    List<Widget> pageContent = [];
    SizedBox _spacing = SizedBox(
      height: _widgetSize.getResponsiveHeight(0.01, 0.01, 0.01),
    );

    SizedBox _topSpacing = SizedBox(
      height: _widgetSize.getResponsiveHeight(0.07, 0.07, 0.07),
    );

    /// Pay By:
    pageContent.add(getTopUpMethodUI(_deviceDetails, _widgetSize, data));

    /// Wallet Amount
    pageContent.add(getWalletAmountUI(_deviceDetails, _widgetSize));

    pageContent.add(_topSpacing);
    pageContent.add(getAmountInputUI(_deviceDetails, _widgetSize));
    pageContent.add(getAmountButtonsUI(_deviceDetails, _widgetSize));
    pageContent.add(getTopUpButton(_deviceDetails, _widgetSize, data));

    pageContent.add(_spacing);

    return pageContent;
  }
}
