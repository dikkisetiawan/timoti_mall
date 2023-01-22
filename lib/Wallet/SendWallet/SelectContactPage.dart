import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:timoti_project/Data-Class/ContactData.dart';
import 'package:timoti_project/Screen-Size/Get-Device-Details.dart';
import 'package:timoti_project/Screen-Size/WidgetSizeCalculation.dart';
import 'package:timoti_project/Screen-Size/ui-utils.dart';
import 'package:timoti_project/Wallet/SendWallet/SendWalletPage.dart';
import 'package:timoti_project/enums/device-screen-type.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';

class SelectContactPage extends StatefulWidget {
  static const routeName = '/SelectContactPage';

  @override
  _SelectContactPageState createState() => _SelectContactPageState();
}

class _SelectContactPageState extends State<SelectContactPage> {
  List<ContactData> allContactData = <ContactData>[];

  @override
  void initState() {
    _askPermissions();
    super.initState();
  }

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

  // region Permission
  Future<void> _askPermissions() async {
    await Permission.contacts.request();
    var permissionStatus = await Permission.contacts.status;
    if (permissionStatus != PermissionStatus.granted) {
      print("Not Granted");
      _handleInvalidPermissions(permissionStatus);
    } else {
      print("Granted");
      getContacts();
    }
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      print("Permission Temporary Denied");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).highlightColor,
            content: Text(
              "To use this feature we need your contact permission",
              style: TextStyle(
                  color: Theme.of(context).backgroundColor,
                  fontWeight: FontWeight.bold),
            ),
            actions: [
              TextButton(
                child: Text("Cancel",
                    style: TextStyle(
                      color: Theme.of(context).backgroundColor,
                    )),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: Text("Ok",
                    style: TextStyle(
                      color: Theme.of(context).backgroundColor,
                    )),
                onPressed: () async {
                  Navigator.pop(context);
                  _askPermissions();
                },
              ),
            ],
          );
        },
      );
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      print("Permission Permanently Denied");
      Navigator.pop(context);
      openAppSettings();
    } else {
      print("Asking Permission");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).highlightColor,
            content: Text(
              "To use this feature we need your contact permission",
              style: TextStyle(
                  color: Theme.of(context).backgroundColor,
                  fontWeight: FontWeight.bold),
            ),
            actions: [
              TextButton(
                child: Text("Cancel",
                    style: TextStyle(
                      color: Theme.of(context).backgroundColor,
                    )),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: Text("Ok",
                    style: TextStyle(
                      color: Theme.of(context).backgroundColor,
                    )),
                onPressed: () async {
                  Navigator.pop(context);
                  _askPermissions();
                },
              ),
            ],
          );
        },
      );
    }
  }
  // endregion

  Future<void> getContacts() async {
    Iterable<Contact> _contacts =
        await ContactsService.getContacts(withThumbnails: false);

    _contacts.forEach((contact) {
      contact.phones!.toSet().forEach((phone) {
        if (phone.value != null || phone.value != '') {
          /// Remove Special Case
          String phoneNumber =
              phone.value!.replaceAll(new RegExp(r'[^\w\s]+'), '');

          /// Remove Space
          String finalPhoneNumber = phoneNumber.replaceAll(" ", "");
          if (finalPhoneNumber[0] != "6" && finalPhoneNumber[1] != "0") {
            finalPhoneNumber = "+6" + finalPhoneNumber;
          } else {
            finalPhoneNumber = "+" + finalPhoneNumber;
          }
          print(finalPhoneNumber);

          ContactData contactData = new ContactData(
            name: contact.displayName as String,
            phoneNumbers: finalPhoneNumber,
          );

          allContactData.add(contactData);
        }
      });
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);

    return Scaffold(
      appBar: _getCustomAppBar("Choose Receiver", _widgetSize, _deviceDetails),
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
            minWidth: MediaQuery.of(context).size.width,
          ),
          child: allContactData.length != 0
              ? ListView.builder(
                  scrollDirection: Axis.vertical,
                  physics: BouncingScrollPhysics(),
                  itemCount: allContactData.length,
                  itemBuilder: (BuildContext context, int i) {
                    /// First Index Guarantee have title
                    if (i == 0) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                              _widgetSize.getResponsiveWidth(0.02, 0.02, 0.02),
                              0,
                              _widgetSize.getResponsiveWidth(0.02, 0.02, 0.02),
                            ),
                            child: Text(
                              allContactData[i].name[0],
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: _deviceDetails.getTitleFontSize(),
                              ),
                            ),
                          ),
                          Container(
                            width: _widgetSize.getResponsiveWidth(1, 1, 1),
                            decoration: BoxDecoration(
                              color: Theme.of(context).shadowColor,
                              border: Border(
                                top: BorderSide(
                                  width: 0.6,
                                  color: Theme.of(context).dividerColor,
                                ),
                                bottom: BorderSide(
                                  width: 0.6,
                                  color: Theme.of(context).dividerColor,
                                ),
                              ),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.fromLTRB(
                                _widgetSize.getResponsiveWidth(
                                    0.05, 0.05, 0.05),
                                0,
                                _widgetSize.getResponsiveWidth(
                                    0.05, 0.05, 0.05),
                                0,
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                color: Theme.of(context).primaryColor,
                                size: _widgetSize.getResponsiveWidth(
                                    0.05, 0.05, 0.05),
                              ),
                              title: Text(
                                allContactData[i].name,
                                style: TextStyle(
                                  fontSize: _deviceDetails.getNormalFontSize(),
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              subtitle: Text(
                                allContactData[i].phoneNumbers,
                                style: TextStyle(
                                  fontSize: _deviceDetails.getNormalFontSize(),
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    type: PageTransitionType.rightToLeft,
                                    child: SendWalletPage(
                                      name: allContactData[i].name,
                                      phoneNumber:
                                          allContactData[i].phoneNumbers,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    }

                    // If previous and current have the same first alphabet
                    /// Wont Add Title
                    else if (i > 0 &&
                        (allContactData[i].name[0] ==
                            allContactData[i - 1].name[0])) {
                      return Container(
                        width: _widgetSize.getResponsiveWidth(1, 1, 1),
                        decoration: BoxDecoration(
                          color: Theme.of(context).shadowColor,
                          border: Border(
                            bottom: BorderSide(
                              width: 0.6,
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.fromLTRB(
                            _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                            0,
                            _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                            0,
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: Theme.of(context).primaryColor,
                            size: _widgetSize.getResponsiveWidth(
                                0.05, 0.05, 0.05),
                          ),
                          title: Text(
                            allContactData[i].name,
                            style: TextStyle(
                              fontSize: _deviceDetails.getNormalFontSize(),
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          subtitle: Text(
                            allContactData[i].phoneNumbers,
                            style: TextStyle(
                              fontSize: _deviceDetails.getNormalFontSize(),
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.rightToLeft,
                                child: SendWalletPage(
                                  name: allContactData[i].name,
                                  phoneNumber: allContactData[i].phoneNumbers,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }

                    /// Other Index Guarantee have title
                    else {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                              _widgetSize.getResponsiveWidth(0.02, 0.02, 0.02),
                              0,
                              _widgetSize.getResponsiveWidth(0.02, 0.02, 0.02),
                            ),
                            child: Text(
                              allContactData[i].name[0],
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: _deviceDetails.getTitleFontSize(),
                              ),
                            ),
                          ),
                          Container(
                            width: _widgetSize.getResponsiveWidth(1, 1, 1),
                            decoration: BoxDecoration(
                              color: Theme.of(context).shadowColor,
                              border: Border(
                                top: BorderSide(
                                  width: 0.6,
                                  color: Theme.of(context).dividerColor,
                                ),
                                bottom: BorderSide(
                                  width: 0.6,
                                  color: Theme.of(context).dividerColor,
                                ),
                              ),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.fromLTRB(
                                _widgetSize.getResponsiveWidth(
                                    0.05, 0.05, 0.05),
                                0,
                                _widgetSize.getResponsiveWidth(
                                    0.05, 0.05, 0.05),
                                0,
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                color: Theme.of(context).primaryColor,
                                size: _widgetSize.getResponsiveWidth(
                                    0.05, 0.05, 0.05),
                              ),
                              title: Text(
                                allContactData[i].name,
                                style: TextStyle(
                                  fontSize: _deviceDetails.getNormalFontSize(),
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              subtitle: Text(
                                allContactData[i].phoneNumbers,
                                style: TextStyle(
                                  fontSize: _deviceDetails.getNormalFontSize(),
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    type: PageTransitionType.rightToLeft,
                                    child: SendWalletPage(
                                      name: allContactData[i].name,
                                      phoneNumber:
                                          allContactData[i].phoneNumbers,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    }
                  },
                )
              : Padding(
                  padding: EdgeInsets.fromLTRB(
                    _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                    _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                    0,
                    _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
                  ),
                  child: Text(
                    "Empty Contacts",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: _deviceDetails.getNormalFontSize(),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
