import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timoti_project/Address-Page/Address-Add.dart';
import 'package:timoti_project/Address-Page/Address-Edit.dart';
import 'package:timoti_project/Address-Page/AddressClass.dart';
import 'package:timoti_project/Address-Page/AddressEditArgument.dart';
import 'package:timoti_project/Custom-UI/Custom-LoadingUI.dart';
import 'package:timoti_project/Functions/Messager.dart';
import 'package:timoti_project/Screen-Size/Get-Device-Details.dart';
import 'package:timoti_project/Screen-Size/WidgetSizeCalculation.dart';
import 'package:timoti_project/Screen-Size/ui-utils.dart';
import 'package:timoti_project/enums/device-screen-type.dart';

class AddressMainPage extends StatefulWidget {
  static const routeName = '/_AddressMainPage';
  @override
  _AddressMainPageState createState() => _AddressMainPageState();
}

class _AddressMainPageState extends State<AddressMainPage> {
  /// Firebase
  User firebaseUser = FirebaseAuth.instance.currentUser as User;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<AddressClass> addressDataList = <AddressClass>[];

  bool loading = false;

  @override
  void initState() {
    print(firebaseUser.displayName);

    /// Get User Address
    getUserAddress();

    super.initState();
  }

  // region UI
  PreferredSize _getCustomAppBar(
    String title,
    WidgetSizeCalculation _widgetSize,
    DeviceDetails _deviceDetails,
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

  /// Data Address UI
  Widget getDataAddressUI(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
    AddressClass data,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 0.6,
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: ListTile(
        tileColor: Theme.of(context).shadowColor,
        onTap: () {
          Navigator.pop(
            context,
            data,
          );
        },
        leading: Icon(
          data.label == "Home" ? Icons.home : Icons.label,
          color: Colors.grey,
          size: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
        ),
        title: Text(
          data.label as String,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: _deviceDetails.getTitleFontSize(),
          ),
        ),

        /// Edit & Delete
        trailing: Container(
          width: _widgetSize.getResponsiveWidth(0.25, 0.25, 0.25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// Edit
              InkWell(
                splashColor: Colors.transparent,
                onTap: () {
                  AddressEditArgument arg =
                      new AddressEditArgument(addressClass: data);

                  Navigator.pushNamed(context, AddressEditPage.routeName,
                          arguments: arg)
                      .then((value) {
                    addressDataList.clear();
                    getUserAddress();
                    setState(() {});
                  });
                },
                child: Text(
                  "Edit",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: _deviceDetails.getNormalFontSize(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              /// Line
              Text("|",
                  style: TextStyle(color: Theme.of(context).primaryColor)),

              /// Delete
              InkWell(
                splashColor: Colors.transparent,
                onTap: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: Theme.of(context).backgroundColor,
                        content: Text(
                          'Remove ${data.label} ?',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        actions: [
                          /// Cancel
                          TextButton(
                            child: Text("Cancel",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                )),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text("Delete",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                )),
                            onPressed: () {
                              hasInternet().then((value) {
                                if (value == true) {
                                  removeAddress(
                                          data.index as int, _deviceDetails)
                                      .then((value) {
                                    addressDataList.clear();
                                    getUserAddress();
                                    setState(() {});
                                  });
                                } else {
                                  showSnackBar("No Internet Connection");
                                }
                              });
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text(
                  "Delete",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: _deviceDetails.getNormalFontSize(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Add new address UI
  Widget getAddNewAddressUI(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 0.6,
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: ListTile(
        tileColor: Theme.of(context).shadowColor,
        onTap: () {
          Navigator.pushNamed(context, AddressAddPage.routeName).then((value) {
            addressDataList.clear();
            getUserAddress();
            setState(() {});
          });
        },
        leading: Icon(
          Icons.add,
          color: Colors.grey,
          size: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
        ),
        title: Text(
          "Add New",
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: _deviceDetails.getTitleFontSize(),
          ),
        ),
      ),
    );
  }
  // endregion

  // region Functions
  void getUserAddress() async {
    DocumentSnapshot userDocument;
    userDocument =
        await firestore.collection('Customers').doc(firebaseUser.uid).get();

    /// Define Map Data
    Map<String, dynamic> data = Map<String, dynamic>();

    /// Assign Data
    data = userDocument.data() as Map<String, dynamic>;

    /// - If data found
    if (data["Address"] != null) {
      print("Has Address");
      if (data["Address"].length > 0) {
        AddressClass temp = AddressClass();
        for (int i = 0; i < data["Address"].length; ++i) {
          temp = AddressClass(
            addressDetails: data["Address"][i]["Address_Details"],
            city: data["Address"][i]["City"],
            state: data["Address"][i]["State"],
            postcode: data["Address"][i]["Postcode"],
            country: data["Address"][i]["Country"],
            phone: data["Address"][i]["Phone"],
            fullName: data["Address"][i]["Full_Name"],
            label: data["Address"][i]["Label"] != null
                ? data["Address"][i]["Label"]
                : "Address ${i + 1}",
            index: i,
            latitude: data["Address"][i]["Latitude"],
            longitude: data["Address"][i]["Longitude"],
          );
          addressDataList.add(temp);

          if (i == data["Address"].length - 1) {
            setState(() {});
          }
        }
      }
    } else {
      print("No Address Found");
    }
  }

  /// Remove Address
  Future<void> removeAddress(
    int targetIndex,
    DeviceDetails _deviceDetails,
  ) async {
    loading = true;
    setState(() {});

    DocumentSnapshot userDocument;
    userDocument =
        await firestore.collection('Customers').doc(firebaseUser.uid).get();

    /// Define Map Data
    Map<String, dynamic> data = Map<String, dynamic>();

    /// Assign Data
    data = userDocument.data() as Map<String, dynamic>;

    /// Has Address Field
    if (data["Address"] != null) {
      print("Has Address Field");
      if (data["Address"].length > 0) {
        print("This has other address");
        List<dynamic> finalList = [];

        for (int i = 0; i < data["Address"].length; ++i) {
          /// Dont add current Index
          if (i != targetIndex) {
            /// Assign Data
            AddressClass tempAddress = new AddressClass(
              addressDetails: data["Address"][i]["Address_Details"],
              state: data["Address"][i]["State"],
              city: data["Address"][i]["City"],
              country: data["Address"][i]["Country"],
              fullName: data["Address"][i]["Full_Name"],
              label: data["Address"][i]["Label"],
              phone: data["Address"][i]["Phone"],
              postcode: data["Address"][i]["Postcode"],
              latitude: data["Address"][i]["Latitude"],
              longitude: data["Address"][i]["Longitude"],
            );

            /// Add to List
            finalList.add(tempAddress.toMap());
          }

          /// Reach Last Index (Update Data)
          if (i == data["Address"].length - 1) {
            await FirebaseFirestore.instance
                .collection("Customers")
                .doc(firebaseUser.uid)
                .update({
              'Address': finalList,
            }).then((value) async {
              print("Added Address on user: " + firebaseUser.uid);
              print("Index: " + targetIndex.toString());
              loading = false;
              setState(() {});

              /// Message
              showMessage(
                "",
                'Address Updated',
                _deviceDetails,
                context,
              );
            });
          }
        }
      }
    }

    /// No Address field
    else {
      print("No Address Field");
      loading = false;
      setState(() {});
    }
  }

  /// Check Internet Status
  Future<bool> hasInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    } else {
      // Neither mobile data or WIFI detected, not internet connection found.
      return false;
    }
  }

  /// Show Snackbar below
  void showSnackBar(String textData) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(textData),
      duration: const Duration(seconds: 1),
      // action: SnackBarAction(
      //   label: 'ACTION',
      //   onPressed: () { },
      // ),
    ));
  }
  // endregion

  @override
  Widget build(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);

    return Scaffold(
      appBar: _getCustomAppBar("Select Address", _widgetSize, _deviceDetails),
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
            minWidth: MediaQuery.of(context).size.width,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: getPageContent(
                context,
                _deviceDetails,
                _widgetSize,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> getPageContent(
    BuildContext context,
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    List<Widget> pageContent = [];
    // allAddress.clear();

    /// Spacing
    SizedBox _spacing = SizedBox(
      height: _widgetSize.getResponsiveHeight(0.03, 0.03, 0.03),
    );

    /// Spacing
    SizedBox _spacing2 = SizedBox(
      height: _widgetSize.getResponsiveHeight(0.1, 0.1, 0.1),
    );

    if (loading == false) {
      /// Show Default Address
      if (addressDataList.length > 0) {
        /// Spacing
        pageContent.add(_spacing);

        /// Default Title
        pageContent.add(
          Padding(
            padding: EdgeInsets.fromLTRB(
                _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                0,
                0,
                _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03)),
            child: Text(
              "Default Address",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: _deviceDetails.getTitleFontSize(),
              ),
            ),
          ),
        );

        /// List all address
        pageContent.add(
            getDataAddressUI(_deviceDetails, _widgetSize, addressDataList[0]));
      }

      /// Save Places Title
      pageContent.add(
        Padding(
          padding: EdgeInsets.fromLTRB(
              _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
              _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
              0,
              _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03)),
          child: Row(
            children: [
              /// Title
              Text(
                "Saved Places",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: _deviceDetails.getTitleFontSize(),
                ),
              ),

              SizedBox(width: 10),

              /// Info
              InkWell(
                onTap: () {
                  showMessage(
                    "",
                    'These are the address you saved',
                    _deviceDetails,
                    context,
                  );
                },
                child: Icon(
                  Icons.info_outline,
                  color: Theme.of(context).highlightColor,
                  size: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                ),
              )
            ],
          ),
        ),
      );

      if (addressDataList.length > 0) {
        /// List all address
        for (int i = 0; i < addressDataList.length; ++i) {
          pageContent.add(
            getDataAddressUI(
              _deviceDetails,
              _widgetSize,
              addressDataList[i],
            ),
          );
        }
      }

      /// Add new address
      pageContent.add(getAddNewAddressUI(_deviceDetails, _widgetSize));
    }

    /// Loading is true
    else {
      pageContent.add(Center(child: CustomLoading()));
    }

    /// Spacing
    pageContent.add(_spacing);

    pageContent.add(SizedBox(
      height: _widgetSize.getResponsiveHeight(0.1, 0.1, 0.1),
    ));
    return pageContent;
  }
}
