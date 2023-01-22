import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:timoti_project/Account/AccountPage.dart';
import 'package:timoti_project/Cart/CartPage.dart';
import 'package:timoti_project/Home/HomePage.dart';
import 'package:timoti_project/Message/MessagePage.dart';
import 'package:timoti_project/Screen-Size/ui-utils.dart';
import 'package:timoti_project/Wallet/WalletPage.dart';
import 'package:timoti_project/enums/device-screen-type.dart';

class Nav extends StatefulWidget {
  static const routeName = '/Nav';
  // const Nav({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BottomAppBarState();
  }
}

class BottomAppBarState extends State<Nav> {
  int _currentIndex = 0;

  /// Firebase
  User? firebaseUser = FirebaseAuth.instance.currentUser;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  int cartQuantity = 0;

  @override
  void initState() {
    // updateCartQuantity();
    super.initState();
  }

  List<Widget> get _children => [
        HomePage(bottomAppBarState: this),
        CartPage(bottomAppBarState: this),
        WalletPage(),
        MessagePage(),
        AccountPage(),
      ];

  // region Function
  /// Get cart quantity
  int getCartQuantity() {
    int tempQuantity = 0;
    if (cartQuantity > 0) {
      tempQuantity = cartQuantity;
    }
    return tempQuantity;
  }

  /// Update Cart quantity
  Future<void> updateCartQuantity() async {
    if (firebaseUser != null) {
      /// Get User All Branch Cart
      QuerySnapshot cartSnapshot;
      cartSnapshot = await firestore
          .collection('Cart')
          .where("User_ID", isEqualTo: firebaseUser!.uid)
          .get();

      if (cartSnapshot.docs.length > 0) {
        int tempQuantity = 0;

        /// Define Temp Map Data
        Map<String, dynamic>? cartSnapshotMapData = Map<String, dynamic>();

        /// Get each branch cart quantity
        for (int i = 0; i < cartSnapshot.docs.length; ++i) {
          /// Assign Data
          cartSnapshotMapData =
              cartSnapshot.docs[i].data() as Map<String, dynamic>;
          tempQuantity += cartSnapshotMapData["Qty"] as int;
        }

        cartQuantity = tempQuantity;
        if (this.mounted) {
          print("*** Bottom App Bar Cart QTY Updated");
          setState(() {});
        }
      } else {
        cartQuantity = 0;
        if (this.mounted) {
          print("*** Bottom App Bar Cart QTY is 0");
          setState(() {});
        }
      }

      /// Updated Page
      // _cartPageKey.currentState.refresh();
    } else {
      print("*** User is NULL");
    }
  }
  // endregion

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    return Scaffold(
        // body: IndexedStack(
        //   index: _currentIndex,
        //   children: _children,
        // ),
        body: _children[_currentIndex],
        bottomNavigationBar:
            getDeviceType(mediaQuery) != DeviceScreenType.Desktop
                ? myBottomNavigationBar(25, 15)
                : null);
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      // if (index == 1) {
      //   /// Updated Cart Page
      //   _cartPageKey.currentState.refresh();
      // }
    });
  }

  myBottomNavigationBar(double iconValue, double fontSizeValue) {
    return BottomNavigationBar(
      // key: navBarGlobalKey,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.black,
      currentIndex: _currentIndex,
      selectedItemColor: Theme.of(context).highlightColor,
      unselectedItemColor: Colors.white,
      onTap: onTabTapped,
      items: [
        // Home Page
        bottomIcon(
          'Home',
          Icon(
            Icons.home,
            color: Colors.white,
            size:iconValue ,
          ),
          Icon(
            Icons.home,
            color: Theme.of(context).highlightColor,
            size:iconValue ,
          ),
          iconValue,
          fontSizeValue,
          0,
          _currentIndex,
        ),

        // Cart Page
        bottomIcon(
          'Cart',
          Image.asset(
            'assets/icon/cart.png',
            width: iconValue,
            height: iconValue,
            color: Colors.white,
          ),
          Image.asset(
            'assets/icon/cart.png',
            width: iconValue,
            height: iconValue,
            color: Theme.of(context).highlightColor,
          ),
          iconValue,
          fontSizeValue,
          1,
          _currentIndex,
        ),

        // Wallet Page
        bottomIcon(
          'Wallet',
          Image.asset(
            'assets/icon/wallet.png',
            width: iconValue,
            height: iconValue,
            color: Colors.white,
          ),
          Image.asset(
            'assets/icon/wallet.png',
            width: iconValue,
            height: iconValue,
            color: Theme.of(context).highlightColor,
          ),
          iconValue,
          fontSizeValue,
          2,
          _currentIndex,
        ),

        // Message Page
        bottomIcon(
          'Message',
          Image.asset(
            'assets/icon/message.png',
            width: iconValue,
            height: iconValue,
            color: Colors.white,
          ),
          Image.asset(
            'assets/icon/message.png',
            width: iconValue,
            height: iconValue,
            color: Theme.of(context).highlightColor,
          ),
          iconValue,
          fontSizeValue,
          3,
          _currentIndex,
        ),

        // Account Page
        bottomIcon(
          'Account',
          Image.asset(
            'assets/icon/profile.png',
            width: iconValue,
            height: iconValue,
            color: Colors.white,
          ),
          Image.asset(
            'assets/icon/profile.png',
            width: iconValue,
            height: iconValue,
            color: Theme.of(context).highlightColor,
          ),
          iconValue,
          fontSizeValue,
          4,
          _currentIndex,
        ),
      ],
    );
  }

  BottomNavigationBarItem bottomIcon(
    String bottomText,
    Widget unActiveIcon,
    Widget activeIcon,
    double iconValue,
    double fontSizeValue,
    int index,
    int currentIndex,
  ) {
    return BottomNavigationBarItem(
      // backgroundColor: Colors.white,
      icon: Container(
        width: iconValue + 40,
        height: iconValue + 12,
        child: Align(
          alignment: Alignment.center,
          child: unActiveIcon,
        ),
      ),
      /*title: Text(
        bottomText,
        style: TextStyle(
          fontSize: fontSizeValue,
          color: _currentIndex == index
              ? Theme.of(context).highlightColor
              : Colors.white,
        ),
      ),*/
      label: bottomText,
      activeIcon: Container(
        width: iconValue + 40,
        height: iconValue + 12,
        child: Align(
          alignment: Alignment.center,
          child: activeIcon,
        ),
      ),
    );
  }
}
