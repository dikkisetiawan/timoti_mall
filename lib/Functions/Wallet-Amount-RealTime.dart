import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WalletAmountRealTimeText extends StatefulWidget {
  final double fontSize;
  final FontWeight fontWeight;
  final Color fontColor;

  WalletAmountRealTimeText({
    required this.fontSize,
    required this.fontWeight,
    required this.fontColor,
  });

  @override
  _WalletAmountRealTimeTextState createState() =>
      _WalletAmountRealTimeTextState();
}

class _WalletAmountRealTimeTextState extends State<WalletAmountRealTimeText> {
  String walletAmount = '0';
  final formatCurrency = new NumberFormat.currency(
    locale: "ms-MY",
    symbol: "",
    decimalDigits: 2,
  );

  void initState() {
    getWalletAmountInit();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
      Map<String, dynamic>? tempMapData = Map<String, dynamic>();

      /// Assign Data
      tempMapData = value.data() as Map<String, dynamic>;

      if (tempMapData["walletAmount"] != null) {
        if (tempMapData["walletAmount"] != '') {
          walletAmount = tempMapData["walletAmount"];
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

  @override
  Widget build(BuildContext context) {
    return Text(
      formatCurrency.format(double.parse(walletAmount)).toString(),
      style: TextStyle(
        fontWeight: widget.fontWeight,
        color: widget.fontColor,
        fontSize: widget.fontSize,
      ),
    );
  }
}
